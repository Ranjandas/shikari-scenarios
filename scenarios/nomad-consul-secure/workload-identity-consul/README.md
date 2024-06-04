## Prerequisites

The following tools are required to run these scenarios:

* HashiCorp [Packer](https://developer.hashicorp.com/packer) (if you are building custom images)
* CDRtools (if you are building custom images)
* [Lima](https://lima-vm.io/)
* [Shikari](https://github.com/ranjandas/shikari)
* [Workload_Identity_Doc](https://developer.hashicorp.com/nomad/docs/concepts/workload-identity)
* [Workload_Identity_Tutorial](https://developer.hashicorp.com/nomad/tutorials/integrate-consul/consul-acl)
* Supported from [Nomad Version](https://github.com/hashicorp/nomad/blob/main/CHANGELOG.md#170-december-07-2023)

> NOTE: all the above except shikari can be installed using Homebrew

## Usage

Perform the following steps to execute Workload-Identity jobs for consul

1. Execute the below command for shikari to spin up nomad and consul cluster

    ```
    Example:
    $ shikari create -n wi -s 1 -c 1 -t ../shikari-scenarios/scenarios/nomad-consul-secure/workload-identity-consul/hashibox.yaml -e CONSUL_LICENSE=$(cat ~/workspace/consul.hclic) -e NOMAD_LICENSE=$(cat ~/workspace/nomad.hclic)
    ```

2. Export the nomad and consul token as env var

    ```
    $ export CONSUL_HTTP_TOKEN=root
    $ export NOMAD_TOKEN=00000000-0000-0000-0000-000000000000
    ```

3. Check if you can access the nomad and consul cluster by executing following commands.

    ```
    $ nomad server members
    $ nomad node status
    $ consul members
    $ consul operator raft list-peers
    ```
4. Run a sample connect enabled job

    ```
    $ nomad job init -short -connect
    Example job file written to example.nomad.hcl
    $ nomad job run example.nomad.hcl
    ```

5. This should create SI tokens for the services and register services in consul

6. To destroy the setup execute the below commands

    ```
    $ shikari stop -n wi
    $ shikari destroy -n wi f
    unset CONSUL_HTTP_TOKEN
    unset NOMAD_TOKEN
    ```
