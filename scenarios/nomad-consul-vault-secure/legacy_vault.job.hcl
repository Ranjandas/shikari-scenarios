job "fetch-secret" {
  datacenters = ["*"] 

  group "example" {
    task "show-secret" {
      driver = "exec"

      config {
        command = "/bin/sh"
        args = ["-c", "cat ${NOMAD_SECRETS_DIR}/mysecret.json && sleep 3600"]
      }

      vault {
        policies = ["nomad-policy"]
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/mysecret.json"
        data = <<EOF
          {{ with secret "secret/mysecret" }}
   USER = "{{ .Data.username }}"
   PASSWORD = "{{ .Data.password }}"
   {{ end }}
     EOF
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}