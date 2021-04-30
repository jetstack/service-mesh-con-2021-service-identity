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

pe "kubectl apply -f mtls.yaml"
pei "istioctl kube-inject -f sleep.yaml | kubectl apply -f -"
pei "istioctl kube-inject -f httpbin.yaml | kubectl apply -f -"
pe "kubectl get pods"
pei "kubectl exec "$(kubectl get pod -l app=sleep  -o jsonpath={.items..metadata.name})" -c istio-proxy -- openssl s_client -showcerts -connect httpbin:8000 &> httpbin-proxy-cert.txt"
pei "sed -n '/-----BEGIN CERTIFICATE-----/{:start /-----END CERTIFICATE-----/!{N;b start};/.*/p}' httpbin-proxy-cert.txt > certs.pem"
pei "cat certs.pem  | openssl x509 --noout --text | grep Data -A 5"
pei "cat certs.pem  | openssl x509 --noout --text | grep Alternative -A 1"
pe ""
