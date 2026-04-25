terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.118.0" # Можно указать актуальную версию
    }
  }

  # ⚠️ СЮДА ЖЕ ДОБАВЛЯЕМ НАШ БЭКЕНД ИЗ ПРОШЛОГО ПРОЕКТА
  # Обязательно поменяй строку key!
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "devops-portfolio-tf-state-22" # Впиши имя своего бакета
    region = "ru-central1"
    key    = "ha-project/terraform.tfstate" #новый путь 

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  # Настройки авторизации мы передаем через export YC_...
  # Поэтому сам блок оставляем почти пустым
  zone = "ru-central1-a"
}
