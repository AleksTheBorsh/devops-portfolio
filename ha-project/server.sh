#!/bin/bash
apt-get update
apt-get install -y apache2
echo "<h1>Hello World from Yandex Cloud Auto Scaling Group!</h1>" > /var/www/html/index.html
systemctl enable apache2
systemctl start apache2
