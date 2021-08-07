# AWSのEC2でkind(k8s)環境構築

## ubuntuインストール

- AWSのEC2インスタンスをUbuntu18で作成する
- 推奨はメモリ8GB以上

## kubectlのインストール

```cmd
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

## kindのインストール

```cmd
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

## kindを使ってクラスタ作成

_cluster.yaml_

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "192.168.33.11"
  apiServerPort: 6443
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 8080
    hostPort: 8081
- role: worker
  extraPortMappings:
  - containerPort: 8080
    hostPort: 8080
  - containerPort: 30082
    hostPort: 30082
  - containerPort: 80
    hostPort: 80
  - containerPort: 443
    hostPort: 443
- role: worker
  extraPortMappings:
  - containerPort: 8080
    hostPort: 8082
```

```cmd
sudo kind create cluster --config=cluster.yaml --name=k8s
```

---

# docker registoryのインストール

- https://docs.docker.jp/compose/install.html
- https://qiita.com/wwbQzhMkhhgEmhU/items/a391ea346cc70a9a383b

## 証明書の作成

```cmd
mkdir -p registry/certs
cd registry/certs
export URLNAME=example.com
openssl req -x509 -days 36500 -newkey rsa:2048 -nodes \
-out ${URLNAME}.crt -keyout ${URLNAME}.key \
-subj "/C=JP/ST=Tokyo/L=null/O=null/OU=null/CN=${URLNAME}/"
cd ../../
```

## htpasswdファイルの作成

```
mkdir registry/auth
docker run --rm --entrypoint htpasswd httpd:2 -Bbn testuser testpassword > registry/auth/htpasswd
```

## docker-compose.yamlファイルの作成

```yaml
registry:
  restart: always
  image: registry:2
  ports:
    - 443:443
  environment:
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/example.com.crt
    REGISTRY_HTTP_TLS_KEY: /certs/example.com.key
    REGISTRY_AUTH: htpasswd
    REGISTRY_HTTP_ADDR: 0.0.0.0:443
    REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
  volumes:
    - ./registry/data:/var/lib/registry
    - ./registry/certs:/certs
    - ./registry/auth:/auth
```

## コマンドラインツール

### starn

#### インストール（Mac）

```cmd
brew install stern
```

#### インストール（Win）

```cmd
choco install -y stern
```

#### 使い方

```cmd
kubectl create deploy/nginx --image=nginx
kubectl scale deploy/nginx --replicas=3
```

## コマンド補完

```cmd
echo "source <(kubectl completion bash)" >> ~/.bashrc
```