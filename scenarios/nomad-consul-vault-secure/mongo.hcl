job "mongo" {
  namespace = "default"

  group "db" {
    network {
      port "db" {
        static = 27017
      }
    }

    service {
      provider = "nomad"
      name     = "mongo"
      port     = "db"
    }

    task "mongo" {
      driver = "docker"

      config {
        image = "mongo:7"
        ports = ["db"]
      }

      vault {}

      template {
        data        = <<EOF
MONGO_INITDB_ROOT_USERNAME=root
MONGO_INITDB_ROOT_PASSWORD={{with secret "secret/data/default/mongo/config"}}{{.Data.root_password}}{{end}}
EOF
        destination = "secrets/env"
        env         = true
      }
    }
  }
}
