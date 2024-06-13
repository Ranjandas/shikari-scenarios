# Shikari "Nomad-Secure" scenario with ACLs and TLS enabled
This specific scenario run Nomad(alongside Consul) with ACLs and TLS enabled.
Once the cluster is spun, TLS is enabled fully Except, the CLI access doesnt need to use CACERT and CLIENT_CERT/CLIENT_KEY to interact with Nomad and Consul, as `HTTPS` endpoints are not configured to have client certificate authentication. The ACL tokens for Nomad and Consul have been hardcoded for ease of use for Demo and Repro reasons.

## Prerequisites
The following tools are required to run these scenarios:

- CDRtools (if you are building custom images)
- Lima
- Shikari
- Nomad and Consul ACL and TLS Documentation
- Supported Consul & Nomad Version
- Requires Packer build using Consul and Nomad binaries, may need to update the [variables.pkvars.hcl] file incase there's a need to change versions than default.

**NOTE**📝: All the above except Shikari tool can be installed using Homebrew

## Usage
Perform the following steps to execute ACL/TLS equipped jobs for Consul and Nomad
1. Execute the below command for shikari to spin up nomad and consul cluster

#### For example:  
- `$ shikari create -n dc1 -s 1 -c 1 -i <.qcow2_packer_image_location>`
```
where: 
-s : Nomad servers count
-c : Nomad clients count
-i : packer image location
```

2. Export the below CONSUL and NOMAD ENV variables for ACLs and TLS, as shown below :
```
  export CONSUL_HTTP_TOKEN: root
  export NOMAD_TOKEN: 00000000-0000-0000-0000-000000000000
  export NOMAD_ADDR: https://localhost:4646
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

4. Check the health of Nomad and consul using `systemd` logs, by exec'ing into VMs as below :
```
   shikari exec -n test -s  "sudo journalctl -u nomad"
   shikari exec -n test -s  "sudo journalctl -u consul"
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
unset NOMAD_ADDR: https://localhost:4646
unset CONSUL_HTTP_ADDR: https://localhost:8501
unset CONSUL_HTTP_SSL_VERIFY: false
unset NOMAD_SKIP_VERIFY: true
```
