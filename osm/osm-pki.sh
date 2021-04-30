#!/usr/bin/env bash

########################
# include the magic
########################
. ~/go/src/github.com/paxtonhare/demo-magic/demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=60

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#

# text color
DEMO_CMD_COLOR=$WHITE

# hide the evidence
clear


pe "kubectl get certs -n cert-manager"
pei "kubectl get certs -n osm-system"
pei "kubectl get secrets -n osm-system osm-ca-intermediate -o jsonpath=\"{.data['ca\.crt']}\" | base64 -d > ca.crt"
pei "kubectl create secret -n osm-system generic osm-ca-bundle --from-file ca.crt"
pei "osm install --certificate-manager=cert-manager --cert-manager-issuer-name=osm-intermediate-ca --enable-permissive-traffic-policy=false"
pe ""
pe "osm namespace add default"
pei "kubectl apply -f sleep.yaml"
pei "kubectl apply -f httpbin.yaml"
pe "kubectl get pods"
pei "kubectl exec "$(kubectl get pod -l app=sleep  -o jsonpath={.items..metadata.name})" -c envoy -- openssl s_client -showcerts -connect httpbin:8000 > httpbin-proxy-cert.txt"
pei "osm proxy get config_dump "$(kubectl get pod -l app=sleep  -o jsonpath={.items..metadata.name})" | jq -r '.configs[5].dynamic_active_secrets[0].secret.tls_certificate.certificate_chain.inline_bytes' | base64 -d | openssl x509 --noout --text | grep Data -A 5"
pei "osm proxy get config_dump "$(kubectl get pod -l app=sleep  -o jsonpath={.items..metadata.name})" | jq -r '.configs[5].dynamic_active_secrets[0].secret.tls_certificate.certificate_chain.inline_bytes' | base64 -d | openssl x509 --noout --text | grep Alternative -A 1"
pe ""
