# shikari-scenarios
A collection of Lima Templates that will be used with Shikari.

## Prerequisites

The following tools are required to run these scenarios:

* HashiCorp [Packer](https://developer.hashicorp.com/packer) (if you are building custom images)
* CDRtools (if you are building custom images)
* [Lima](https://lima-vm.io/)
* [Shikari](https://github.com/ranjandas/shikari)

You can use the Brewfile shipped in this repository to install all the dependent tools.

```
$ brew bundle
Using hashicorp/tap
Tapping ranjandas/shikari
Installing ranjandas/shikari/shikari
Using hashicorp/tap/packer
Using hashicorp/tap/nomad
Using hashicorp/tap/consul
Using cdrtools
Using qemu
Using lima
Using socket_vmnet
Homebrew Bundle complete! 10 Brewfile dependencies now installed.
```

### Setup Socket_vmnet

Run the following commands to configure socket_vmnet.

```
$ limactl sudoers > etc_sudoers.d_lima
$ sudo install -o root etc_sudoers.d_lima /etc/sudoers.d/lima
```

### Run Test VM

Run a test VM to verify the socket_vmnet is configred properly. Verify that the `lima0` interface inside the VM has an IP Address.

```
$ limactl start template://alpine --network=lima:shared

$ limactl shell alpine ifconfig lima0
lima0     Link encap:Ethernet  HWaddr 52:55:55:96:B6:B1
          inet addr:192.168.105.2  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::5055:55ff:fe96:b6b1/64 Scope:Link
          inet6 addr: fdff:bed9:f801:6df1:5055:55ff:fe96:b6b1/64 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:9 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1252 (1.2 KiB)  TX bytes:1291 (1.2 KiB)

```

Once the above pre-requisites are met, you can proceed using Shikari to launch clusters based on various scenarios.

## Usage

The following steps will build a VM image with Consul and Nomad installed, which will be used as the source of the VMs created using Shikari.

1. Build the base VM image

    ```
    $ cd packer 
    $ packer init hashibox.pkr.hcl
    $ packer build -var-file variables.pkrvars.hcl hashibox.pkr.hcl
    ```
    > NOTE: Pass `-var enterprise=true` for Enterprise binaries and `-var fips=true` for fips binaries repsectively.
    
    This will build the VM image into the `.artifacts` directory in the current directory.

2. Now you can run the scenarios by going into specific scenario directory and invoking the template using Shikari.

    > NOTE: You can avoid passing the image on the CLI by setting the `image.location` inside the template file (hashibox.yaml) to point to the newly created image file in the previous step. (this should end with `.qcow2`). Run the following command to get the absolute path to the image file.
    > ```
    > readlink -f .artifacts/<image-dir>/<image-file>.cqow2
    > ```

    ```
    $ cd scenarios/nomad-consul-quickstart
    $ shikari create --name demo --servers 3 --clients 3 -i ../../.artifacts/<image-dir>/<image-file>.cqow2
    ```

    The above example command will create 3 servers and 3 clients using the image we previously built using packer.

3. Export the environment variables to access the cluster services.

    ```
    $ eval $(shikari env -n demo consul)
    ```

4. You can exec into the servers using the `limactl shell <vm-name>` command.
