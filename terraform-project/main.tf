
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
    bucket = "devops-portfolio-tf-state-22"
    region = "ru-central1"
    key    = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true

    # Добавляем этот параметр, так как новые версии Terraform 
    # иногда требуют его для совместимости с Яндексом
    skip_s3_checksum = true
  }
}

# 2. Настройки подключения (используем наш сервисный аккаунт)
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a" # Зона доступности по умолчанию
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

module "my_compute_instance" {
  source = "./modules/compute" # Указываем путь к нашему модулю

  # Передаем переменные внутрь модуля:
  instance_name  = "server-production"
  folder_id      = var.folder_id
  subnet_id      = yandex_vpc_subnet.my_first_subnet.id # Берем ID свежесозданной подсети
  ssh_public_key = var.ssh_public_key
}

module "my_second_server" {
  source = "./modules/compute" # Обращаемся к тому же самому чертежу

  instance_name  = "server-testing"                     # Даем ДРУГОЕ имя
  folder_id      = var.folder_id                        # Каталог тот же
  subnet_id      = yandex_vpc_subnet.my_first_subnet.id # Сеть та же
  ssh_public_key = var.ssh_public_key


  #ждем когда поднимется первый сервер и затем поднимаем второй. 
  #Не обязательно если нет требования четкой последовательности
  depends_on = [module.my_compute_instance]
}

# Обновляем корневой output, чтобы он брал IP из модуля
output "external_ip_address" {
  value = module.my_compute_instance.instance_external_ip
}
output "second_server_ip" {
  value = module.my_second_server.instance_external_ip
}
resource "yandex_compute_disk" "imported_disk" {
  name = "manual-disk"
  type = "network-ssd"
  size = 10
  zone = "ru-central1-a"
}