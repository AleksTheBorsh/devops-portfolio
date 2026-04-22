variable "folder_id" {
  description = "ID каталога в Яндексе"
  type        = string
}

variable "subnet_id" {
  description = "ID подсети, куда подключить ВМ"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH ключ"
  type        = string
}
variable "instance_name" {
  description = "Имя виртуальной машины"
  type        = string
}