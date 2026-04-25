# ==========================================
# APPLICATION LOAD BALANCER (ALB)
# ==========================================

# 1. Бэкенд-группа (связывает балансировщик с нашей целевой группой ВМ)
resource "yandex_alb_backend_group" "ha_backend_group" {
  name = "ha-backend-group"

  http_backend {
    name             = "http-backend"
    weight           = 1
    port             = 80
    # Ссылаемся на целевую группу, которую автоматически создала наша Группа ВМ
    target_group_ids = [yandex_compute_instance_group.web_group.application_load_balancer.0.target_group_id]
    
    # Проверка здоровья (Health Check) - балансировщик будет пинговать серверы
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# 2. HTTP-роутер (правила маршрутизации)
resource "yandex_alb_http_router" "ha_router" {
  name = "ha-http-router"
}

resource "yandex_alb_virtual_host" "ha_virtual_host" {
  name           = "ha-virtual-host"
  http_router_id = yandex_alb_http_router.ha_router.id
  route {
    name = "ha-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.ha_backend_group.id
        timeout          = "60s"
      }
    }
  }
}

# 3. Сам Балансировщик
resource "yandex_alb_load_balancer" "ha_alb" {
  name       = "ha-load-balancer"
  network_id = yandex_vpc_network.ha_network.id

  # В каких сетях балансировщик должен ловить трафик
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public_a.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public_b.id
    }
    location {
      zone_id   = "ru-central1-d"
      subnet_id = yandex_vpc_subnet.public_d.id
    }
  }

  # Слушатель (Listener) - открываем 80 порт наружу
  listener {
    name = "ha-listener"
    endpoint {
      address {
        external_ipv4_address {} # Автоматически выдаст публичный IP
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.ha_router.id
      }
    }
  }
}

# 4. Вывод IP адреса (чтобы не искать его в консоли Яндекса)
output "load_balancer_public_ip" {
  description = "Публичный IP адрес нашего балансировщика"
  value       = yandex_alb_load_balancer.ha_alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}