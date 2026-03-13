# Берем за основу чистую Ubuntu
FROM ubuntu:latest

# Обновляем пакеты и ставим SSH-сервер, Python3 (для Ansible) и sudo
RUN apt-get update && apt-get install -y openssh-server python3 sudo

# Создаем папку, которая нужна службе SSH для нормальной работы
RUN mkdir /var/run/sshd

# Задаем пароль для пользователя root (сделаем пароль 'root' для простоты лаборатории)
RUN echo 'root:root' | chpasswd

# Разрешаем подключаться по SSH под рутом (по умолчанию Ubuntu это запрещает)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Говорим Докеру, что контейнер будет слушать стандартный порт SSH (22)
EXPOSE 22

# Запускаем службу SSH на переднем плане (-D), чтобы контейнер не выключился сразу после старта
CMD ["/usr/sbin/sshd", "-D"]
