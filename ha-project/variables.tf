variable "folder_id" {
  description = "ID каталога в Яндекс Облаке"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH ключ для ВМ"
  type        = string
  sensitive   = true # Скрывает значение из логов терминала (Best Practice!)
}
