
job "fetch-secret" {
  datacenters = ["*"] 

  group "example" {
    task "show-secret" {
      driver = "exec"

      config {
        command = "/bin/sh"
        args = ["-c", "cat ${NOMAD_SECRETS_DIR}/mysecret.json && sleep 3600"]
      }
      vault {}

      template {
        destination = "${NOMAD_SECRETS_DIR}/mysecret.json"
        data        = <<EOF
ROOT_USERNAME={{with secret "secret/data/default/fetch-secret/config"}}{{.Data.user}}{{end}}
ROOT_PASSWORD={{with secret "secret/data/default/fetch-secret/config"}}{{.Data.password}}{{end}}
EOF
      }
    }
  }
}