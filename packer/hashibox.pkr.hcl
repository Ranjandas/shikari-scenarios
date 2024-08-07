packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "arch" {
  type        = string
  default     = "aarch64"
  description = "Architecture of the machine where you'd run the image"
}

variable "enterprise" {
  type        = bool
  default     = false
  description = "Switch between Enterprise and CE binaries for installation"
}

variable "fips" {
  type        = bool
  default     = false
  description = "Switch between FIPS and non-FIPS binaries for installation"
}

variable "consul_version" {
  type        = string
  default     = "1.19"
  description = "Consul version to install"
}

variable "nomad_version" {
  type        = string
  default     = "1.8"
  description = "Nomad version to install"
}

variable "vault_version" {
  type        = string
  default     = "1.17"
  description = "Vault version to install"
}

variable "boundary_version" {
  type        = string
  default     = "0.16"
  description = "Boundary version to install"
}

variable "consul_cni_version" {
  type        = string
  default     = "1.5.0"
  description = "Consul CNI version to install"
}

variable "source_image_url" {
  type        = string
  default     = "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/aarch64/images/Fedora-Cloud-Base-Generic.aarch64-40-1.14.qcow2"
  description = "Fedora Cloud Image URL - qcow2 format"
}

variable "source_image_checksum" {
  type        = string
  default     = "file:https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/aarch64/images/Fedora-Cloud-40-1.14-aarch64-CHECKSUM"
  description = "Checksum in the packer format of the cloud image"
}

locals {
  qemu_binary       = "${var.arch == "aarch64" ? "qemu-system-aarch64" : "qemu-system-x86_64"}"
  accelerator       = "hvf"
  cpu_model         = "${var.arch == "aarch64" ? "cortex-a57" : "host"}"
  machine_type      = "${var.arch == "aarch64" ? "virt" : "pc"}"
  efi_boot          = "${var.arch == "aarch64" ? true : false}"
  efi_firmware_code = "${var.arch == "aarch64" ? "/opt/homebrew/share/qemu/edk2-aarch64-code.fd" : ""}"
  efi_firmware_vars = "${var.arch == "aarch64" ? "/opt/homebrew/share/qemu/edk2-arm-vars.fd" : ""}"

  source_image_url      = "${var.arch == "aarch64" ? var.source_image_url : replace(var.source_image_url, "aarch64", "x86_64")}"
  source_image_checksum = "${var.arch == "aarch64" ? var.source_image_checksum : replace(var.source_image_checksum, "aarch64", "x86_64")}"
}

locals {
  # fips will always be enterprise. We are using '*' here as the Vault FIPS package name is vault-enterprise-fips1402
  is_fips = "${var.fips ? "enterprise-fips*" : "enterprise"}"

  is_ent = "${var.enterprise || var.fips ? true : false}"


  # switch between Enterprise and CE 
  nomad_version    = "${local.is_ent ? join("-", ["enterprise", var.nomad_version]) : var.nomad_version}"
  boundary_version = "${local.is_ent ? join("-", ["enterprise", var.boundary_version]) : var.boundary_version}"

  # only Consul and Nomad has FIPS
  consul_version = "${local.is_ent ? join("-", [local.is_fips, var.consul_version]) : var.consul_version}"
  vault_version  = "${local.is_ent ? join("-", [local.is_fips, var.vault_version]) : var.vault_version}"

  # used to name the VM image
  image_id_format = "c-${var.consul_version}-n-${var.nomad_version}-v-${var.vault_version}-b-${var.boundary_version}"
  image_id_string = "${local.is_ent ? join("-", [replace(local.is_fips, "*", ""), local.image_id_format]) : local.image_id_format}"
}

source "qemu" "hashibox" {
  iso_url      = "${local.source_image_url}"
  iso_checksum = "${local.source_image_checksum}"

  headless = true

  disk_compression = true
  disk_interface   = "virtio"
  disk_image       = true

  format       = "qcow2"
  vm_name      = "hashibox.qcow2"
  boot_command = []
  net_device   = "virtio-net"

  output_directory = pathexpand(join("/", ["~/.shikari", local.image_id_string]))

  cpus   = 8
  memory = 5120

  qemu_binary       = "${local.qemu_binary}"
  accelerator       = "hvf"
  cpu_model         = "${local.cpu_model}"
  machine_type      = "${local.machine_type}"
  efi_boot          = "${local.efi_boot}"
  efi_firmware_code = "${local.efi_firmware_code}"
  efi_firmware_vars = "${local.efi_firmware_vars}"

  qemuargs = [
    ["-cdrom", "userdata/cidata.iso"],
    ["-monitor", "none"],
    ["-no-user-config"]
  ]

  communicator     = "ssh"
  shutdown_command = "echo shikari | sudo -S shutdown -P now"
  ssh_password     = "shikari"
  ssh_username     = "shikari"

  ssh_timeout = "10m"
}

build {
  sources = ["source.qemu.hashibox"]

  provisioner "shell" {
    environment_vars = [
      "CONSUL_VERSION=${local.consul_version}",
      "NOMAD_VERSION=${local.nomad_version}",
      "VAULT_VERSION=${local.vault_version}",
      "BOUNDARY_VERSION=${local.boundary_version}",
      "CONSUL_CNI_VERSION=${var.consul_cni_version}"
    ]
    inline = [
      "sudo dnf clean all",
      "sudo dnf install -y unzip wget postgresql",

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
      "sudo dnf install -y consul-$CONSUL_VERSION* nomad-$NOMAD_VERSION* vault-$VAULT_VERSION* boundary-$BOUNDARY_VERSION* containernetworking-plugins",

      # Nomad expects CNI binaries to be under /opt/cni/bin by default. We use symlink to avoid configuring alternate path in Nomad.
      "sudo mkdir /opt/cni && sudo ln -s /usr/libexec/cni /opt/cni/bin",

      # Consul CNI Binary, required for Nomad Transparent Proxy Support.
      "curl -L -o /tmp/consul-cni.zip https://releases.hashicorp.com/consul-cni/$${CONSUL_CNI_VERSION}/consul-cni_$${CONSUL_CNI_VERSION}_linux_$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64).zip",
      "sudo unzip /tmp/consul-cni.zip -d /usr/libexec/cni/",

      # Provision Nomad, Consul and Vault CA's that can be later used for agent cert provisioning.
      "sudo install -o consul -g consul -d /etc/consul.d/certs && cd /etc/consul.d/certs ; sudo consul tls ca create",
      "sudo install -o nomad -g nomad -d /etc/nomad.d/certs && cd /etc/nomad.d/certs ; sudo nomad tls ca create",
      # this will generate CA with the name vault-agent-ca.pem. Ensure the cert generation commands out of these CA use `-domain vault`
      "sudo install -o vault -g vault -d /etc/vault.d/certs && cd /etc/vault.d/certs ; sudo consul tls ca create -domain vault",
      # this will generate CA with the name boundary-agent-ca.pem. Ensure the cert generation commands out of these CA use `-domain boundary`
      "sudo install -o boundary -g boundary -d /etc/boundary.d/certs && cd /etc/boundary.d/certs ; sudo consul tls ca create -domain boundary",

      # Install exec2 driver
      "sudo dnf install -y nomad-driver-exec2 --enablerepo hashicorp-test",

      # Enabling of the services is the responsibility of the instance provisioning scripts.
      "sudo systemctl disable docker consul nomad vault boundary"
    ]
  }
}
