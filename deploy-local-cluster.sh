#!/bin/bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx -n ingress-nginx --create-namespace ingress-nginx/ingress-nginx

helm repo add bitnami https://charts.bitnami.com/bitnami

kubectl create ns keycloak

helm install -n keycloak keycloak-db bitnami/postgresql-ha

sleep 30

kubectl apply -n keycloak -f keycloak.yaml

sleep 120

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout auth-tls.key -out auth-tls.crt -subj "/CN=auth.localtest.me/O=keycloak"
kubectl create secret -n keycloak tls auth-tls-secret --key auth-tls.key --cert auth-tls.crt
kubectl apply -n keycloak -f keycloak-ingress.yaml

sleep 30

kubectl get deployment -n keycloak
kubectl get service -n keycloak
kubectl get ingress -n keycloak

curl -k https://auth.localtest.me/auth/realms/master/protocol/openid-connect/certs

exit 0
