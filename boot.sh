#!/bin/sh

kubectl apply -f ./kubefiles/routes.configmap.yaml
kubectl apply -f ./kubefiles/policies.configmap.yaml
kubectl apply -f ./kubefiles/application.service.yaml
kubectl apply -f ./kubefiles/application.deployment.yaml
