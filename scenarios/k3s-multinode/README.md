# K3S Multinode

This scenario builds Kubernetes Cluster (using K3S). This scenario supports K3S HA. 

Specificy the size of the cluster by setting number of servers using the `--servers/-s` and `--clients/-c` flags.

When `-s` is > 1, HA will be configured. All the control-plane nodes gets the NoSchedule Taint, so to run workloads you would need atleast one client or use tolerations.

> NOTE: This scenario by default uses the upstream Ubuntu image as it is not dependent on the components we bake using packer. However, you can use the baked images and avoid downloading Ubuntu images if you don't have them already cached.

## Usage


### Build

The following steps will build a Multinode Kubernetes cluster with 3 Control Plane nodes (with HA), and 1 worker node.

```
shikari create -n k3s -s 3 -c 1 -i ~/.shikari/c-1.19-n-1.8-v-1.17-b-0.16/hashibox.qcow2
```
> NOTE: You can skip the `-i` flag in the above command to use the upstream Ubuntu Images

### Access

Setup the KUBECONFIG file to access the cluster.

```
$ eval $(shikari env -n k3s k3s)

$ kubectl get nodes -o wide
NAME              STATUS   ROLES                       AGE   VERSION        INTERNAL-IP       EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION     CONTAINER-RUNTIME
lima-k3s-cli-01   Ready    <none>                      11m   v1.29.6+k3s1   192.168.105.101   <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
lima-k3s-srv-01   Ready    control-plane,etcd,master   11m   v1.29.6+k3s1   192.168.105.99    <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
lima-k3s-srv-02   Ready    control-plane,etcd,master   11m   v1.29.6+k3s1   192.168.105.100   <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
lima-k3s-srv-03   Ready    control-plane,etcd,master   11m   v1.29.6+k3s1   192.168.105.103   <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
```

### Destroy

```
shikari destroy -n k3s -f
```