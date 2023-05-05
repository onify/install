Install Onify Hub in Linux
==========================

Installing Onify Hub on a single Linux machine requires [Microk8s](https://microk8s.io/).

# Preparations

1. Install snapd (if not installed)
2. Install Microk8s
3. Install Onify 

# 1. Install snapd

```bash
sudo yum install snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
```

## 2. Install MicroK8s

```bash
sudo snap install microk8s --classic
```

## Configure MicroK8s

### Enable DNS

```bash
microk8s.enable dns
```

> If you have issues with MicroK8s default DNS (8.8.8.8 and 8.8.4.4), you need to change this, see [MicroK8s Add-on dns](https://microk8s.io/docs/addon-dns).

### Set kubetcl alias

```bash
snap alias microk8s.kubectl kubectl
```

# 3. Install Onify 

[Setup Onify using Kubernetes](https://github.com/onify/install/tree/default/hub/kubernetes)
