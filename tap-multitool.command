#!/bin/bash

##### DISCLAIMER #####
# This script is targeted towards Mac users. Zsh is targeted in this script

function _check_for_brew_install() {
    if ! command -v brew &> /dev/null; then
        read -p 'Unable to find brew. Install brew?[Y/n] ' INSTALL_BREW
        INSTALL_BREW=${INSTALL_BREW:-Y}
        if [ "${INSTALL_BREW}" != "Y" ]; then
            echo "Not installing brew. First install brew using `tap-multitool install-brew`, then try this command again."
            exit 0
        else 
            install_homebrew
        fi
    fi
}

function install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # NOTE: if running on Apple Silicon, this will work okay. If you're on Intel, the path will be the old version: /usr/local/bin/brew
    # https://adamtheautomator.com/install-homebrew/
    if [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
        echo "---- Adding homebrew to PATH ----"
        echo 'export PATH=$PATH:/opt/homebrew/bin' >> "${HOME}"/.zshrc
        source ${HOME}/.zshrc
    else
        echo '---- Brew is already in PATH ----'
    fi
}

function configure_aa_aks() {
    if ! command -v az &> /dev/null; then
        _check_for_brew_install
        brew update && brew install azure-cli
    fi
    echo "---- Logging into Azure ----"
    az login
    
    echo "---- Setting Azure Subscription ----"
    read -p 'Azure Subscription: ' AZ_SUBSCRIPTION
    if [ -z "${AZ_SUBSCRIPTION}" ]; then
        echo "Azure subscription not provided. Rerun the command and provide a subscription."
        exit 1
    fi
    az account set --subscription "${AZ_SUBSCRIPTION}"
    az aks get-credentials --resource-group acc-west-us --name acc-test
}

function install_mac_certs() {
    
    _check_for_brew_install

    # Check if yq is installed
    if ! command -v yq &> /dev/null; then
        brew install yq
    fi
    
    if ! command -v kubectl &> /dev/null; then
        echo "Unable to find kubectl. First install kubectl then rerun this command."
    fi

    echo "--- Fetching TAP Ingress Certificate ---"
    kubectl get secret -n cert-manager tap-ingress-selfsigned-root-ca -o yaml | yq '.data."ca.crt"' | base64 -d > ca.crt
    ### Use the openssl command below to verify the cert if issues arise
    # echo "--- Verifying Certificate ---"
    # openssl x509 -in ca.crt -text -noout
    echo "--- Adding to System.keychain (Mac password required) ---"
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
    echo "--- TAP Ingress Certificate added to System.keychain ---"

    echo "######################### NOTE ##########################"
    echo "#"
    echo "# For the certificate to be read by IDE extensions and your web browser, fully close and reopen each. Once re-opened, the certificate should be available to the applications."
    echo "#"
    echo "#########################################################"
}


case "$1" in
    install-brew)
        echo "---- Installing homebrew ----";
        install_homebrew;
        exit;
        ;;
    configure-azure)
        echo "---- Configuring Azure Connection to App Accelerator AKS Cluster ----"
        configure_aa_aks;
        exit;
        ;;
    install-certs)
        echo "---- Adding TAP GUI Certificates to Mac Keyring ----"
        install_mac_certs;
        exit;
        ;;
    * )
        echo "Unknown argument: $1"
        exit 1;
        ;;
esac