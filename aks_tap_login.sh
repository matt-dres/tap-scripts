#!/bin/bash

set -eo pipefail

source ${HOME}/.credentials/azure

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    echo "Missing input parameters for AKS resource group or name"
    exit 1
fi

az login --username "${STD_USERNAME}" --password "${STD_PASSWORD}"
az account set --subscription "$1"
az aks get-credentials --resource-group "$2"-rg --name "$2"
kubectl config get-contexts
kubectl config current-context
