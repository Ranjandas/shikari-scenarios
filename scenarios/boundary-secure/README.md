# Scenario: Boundary Secure

This scenario builds Boundary with TLS enabled. Specificy the number of `controllers` by setting `--servers/-s` and the number of `workers` by setting `--clients/-c` flags resepctively.

## Usage


### Build

The following steps will build a Boundary cluster.

```
shikari create -n <cluster_name> -s 3 -c 3 -i ~/.shikari/c-1.18-n-1.7-v-1.17-b-0.16/hashibox.qcow2
```

### Access

Export the Boundary environment variable using the following command

> This option will only be available in Shikari version >=0.4.1

```
shikari env -n <cluster_name> boundary --tls
```

Extract the Login information from the first server.

```
limactl shell boundary-srv-01 cat /etc/boundary.d/db_init.json | jq .auth_method
{
  "auth_method_id": "ampw_KEOB3T5XBL",
  "auth_method_name": "Generated global scope initial password auth method",
  "login_name": "admin",
  "password": "galNGsRubsGdgxKXTfOU",
  "scope_id": "global",
  "user_id": "u_8ftKbORVbU",
  "user_name": "admin"
}
```

Access the UI and login with the above credentials

```
open $BOUNDARY_ADDR
```

### Destroy

```
shikari destroy -n <cluster_name> -f
```