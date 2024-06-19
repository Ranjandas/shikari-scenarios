packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "consul_version" {
  type        = string
  default     = "1.18"
  description = "Consul version to install"
}

variable "nomad_version" {
  type        = string
  default     = "1.7"
  description = "Nomad version to install"
}

variable "consul_cni_version" {
  type        = string
  default     = "1.5.0"
  description = "Consul CNI version to install"
}

variable "source_image_url" {
  type = string
  default     = "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/aarch64/images/Fedora-Cloud-Base-Generic.aarch64-40-1.14.qcow2"
  description = "Fedora Cloud Image URL - qcow2 format"
}

variable "source_image_checksum" {
  type = string
  default     = "file:https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/aarch64/images/Fedora-Cloud-40-1.14-aarch64-CHECKSUM"
  description = "Checksum in the packer format of the cloud image"
}

source "qemu" "hashibox" {
  iso_url      = "${var.source_image_url}"
  iso_checksum = "${var.source_image_checksum}"

  headless = true

  disk_compression = true
 # disk_size        = "5G"
  disk_interface   = "virtio"
  disk_image       = true

  format       = "qcow2"
  vm_name      = "c-${var.consul_version}-n-${var.nomad_version}.qcow2"
  boot_command = []
  net_device   = "virtio-net"

  output_directory = ".artifacts/c-${var.consul_version}-n-${var.nomad_version}"

  qemu_binary  = "qemu-system-aarch64"
  accelerator  = "hvf"
  cpu_model    = "cortex-a57"
  machine_type = "virt"

  cpus   = 8
  memory = 5120


  efi_boot          = true
  efi_firmware_code = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  efi_firmware_vars = "/opt/homebrew/share/qemu/edk2-arm-vars.fd"

  qemuargs = [
    ["-cdrom", "userdata/cidata.iso"],
    ["-monitor", "none"],
    ["-no-user-config"]
  ]

  communicator     = "ssh"
  shutdown_command = "echo shikari | sudo -S shutdown -P now"
  ssh_password     = "shikari"
  ssh_username     = "shikari"

  ssh_timeout      = "10m"
}

build {
  sources = ["source.qemu.hashibox"]

  provisioner "shell" {
    environment_vars = [
      "CONSUL_VERSION=${var.consul_version}",
      "NOMAD_VERSION=${var.nomad_version}",
      "CONSUL_CNI_VERSION=${var.consul_cni_version}"
    ]
    inline = [
      "sudo dnf clean all",
      "sudo dnf install -y unzip wget",

      # For multicast DNS to use with socket_vmnet in Lima we use systemd-resolved. For rocky we have to install epel repo for Crudini.
      "source /etc/os-release && [[ $ID != fedora ]] && sudo dnf install -y epel-release systemd-resolved && sudo systemctl enable --now systemd-resolved",
      "sudo dnf install -y crudini $([ $(source /etc/os-release && echo $ID) != fedora ] && echo --enablerepo=epel)",
      "sudo mkdir /etc/systemd/resolved.conf.d/ && sudo crudini --ini-options=nospace --set /etc/systemd/resolved.conf.d/mdns.conf Resolve MulticastDNS yes",
      
      # With systemd-resolved enabled, we should use the stub-resolver for mDNS to work.
      "sudo rm /etc/resolv.conf && sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf",

      # Enable Docker repository and install Docker-CE
      "sudo dnf config-manager --add-repo https://download.docker.com/linux/$([ $(source /etc/os-release && echo $ID) == fedora ] && echo fedora || echo rhel)/docker-ce.repo",
      "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      # Enable HashiCorp Repository and install the required packages including CNI libs
      "sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/$([ $(source /etc/os-release && echo $ID) == fedora ] && echo fedora || echo RHEL)/hashicorp.repo",
      "sudo dnf install -y consul-$CONSUL_VERSION* nomad-$NOMAD_VERSION* containernetworking-plugins",

      # Nomad expects CNI binaries to be under /opt/cni/bin by default. We use symlink to avoid configuring alternate path in Nomad.
      "sudo mkdir /opt/cni && sudo ln -s /usr/libexec/cni /opt/cni/bin",

      # Consul CNI Binary, required for Nomad Transparent Proxy Support.
      "curl -L -o /tmp/consul-cni.zip https://releases.hashicorp.com/consul-cni/$${CONSUL_CNI_VERSION}/consul-cni_$${CONSUL_CNI_VERSION}_linux_$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64).zip",
      "sudo unzip /tmp/consul-cni.zip -d /usr/libexec/cni/",

      # Provision Nomad and Consul CA's that can be later used for agent cert provisioning.
      "sudo mkdir /etc/consul.d/certs && cd /etc/consul.d/certs ; sudo consul tls ca create",
      "sudo mkdir /etc/nomad.d/certs && cd /etc/nomad.d/certs ; sudo nomad tls ca create",

      # Set permissions for the certs directory
      "sudo chown consul:consul /etc/consul.d/certs",
      "sudo chown nomad:nomad /etc/nomad.d/certs",

      # Enabling of the services is the responsibility of the instance provisioning scripts.
      "sudo systemctl disable docker consul nomad"
    ]
  }
}
