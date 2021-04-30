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
pei "kubectl get certs -n istio-system"
pei "kubectl get secrets -n istio-system istio-ca-intermediate -o jsonpath=\"{.data['tls\.crt']}\" | base64 -d > ca-cert.pem"
pei "kubectl get secrets -n istio-system istio-ca-intermediate -o jsonpath=\"{.data['tls\.key']}\" | base64 -d > ca-key.pem"
pei "kubectl get secrets -n istio-system istio-ca-intermediate -o jsonpath=\"{.data['ca\.crt']}\" | base64 -d > root-cert.pem"
pei "kubectl get secrets -n istio-system istio-ca-intermediate -o jsonpath=\"{.data['ca\.crt']}\" | base64 -d > cert-chain.pem"
pei "kubectl get secrets -n istio-system istio-ca-intermediate -o jsonpath=\"{.data['tls\.crt']}\" | base64 -d >> cert-chain.pem"
pei "kubectl create secret generic cacerts -n istio-system --from-file=ca-cert.pem --from-file=ca-key.pem --from-file=root-cert.pem --from-file=cert-chain.pem"
pei "istioctl install --set profile=demo -y"
pei "kubectl get cm istio-ca-root-cert -o  jsonpath=\"{.data['root-cert\.pem']}\" | openssl x509 --noout --text | head"
