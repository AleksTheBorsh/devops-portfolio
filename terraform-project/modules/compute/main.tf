data "yandex_compute_image" "ubuntu_2204" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm-1" {
  name        = "terraform-module-instance" # Изменили имя для наглядности
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id  = var.subnet_id
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}