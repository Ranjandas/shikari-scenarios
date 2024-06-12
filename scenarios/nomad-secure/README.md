# Shikari "Nomad-Secure" scenario with ACLs and TLS enabled
This specific scenario run Nomad(alongside Consul) with ACLs and TLS enabled.
Once the cluster is spun, TLS is enabled fully Except, the CLI access doesnt need to use CACERT and CLIENT_CERT/CLIENT_KEY to interact with Nomad and Consul, as `https` access has been set to false using ENV Variables.
The ACL tokens for Nomad and Consul have been hardcoded for ease of use for Demo and Repro reasons.

## Prerequisites
The following tools are required to run these scenarios:

- HashiCorp Packer (if you are building custom images)
- CDRtools (if you are building custom images)
- Lima
- Shikari
- Nomad and Consul ACL and TLS Documentation
- Supported Consul & Nomad Version
- Requires Packer build using enterprise binary for consul and nomad, update the [variables.pkvars.hcl] file.

**NOTE**📝: All the above except Shikari tool can be installed using Homebrew

## Usage
Perform the following steps to execute ACL/TLS equipped jobs for Consul and Nomad
1. Execute the below command for shikari to spin up nomad and consul cluster

>For Example: `$ shikari create -n dc1 -s 1 -c 1 -t ../shikari-scenarios/scenarios/nomad-secure/hashibox.yaml`
> <p>where: </p>
> <p>-s : Nomad servers count \n </p>
> <p>-c : Nomad clients count</p>
> <p>-t : template file to be used</p>


2. Export the below CONSUL and NOMAD ENV variables for ACLs and TLS, as shown below :
```
  export CONSUL_HTTP_TOKEN: root
  export NOMAD_TOKEN: 00000000-0000-0000-0000-000000000000
  export NOMAD_CERTS_HOME: /etc/nomad.d/certs
  export NOMAD_ADDR: https://localhost:4646
  export CONSUL_CERTS_HOME: /etc/consul.d/certs
  export CONSUL_HTTP_ADDR: https://localhost:8501
  export CONSUL_HTTP_SSL_VERIFY: false
  export NOMAD_SKIP_VERIFY: true
```
  
3. Check if you can access the Nomad and Consul cluster by executing following commands:
```
$ nomad server members
$ nomad node status
$ consul members
$ consul operator raft list-peers
```

4. Check the health of Nomad and consul using `systemd` logs as below :
```
   sudo journalctl -u nomad
   sudo journalctl -u consul
```
📝: The above commands output will reflect in logs that TLS/ACL is enabled, and will provide general logging. Please make sure we dont see any ACL/TLS related errors.

5. Run a sample `connect` enabled job:
```
$ nomad job init -short -connect
Example job file written to example.nomad.hcl

$ nomad job run example.nomad.hcl
📝 This should create SI tokens for the services and register services in consul
```
6. To destroy the setup execute the below commands
```
$ shikari stop -n dc1
$ shikari destroy -n  -f
unset CONSUL_HTTP_TOKEN: root
unset NOMAD_TOKEN: 00000000-0000-0000-0000-000000000000
unset NOMAD_CERTS_HOME: /etc/nomad.d/certs
unset NOMAD_ADDR: https://localhost:4646
unset CONSUL_CERTS_HOME: /etc/consul.d/certs
unset CONSUL_HTTP_ADDR: https://localhost:8501
unset CONSUL_HTTP_SSL_VERIFY: false
unset NOMAD_SKIP_VERIFY: true
```
