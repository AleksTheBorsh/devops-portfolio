#!/bin/bash

# 1. Ставим зависимости и Docker
apt update && apt install -y curl wget apt-transport-https docker.io

# 2. Даем права пользователю ubuntu (чтобы ты мог управлять докером по SSH)
usermod -aG docker ubuntu
chmod 666 /var/run/docker.sock

sleep 30

# 3. Скачиваем и ставим Minikube (разделено на две строки!)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

sleep 15

# 4. Скачиваем и ставим kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install kubectl /usr/local/bin/kubectl

# 5.  Запускаем кластер от имени обычного юзера ubuntu
su - ubuntu -c "minikube start --driver=docker"

# 6. Создаем манифест Nginx (сразу в домашней папке пользователя ubuntu)
cat <<EOF > /home/ubuntu/nginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:   
  name: nginx-pod
spec:       
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
EOF

# 7. Применяем манифест (тоже от имени ubuntu)
su - ubuntu -c "kubectl apply -f /home/ubuntu/nginx-pod.yaml"