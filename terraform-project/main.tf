
# 1. Описание провайдера (откуда качать плагин для Яндекса)
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    # Обновленный синтаксис с указанием протокола https
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket   = "devops-portfolio-tf-state-22"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    
    # Добавляем этот параметр, так как новые версии Terraform 
    # иногда требуют его для совместимости с Яндексом
    skip_s3_checksum            = true 
  }
}

# 2. Настройки подключения (используем наш сервисный аккаунт)
provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a" # Зона доступности по умолчанию
}
# Объявляем, что такие переменные существуют
variable "cloud_id" { type = string }
variable "folder_id" { type = string }
variable "ssh_public_key" { type = string }

# 3. Создаем простую виртуальную сеть (VPC)
resource "yandex_vpc_network" "my_first_network" {
  name = "devops-network"
}

# 4. Создаем подсеть в этой сети
resource "yandex_vpc_subnet" "my_first_subnet" {
  name           = "devops-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my_first_network.id # Ссылка на сеть выше
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# 5. Выводим ID созданной сети в консоль после завершения
output "network_id" {
  value = yandex_vpc_network.my_first_network.id
}

# Запрашиваем у Яндекса ID самого свежего образа Ubuntu 22.04
data "yandex_compute_image" "ubuntu_2204" {
  family = "ubuntu-2204-lts"
}

# 6. Описываем саму виртуальную машину
resource "yandex_compute_instance" "vm-1" {
  name = "terraform-instance"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5 # Экономим: сервер будет использовать 5% мощности процессора
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id #Образ 
      size     = 10 # ГБ
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.my_first_subnet.id # Привязываем к нашей подсети
    nat       = true # Включаем публичный IP, чтобы можно было зайти по SSH
  }

  metadata = {
    # Передаем публичный SSH-ключ, чтобы зайти на созданную машину
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# Добавим вывод публичного IP-адреса в консоль
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}