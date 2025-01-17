provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Recurso para criar ou puxar a imagem Docker
resource "docker_image" "app_image" {
  name = "inter171991/app:${var.image_tag}"
}

# Recurso para rodar o container
resource "docker_container" "app_container" {
  name  = "app-container"
  image = docker_image.app_image.latest
  ports {
    internal = 3000
    external = 3000
  }
}
