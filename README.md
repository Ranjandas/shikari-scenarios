# shikari-scenarios
A collection of Lima Templates that will be used with Shikari.

## Prerequisites

The following tools are required to run these scenarios:

* HashiCorp [Packer](https://developer.hashicorp.com/packer) (if you are building custom images)
* CDRtools (if you are building custom images)
* [Lima](https://lima-vm.io/)
* [Shikari](https://github.com/ranjandas/shikari)

> NOTE: all the above expect shikari can be installed using Homebrew

## Usage

The following steps will build a VM image with Consul and Nomad installed, which will be used as the source of the VMs created using Shikari.

1. Build the base VM image

    ```
    $ cd packer
    $ packer build -var-file variables.pkrvars.hcl hashibox.pkr.hcl
    ```
    This will build the VM image into the `.artifacts` directory in the current directory.

2. Now you can run the scenarios by going into specific scenario directory and invoking the template using Shikari.

    First update the `image.location` inside the template file to point to the newly created image file in the previous step. (this should end with `.qcow2`)

    ```
    $ cd scenarios/nomad-consul-quickstart
    $ shikari create --name demo --servers 3 --clients 3 --template shikari.yaml
    ```

    The above example command will create 3 servers and 3 clients using the local `shikari.yaml` lima template.

3. You can interact with the Consul and Nomad cluster from the host (if you have the binaries locally) as Lima will automatically port-forward Consul and Nomad ports to the host.

4. You can exec into the servers using the `limactl shell <vm-name>` command.