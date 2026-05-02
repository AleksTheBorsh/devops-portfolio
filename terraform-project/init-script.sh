#!/bin/bash

# 1. Ставим зависимости и Docker
apt update && apt install -y curl wget apt-transport-https docker.io

# 2. Даем права пользователю aleks (чтобы ты мог управлять докером по SSH)
usermod -aG docker aleks
chmod 666 /var/run/docker.sock

# 3. Скачиваем и ставим Minikube (разделено на две строки!)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# 4. Скачиваем и ставим kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install kubectl /usr/local/bin/kubectl

# 5. МАГИЯ: Запускаем кластер от имени обычного юзера aleks
su - aleks -c "minikube start --driver=docker"

# 6. Создаем манифест Nginx (сразу в домашней папке пользователя aleks)
cat <<EOF > /home/aleks/nginx-pod.yaml
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

# 7. Применяем манифест (тоже от имени aleks)
su - aleks -c "kubectl apply -f /home/aleks/nginx-pod.yaml"