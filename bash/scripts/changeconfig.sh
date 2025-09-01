#!/bin/bash

set -x

args=()
komponent=()


configuration_hash=$1
deployment_hash=$2
deployment_environment=$3

shift 3

for arg in "$@"; do
  args+=("-l")
  args+=("chart=$arg")
  pods+=($arg)
done

helmfile.exe -e $deployment_environment "${args[@]}" -f ./helmfile.yaml.gotmpl apply --set global.spring.cloud.config.label=$configuration_hash --set global.image.tag=git-$deployment_hash

kubectl scale deployment configuration-backend-deployment --replicas 0 
kubectl scale deployment configuration-backend-deployment --replicas 1

kubectl config set-context <context> --namespace=$deployment_environment

for i in "${pods[@]}"
do
   echo scaling down $i
   kubectl scale deployment "$i"-deployment --replicas 0 
done

for i in "${pods[@]}"
do
   echo scaling up $i
   kubectl scale deployment "$i"-deployment --replicas 1
done

