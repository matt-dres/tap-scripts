#!/bin/bash

source ${HOME}/.credentials/jenkins

JENKINS_CRUMB_JSON=$(curl -s --request GET \
  --url https://tap-test-bed.svc.eng.vmware.com/crumbIssuer/api/json \
  --user "${JENKINS_USERNAME}:${JENKINS_PASSWORD}")

CRUMB=$(echo ${JENKINS_CRUMB_JSON} | jq .crumb)

RESULT=$(curl -s -X POST -L \
  --url https://tap-test-bed.svc.eng.vmware.com/job/create-tap-testbed/buildWithParameters \
  --user "${JENKINS_USERNAME}:${TOKEN}" \
  --header "Jenkins-Crumb: $CRUMB" \
  --data cluster_name=${JENKINS_USERNAME} \
  --data owner_email_id=${JENKINS_EMAIL} \
  --data select_infra=AKS \
  --data install_tap=true \
  --data select_k8s_version=1.23.8 \
  --data select_tap_version=1.4.0-rc.22 \
  --data create_workload=true \
  --data lease_duration_in_days=3)

echo ${RESULT}