#!/bin/bash

set -euo pipefail

source ${HOME}/.git_repo_creds

# Parenthesis create an array that's split on spaces
OUTPUT=($(tanzu package installed list -n tap-install | grep -i "tap.tanzu.vmware.com"))
VERSION=${OUTPUT[2]}

kubectl get secret tap-values -n tap-install -o jsonpath="{.data['tap-values\.yaml']}" | base64 -d > ./test-bed-tap-values.yaml

cp ./test-bed-tap-values.yaml /tmp/tap-values.yaml

yq -i '.tap_gui.app_config.auth.environment = "development"' /tmp/tap-values.yaml
yq -i ".tap_gui.app_config.auth.providers.github.development.clientId = \"${CLIENTID}\"" /tmp/tap-values.yaml
yq -i ".tap_gui.app_config.auth.providers.github.development.clientSecret = \"${CLIENTSECRET}\"" /tmp/tap-values.yaml
yq -i '.tap_gui.app_config.integrations.github[0].host = "github.com"' /tmp/tap-values.yaml
yq -i '.tap_gui.app_config.auth.allowGuestAccess = true' /tmp/tap-values.yaml
# yq -i '.tap_gui.app_config.gitProviders.active = true' /tmp/tap-values.yaml

cat /tmp/tap-values.yaml

echo "---- Updating TAP ${VERSION} cluster with git info ---"

tanzu package installed update tap -p tap.tanzu.vmware.com -v "${VERSION}" -n tap-install -f /tmp/tap-values.yaml
