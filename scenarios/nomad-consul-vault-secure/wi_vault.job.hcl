
job "fetch-secret" {
  datacenters = ["murphy"]  # Update to match your your shikari cluster name

  group "example" {
    task "show-secret" {
      driver = "exec"

      config {
        command = "/bin/sh"
        args = ["-c", "cat ${NOMAD_SECRETS_DIR}/mysecret.json && sleep 3600"]
      }
### for WI use this
//      vault {}
### for legacy use this
       vault {
        policies = ["nomad-policy"]
      }
 ## v1
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