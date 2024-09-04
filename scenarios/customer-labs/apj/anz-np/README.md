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
- lima-dc1-srv-xx : Consul servers
- lima-dc1-cli-xx : Vault Servers with Consul clients

- snippet of example cluster below, where -dc1-srv-xx are consul backend servers, and dc1-cli-xx are Vault servers, also running Consul client agents:

```
[lima@lima-dc1-cli-03 ~]$ consul members -token root
Node             Address              Status  Type    Build        Protocol  DC   Partition  Segment
lima-dc1-srv-01  192.168.105.7:8301   alive   server  1.15.14+ent  2         dc1  default    <all>
lima-dc1-srv-02  192.168.105.19:8301  alive   server  1.15.14+ent  2         dc1  default    <all>
lima-dc1-srv-03  192.168.105.18:8301  alive   server  1.15.14+ent  2         dc1  default    <all>
lima-dc1-cli-01  192.168.105.6:8301   alive   client  1.15.14+ent  2         dc1  default    <default>
lima-dc1-cli-02  192.168.105.16:8301  alive   client  1.15.14+ent  2         dc1  default    <default>
lima-dc1-cli-03  192.168.105.17:8301  alive   client  1.15.14+ent  2         dc1  default    <default>
```

### Destroy

```
shikari destroy -n <cluster_name> -f
```