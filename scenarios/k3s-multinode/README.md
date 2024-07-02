# K3S Multinode

This scenario builds Kubernetes Cluster (using K3S). This scenario supports K3S HA. 

Specificy the size of the cluster by setting number of servers using the `--servers/-s` and `--clients/-c` flags.

When `-s` is > 1, HA will be configured. All the control-plane nodes gets the NoSchedule Taint, so to run workloads you would need atleast one client or use tolerations.

> NOTE: This scenario uses an Ubuntu image and doesn't need a custom image built using packer.

## Usage


### Build

The following steps will build a Vault cluster.

```
shikari create -n k3s -s 3 -c 3
```

### Access

Setup the KUBECONFIG file to access the cluster.

```
limactl cp k3s-srv-01:/etc/rancher/k3s/k3s.yaml $(limactl ls k3s-srv-01 --format="{{.Dir}}")/kubeconfig.yaml

```

### Destroy

```
shikari destroy -n k3s -f
```