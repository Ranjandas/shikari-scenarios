# Shikari "nomad-exec2" scenario
This specific scenario is to run repro environments which utilize Nomad's 1.8.x new `exec2` driver, which is a  successor of previous `exec` driver.
The packer image has `nomad-driver-exec2` driver baked in already, and placed under `/opt/nomad/data/plugins` directory for Nomad's consumption.

## Pre-requisites:
- Nomad version 1.8.x or higher
- Lima
- Shikari

**NOTE** 📝: All the above except Shikari tool can be installed using Homebrew.

## Usage
Perform the following steps to execute `exec2` driver based jobs in Nomad

1. Execute the below command for shikari to spin up Nomad & Consul cluster
For example:

`$ shikari create -n dc1 -s 1 -c 1 -i <.qcow2_packer_image_location>`
```
where: 
-s : Nomad servers count
-c : Nomad clients count
-i : packer image location
```

2. Check if you can access the Nomad and Consul cluster by executing following commands:
```   
$ nomad server members
$ nomad node status
$ consul members
$ consul operator raft list-peers
```

3. Check the health of Nomad and consul using systemd logs, by exec'ing into VMs as below :
```
   shikari exec -n test -s  "sudo journalctl -u nomad"
   shikari exec -n test -s  "sudo journalctl -u consul"
```

4. Check the `exec2` friver presence in Nomad, using below command or from Nomad's UI:

```
$ nomad node status <node-id>
```

5. Run any job which utilises `exec2` driver, and check its function.


6. Destory the environment:

```
$ shikari stop -n <dc-name>
$ shikari destroy -n <dc-name> -f
```
