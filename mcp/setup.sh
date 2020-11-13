#!/usr/bin/env bash
set -o pipefail

entry(){
  echo ""
  echo "Multi-Cloud-Platform Setup"
  echo ""
  echo "Select Option: "

  select choice in "setup" "deploy" "get" "destroy" "help" "exit"; do
    case $choice in 
      setup )
        echo ""
        echo "Starting setup ..."
        echo ""
        runSetup
        ;;
      deploy )
        installDependencies
        runDeploy
        ;;
      get )
        installDependencies
        getState
        ;;
      destroy )
        installDependencies
        runDestroy
        ;;
      help) help;;
      exit) exit;;
      *) exit;;
    esac
  done
  exit
}

help() {
  echo "Usage: ${SCRIPT_NAME} <command> [options]"
  echo ""
  echo "Commands:"
  echo "  setup      Setup Terraform service deployment"
  echo "  get        Get Terraform state for current direectory"
  echo "  destroy    Destroy Terraform infrastructure"
  echo ""
  entry
}


installDependencies() {
  echo ""
  echo "Installing dependencies"

    OS="$(uname)"
    case ${OS} in
        'Linux')
            installLinuxDependencies
            ;;
        'Darwin')
            installDarwinDependencies
            ;;
        *)
            echo "Couldn't determine OS type."
            return
            ;;
    esac
}

installLinuxDependencies() {
  if  ! [ -x "$(command -v terraform)" ]
  then
    echo ""
    echo "Getting terraform ..."
    echo ""

    cd "${BIN}"
    TERRAFORM_URL_LIN=https://releases.hashicorp.com/terraform/0.12.0/terraform_0.12.0_linux_amd64.zip
    TERRAFORM_FILE_LIN="${TERRAFORM_URL_LIN##*/}"
    wget "${TERRAFORM_URL_LIN}"
    unzip -o "${TERRAFORM_FILE_LIN}"
    rm "${TERRAFORM_FILE_LIN}"
    cd "${SCRIPT_DIR}"

    echo ""
    echo "Terraform for $OS installed."
    echo ""
  else
    echo ""
    echo "All dependencies installed"
    echo ""
  fi
}

installDarwinDependencies(){
   # Install Terraform
    if  ! [ -x "$(command -v terraform)" ]
    then
        echo ""
        echo "Getting terraform ..."
        echo ""

        cd "${BIN}"
        TERRAFORM_URL_DAR=https://releases.hashicorp.com/terraform/0.12.0/terraform_0.12.0_linux_amd64.zip
        TERRAFORM_FILE_DAR="${TERRAFORM_URL_DAR##*/}"

        echo "URL: ${TERRAFORM_URL_DAR}"
        echo "File: ${TERRAFORM_FILE_DAR}"

        curl "${TERRAFORM_URL_DAR}" --output "${TERRAFORM_FILE_DAR}"
        unzip "${TERRAFORM_FILE_DAR}"
        rm "${TERRAFORM_FILE_DAR}"
        cd "${SCRIPT_DIR}"

        echo ""
        echo "Terraform for $OS installed."
        echo ""
    fi
}

runSetup(){
  echo "terraform{" > main.tf
  echo "Where would you like to deploy terraform to?"
  select choice in "gcs" "s3" "http" "kubernetes" "local"; do
    case $choice in
      gcs )
        gcsBackend
        ;;
      s3 )
        s3Backend
        ;;
      http )
        httpBackend
        ;;
      kubernetes )
        kubernetesBackend
        ;;
      local) ;;
      *);;
    esac
    break
  done
  echo "}" >> main.tf
  {
    echo "module mcp{"
    echo "  source = \"github.com/mesoform/terraform-infrastructure-modules//mcp\""
    echo "}"
  } >> main.tf

  cat main.tf
  echo ""
  read -r -p "Are you happy with this configuration? [y]es or [n]o: " accept
    case $accept in
      y )
        echo ""
        echo "Setup Complete"
        echo ""
        entry
        ;;
      n)
        echo ""
        echo "Configuration rejected"
        echo ""
        read -r -p "Restart setup? [y]es or [n]o: " restart
          case $restart in
          y )
            echo ""
            echo "Restarting setup ..."
            echo ""
            runSetup
            ;;
          *)
            echo ""
            echo "Deleting main.tf..."
            echo ""
            rm main.tf
            entry
            ;;
          esac
        ;;
      *)
    esac
  entry

}

gcsBackend(){
  echo "  backend \"gcs\"{" >> main.tf
  read -r -p "Enter bucket name: " bucket
  echo "    bucket = \"${bucket}\"" >> main.tf
  read -r -p "Enter gcs prefix: " prefix
  echo "    prefix = \"${prefix}\""  >> main.tf
  echo "  }" >> main.tf
}

s3Backend(){
  echo "  backend \"gcs\"{" >> main.tf
  read -r -p "Enter bucket name: " bucket
  echo "    bucket = \"${bucket}\"" >> main.tf
  read -r -p "Enter key: " key
  echo "    key = \"${key}\""  >> main.tf
  read -r -p "Enter region: " region
  echo "    folder = \"${region}\""  >> main.tf
  echo "  }" >> main.tf
}

httpBackend(){
  echo "  backend \"gcs\"{" >> main.tf
  read -r -p "Enter address: " address
  echo "    address = \"${address}\"" >> main.tf
  read -r -p "Enter lock address: " lock_address
  echo "    lock_address = \"${lock_address}\""  >> main.tf
  read -r -p "Enter unlock address: " unlock_address
  echo "    unlock_address = \"${unlock_address}\""  >> main.tf
  echo "  }" >> main.tf
}

kubernetesBackend(){
  echo "  backend \"gcs\"{" >> main.tf
  read -r -p "Enter secret suffix: " secret_suffix
  echo "    secret_suffix = \"${secret_suffix}\"" >> main.tf
  read -r -p "Load config file? (true or false): " config
  echo "    load_config_file = ${config}"  >> main.tf
  echo "  }" >> main.tf
}

runDeploy() {
  echo ""
  echo "Initialising terraform ..."
  echo ""
  terraform init
  echo ""
  echo "Creating Plan ..."
  echo ""
  terraform apply
  entry
}

runDestroy() {

  echo ""
  echo "Creating plan for destroying resources..."
  echo ""
  terraform destroy
  entry
}

getState(){
  echo ""
  echo "Getting terraform state"
  echo ""
  terraform refresh
  terraform show
}


# ####################################################
# Command selector
# ####################################################
OPTION=$1
case $OPTION in 
  "setup" | "-setup")
    runSetup
    ;;
  "deploy" | "-deploy")
    installDependencies
    runDeploy
    ;;
  "help" | "-help")
    help
    ;;
  "get" | "-get")
    getState
    ;;
  "destroy" | "-destroy")
    runDestroy
    ;;
  *)
    entry
    ;;
esac
