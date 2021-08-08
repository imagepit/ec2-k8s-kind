sudo echo net.bridge.bridge-nf-call-iptables = 1 >> /etc/sysctl.conf
sudo sysctl -p
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# docker
curl https://releases.rancher.com/install-docker/20.10.sh | sh
sudo usermod -g docker ubuntu
sudo /bin/systemctl restart docker.service

# docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chown ubuntu:ubuntu /usr/local/bin/docker-compose
sudo chmod 775 /usr/local/bin/docker-compose

# kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# stern
curl -Lo ./stern https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
chmod +x ./stern
sudo mv ./stern /usr/local/bin/stern

# kube-prompt
sudo apt install unzip
wget https://github.com/c-bata/kube-prompt/releases/download/v1.0.11/kube-prompt_v1.0.11_linux_amd64.zip
unzip kube-prompt_v1.0.11_linux_amd64.zip
chmod +x kube-prompt
sudo mv ./kube-prompt /usr/local/bin/kube-prompt
rm -f kube-prompt_v1.0.11_linux_amd64.zip

# nfs-server
sudo apt install -y nfs-kernel-server
sudo mkdir -p /var/nfs/exports
sudo chown nobody.nogroup /var/nfs/exports
echo "/var/nfs/exports *(rw,sync,fsid=0,crossmnt,no_subtree_check,insecure,all_squash)" >> /etc/exports
sudo exportfs -ra