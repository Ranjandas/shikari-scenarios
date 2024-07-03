# K3S Multinode

This scenario builds Kubernetes Cluster (using K3S). This scenario supports K3S HA. 

Specificy the size of the cluster by setting number of servers using the `--servers/-s` and `--clients/-c` flags.

When `-s` is > 1, HA will be configured. All the control-plane nodes gets the NoSchedule Taint, so to run workloads you would need atleast one client or use tolerations.

> NOTE: This scenario uses an Ubuntu image and doesn't need a custom image built using packer.

## Usage


### Build

The following steps will build a Vault cluster.

```
shikari create -n k3s -s 3 -c 1
```

### Access

Setup the KUBECONFIG file to access the cluster.

```
limactl cp k3s-srv-01:/etc/rancher/k3s/k3s.yaml $(limactl ls k3s-srv-01 --format="{{.Dir}}")/kubeconfig.yaml
export KUBECONFIG=$(limactl ls k3s-srv-01 --format="{{.Dir}}")/kubeconfig.yaml
```

> From Shikari v0.4.0, you can use the below command instead of manually copying and setting env variables.
>```
>$ eval $(shikari env -n k3s k3s)
>
>$ kubectl get nodes -o wide
>NAME              STATUS   ROLES                       AGE   VERSION        INTERNAL-IP       EXTERNAL-IP   OS-IMAGE           KERNEL-VERSION     CONTAINER-RUNTIME
>lima-k3s-cli-01   Ready    <none>                      11m   v1.29.6+k3s1   192.168.105.101   <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
>lima-k3s-srv-01   Ready    control-plane,etcd,master   11m   v1.29.6+k3s1   192.168.105.99    <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
>lima-k3s-srv-02   Ready    control-plane,etcd,master   11m   v1.29.6+k3s1   192.168.105.100   <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
>lima-k3s-srv-03   Ready    control-plane,etcd,master   11m   v1.29.6+k3s1   192.168.105.103   <none>        Ubuntu 24.04 LTS   6.8.0-31-generic   containerd://1.7.17-k3s1
>```

### Destroy

```
shikari destroy -n k3s -f
```