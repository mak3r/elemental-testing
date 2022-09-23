#!/bin/sh

K3S_CHANNEL=v1.23

mkdir k3s-config
mkdir ~/.kube

cat > k3s-config/config.yaml << EOF
write-kubeconfig: "/home/{USER}/.kube/config" 
write-kubeconfig-mode: "0600"
tls-san:
  - "{HOSTNAME}"
kubelet-arg: "config=/etc/rancher/k3s/kubelet.conf"
EOF
sed -i""  "s/{USER}/$(whoami)/" k3s-config/config.yaml
sed -i""  "s/{HOSTNAME}/$(hostname)/" k3s-config/config.yaml

cat > k3s-config/kubelet.conf << EOF
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
maxPods: 1000
EOF

sudo mkdir -p /etc/rancher/k3s
sudo cp k3s-config/config.yaml /etc/rancher/k3s/config.yaml
sudo cp k3s-config/kubelet.conf /etc/rancher/k3s/kubelet.conf
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=$K3S_CHANNEL sh -
#cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(whoami):$(id -gn) ~/.kube/config