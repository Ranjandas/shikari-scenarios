# Scenario: Nomad Consul Vault Quickstart
This scenario deploys Nomad, Consul and Vault with out any of the security configurations in place. This scenario is useful when you have to play around the features of Nomad (with or without Consul and Vault) and not worry about the security aspects.

## Prerequisites
The following tools are required to run these scenarios:

- Shikari and Lima with Socket_VMNet configured
- Requires a base VM image built using packer (../../packer/hashibox.pkr.hcl)
- Uses qemu driver (you can use vz by modifying vmType in the template)
- The vault config uses raft as storage.
- Requires Packer build using Consul, Nomad and Vault binaries, may need to update the [variables.pkvars.hcl] file incase there's a need to change versions than default.
- Update the vault.job.hcl to the correct shikari cluster name for datacenters block
- Setting a Vault token in the agent configuration is deprecated and will be removed in Nomad 1.9. Migrate your Vault configuration to use workload identity.

## Usage

### Create

Use the following command to launch the scenario using Shikari.

```
shikari create --name murphy \
                 --servers 3 \
                 --clients 3 \
                 --env CONSUL_LICENSE=$(cat /location/to/consul/license) \
                 --env NOMAD_LICENSE=$(cat /location/to/nomad/license) \
                 --env VAULT_LICENSE=$(cat /location/to/vault/license) \
                 --image ../../packer/.artifacts/<imagedir>/<image-file>.qcow2

```

### List

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

### Access

You can export the required environment variables to access both Nomad and Consul

```
$ eval $(shikari env -n murphy consul)

$ consul members
Node                Address              Status  Type    Build   Protocol  DC      Partition  Segment
lima-murphy-srv-01  192.168.105.13:8301  alive   server  1.18.2  2         murphy  default    <all>
lima-murphy-srv-02  192.168.105.12:8301  alive   server  1.18.2  2         murphy  default    <all>
lima-murphy-srv-03  192.168.105.11:8301  alive   server  1.18.2  2         murphy  default    <all>
lima-murphy-cli-01  192.168.105.10:8301  alive   client  1.18.2  2         murphy  default    <default>
lima-murphy-cli-02  192.168.105.14:8301  alive   client  1.18.2  2         murphy  default    <default>
lima-murphy-cli-03  192.168.105.9:8301   alive   client  1.18.2  2         murphy  default    <default>


$ eval $(shikari env -n murphy nomad)

$ nomad node status
ID        Node Pool  DC      Name                Class   Drain  Eligibility  Status
94665b9b  default    murphy  lima-murphy-cli-01  <none>  false  eligible     ready
83c90834  default    murphy  lima-murphy-cli-03  <none>  false  eligible     ready
65ecc0ed  default    murphy  lima-murphy-cli-02  <none>  false  eligible     ready

$ nomad server members
Name                       Address        Port  Status  Leader  Raft Version  Build  Datacenter  Region
lima-murphy-srv-01.global  192.168.105.4  4648  alive   true    3             1.8.1  murphy      global
lima-murphy-srv-02.global  192.168.105.5  4648  alive   false   3             1.8.1  murphy      global
lima-murphy-srv-03.global  192.168.105.3  4648  alive   false   3             1.8.1  murphy      global

$ eval $(shikari env -n murphy vault)
$ eval $(shikari exec -n murphy -i srv-01 env | grep VAULT_TOKEN)

$ vault status
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            1
Threshold               1
Version                 1.17.0
Build Date              2024-06-10T10:11:34Z
Storage Type            raft
Cluster Name            vault-cluster-bafbd334
Cluster ID              43dd9a3c-b196-d56b-2464-277aa8a79dfa
HA Enabled              true
HA Cluster              https://lima-murphy-srv-01.local:8201
HA Mode                 active
Active Since            2024-06-25T12:51:40.639035402+10:00
Raft Committed Index    65
Raft Applied Index      65

```

### Run a job to fetch secrets from vault

```
# Put secrets into vault kv
vault login $VAULT_TOKEN
vault secrets enable -path=secret kv
vault kv put secret/mysecret username="john" password="password123"
vault kv get secret/mysecret

# Run job to fetch those secrets 
nomad run vault.job.hcl
nomad job status fetch-secret

# Check logs to see if it returns the secrets from vault
nomad alloc logs <alloc-id>
```

### Destroy

```
$ shikari destroy -f -n murphy
```