# 1. Создаем общую VPC (виртуальную сеть)
resource "yandex_vpc_network" "ha_network" {
  name = "ha-network"
}

# 2. Создаем подсеть в зоне A
resource "yandex_vpc_subnet" "public_a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.ha_network.id
  v4_cidr_blocks = ["10.100.1.0/24"]
}

# 3. Создаем подсеть в зоне B
resource "yandex_vpc_subnet" "public_b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.ha_network.id
  v4_cidr_blocks = ["10.100.2.0/24"]
}

# 4. Создаем подсеть в зоне D (Яндекс недавно добавил зону D вместо старой C)
resource "yandex_vpc_subnet" "public_d" {
  name           = "public-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.ha_network.id
  v4_cidr_blocks = ["10.100.3.0/24"]
}
# 5. Создаем сервисный аккаунт для группы ВМ
resource "yandex_iam_service_account" "ig_sa" {
  name        = "ig-service-account"
  description = "Сервисный аккаунт для управления группой ВМ"
}

# 6. Даем ему роль "editor", чтобы он мог создавать серверы
resource "yandex_resourcemanager_folder_iam_member" "ig_sa_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}
# 7. Сама группа автомасштабирования
resource "yandex_compute_instance_group" "web_group" {
  name               = "ha-web-group"
  folder_id          = var.folder_id 
  service_account_id = yandex_iam_service_account.ig_sa.id

  # Тот самый "Launch Template" (какими будут наши серверы)
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd8snjpoq85qqv0mk9gi" # ID стандартной Ubuntu 22.04 в Яндексе
        size     = 10
      }
    }
    network_interface {
      network_id = yandex_vpc_network.ha_network.id
      subnet_ids = [
        yandex_vpc_subnet.public_a.id,
        yandex_vpc_subnet.public_b.id,
        yandex_vpc_subnet.public_d.id
      ]
      nat = true # Даем публичные IP, чтобы ставить Apache
    }
    metadata = {
      ssh-keys  = "ubuntu:${var.ssh_public_key}"
      # Подключаем наш bash-скрипт
      user-data = file("${path.module}/server.sh")
    }
  }

  # Правила Автоскейлинга (Auto Scaling Policies)
  scale_policy {
    fixed_scale {
      size = 2 # Для начала скажем Терраформу просто держать 2 сервера живыми
    }
  }

  # В каких зонах разрешено создавать серверы
  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
  }

  # Как обновлять серверы (чтобы не выключать все разом)
  deploy_policy {
    max_unavailable = 1
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }

  # Обязательно ждем, пока выдадутся права сервисному аккаунту!
  depends_on = [yandex_resourcemanager_folder_iam_member.ig_sa_editor]
}