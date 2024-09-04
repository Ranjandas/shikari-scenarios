# Customer Scenario
- Customer: ANZ
- Environment: NonProd
- Use Case: Vault Consul Storage

## Description:
This is lab for ANZ Bank Non prod environment involving Consul servers as KV backend for Vault servers. Consul clients are installed within Vault servers

## Usage

The following steps will build a Vault cluster with consul servers as storage backend.

```
- shikari create -n <cluster_name> <scenario-hashibox.yaml> -s 3 -c3 -e VAULT_LICENSE=$(cat <vault_license_file>) -e CONSUL_LICENSE=$(cat <vault_license_file>) -i <image>
```

### Access

Export the Vault environment variable using the following command

```
shikari env -n <cluster_name> vault --tls --insecure
```

Extract the Vault Token from the first server.

```
eval "export $(shikari exec -n <cluster_name> -i srv-01 env | grep TOKEN)"
```

### Environment:
- `lima-dc1-srv-xx` : Consul servers
- `lima-dc1-cli-xx` : Vault Servers with Consul clients

- snippet of example cluster below, where `lima-dc1-srv-xx` are consul backend servers, and `lima-dc1-cli-xx` are Vault servers, also running Consul client agents:

```
$ consul members -token ****

Node             Address              Status  Type    Build        Protocol  DC   Partition  Segment
lima-dc1-srv-01  192.168.105.7:8301   alive   server  1.15.14+ent  2         dc1  default    <all>
lima-dc1-srv-02  192.168.105.19:8301  alive   server  1.15.14+ent  2         dc1  default    <all>
lima-dc1-srv-03  192.168.105.18:8301  alive   server  1.15.14+ent  2         dc1  default    <all>
lima-dc1-cli-01  192.168.105.6:8301   alive   client  1.15.14+ent  2         dc1  default    <default>
lima-dc1-cli-02  192.168.105.16:8301  alive   client  1.15.14+ent  2         dc1  default    <default>
lima-dc1-cli-03  192.168.105.17:8301  alive   client  1.15.14+ent  2         dc1  default    <default>


$ vault status

Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.17.5+ent
Build Date      2024-08-30T15:55:00Z
Storage Type    consul
Cluster Name    vault-cluster-c98d1907
Cluster ID      b2749b42-6f52-f3f1-4089-cb50b5443da1
HA Enabled      true
HA Cluster      https://lima-dc1-cli-03.local:8201
HA Mode         active
Active Since    2024-09-04T23:10:15.302810929Z
Last WAL        54
```




### Destroy

```
shikari destroy -n <cluster_name> -f
```