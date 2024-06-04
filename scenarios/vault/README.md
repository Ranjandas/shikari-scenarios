## Prerequisites

Procure Vault license from internal license portal and save to local machine.

## Usage

The following steps will build a Vault cluster running on Ubunutu Linux OS. 

The following scenarios have been pre-created for quickstart purposes.

1. 1 Node Vault Enterprise Integrated storage install
   `./shikari create -n dr-vault -s 1 -t templates/vault.yaml -e VAULT_LICENSE=$(cat <location of vault license on local file system>)`
2. 3 Node Vault Enterprise Integrated storage cluster install
   `./shikari create -n dr-vault -s 3 -t templates/vault.yaml -e VAULT_LICENSE=$(cat <location of vault license on local file system>)`
3. 5 Node Vault Enterprise Integrated storage cluster install
   `./shikari create -n dr-vault -s 5 -t templates/vault.yaml -e VAULT_LICENSE=$(cat <location of vault license on local file system>)`