# Scenario: Nomad Consul Quickstart

This scenario deploys both Nomad and Consul with ACLs and TLS in place. This scenario is useful when you have to play around the features of Nomad (with or without Consul).

This scenario also supports Consul Workload Identity and is enabled by default when the Nomad version is `>=1.8.0`. If you would like to disable Workload Identity configuration with versions `>=1.8.0`, please pass `-e NOMAD_CONSUL_WI=false` with `shikari create`.

## Prerequsites

This scenario has the following pre-requsites:

* Shikari and Lima with Socket_VMNet configured
* Requires a base VM image built using packer (`../../packer/hashibox.pkr.hcl`)
* Uses `qemu` driver (you can use `vz` by modifying `vmType` in the template)
* If running enterprise binaries, the Consul and Nomad licenses should be passed as environment variable (shown in the example below)

### Usage

#### Create

Use the following command to launch the scenario using Shikari.

```
$ shikari create --name murphy \
                 --servers 3 \
                 --clients 3 \
                 --env CONSUL_LICENSE=$(cat /location/to/consul/license) \
                 --env NOMAD_LICENSE=$(cat /location/to/nomad/license) \
                 --image ../../packer/.artifacts/<imagedir>/<image-file>.qcow2
```

#### List

List the VMs in the cluster

```
shikari list
CLUSTER       VM NAME             SATUS         DISK(GB)       MEMORY(GB)       CPUS
murphy        murphy-cli-01       Running       100            4                4
murphy        murphy-cli-02       Running       100            4                4
murphy        murphy-cli-03       Running       100            4                4
murphy        murphy-srv-01       Running       100            4                4
murphy        murphy-srv-02       Running       100            4                4
murphy        murphy-srv-03       Running       100            4                4
```

#### Access

You can export the required environment variables to access both Nomad and Consul

```
$ eval $(shikari env -n murphy -tai consul)
$ eval $(shikari env -n murphy -tai nomad)

$ consul members
Node                Address              Status  Type    Build   Protocol  DC      Partition  Segment
lima-murphy-srv-01  192.168.105.13:8301  alive   server  1.18.2  2         murphy  default    <all>
lima-murphy-srv-02  192.168.105.12:8301  alive   server  1.18.2  2         murphy  default    <all>
lima-murphy-srv-03  192.168.105.11:8301  alive   server  1.18.2  2         murphy  default    <all>
lima-murphy-cli-01  192.168.105.10:8301  alive   client  1.18.2  2         murphy  default    <default>
lima-murphy-cli-02  192.168.105.14:8301  alive   client  1.18.2  2         murphy  default    <default>
lima-murphy-cli-03  192.168.105.9:8301   alive   client  1.18.2  2         murphy  default    <default>

$ nomad node status
ID        Node Pool  DC      Name                Class   Drain  Eligibility  Status
94665b9b  default    murphy  lima-murphy-cli-01  <none>  false  eligible     ready
83c90834  default    murphy  lima-murphy-cli-03  <none>  false  eligible     ready
65ecc0ed  default    murphy  lima-murphy-cli-02  <none>  false  eligible     ready
```

#### Destroy

```
$ shikari destroy -f -n murphy
```