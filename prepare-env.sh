#!/bin/bash
. demo-magic.sh
clear

export clustergroup1=mvp1
export clustergroup2=mvp2
export cluster1=manhattan
export cluster2=brooklyn
export cluster3=harlem
export region=us-east-1
export keypair=tmc-key-pair
export version="1.16.2-3-amazon2"
export devuser=gborges@pivotal.io
export workspace1=faas-fe # if you change this, make sure to change the image-policy and network-policy files as well
export workspace2=faas-be # if you change this, make sure to change the image-policy and network-policy files as well
export namespace1=frontend
export namespace2=backend
export upgradeversion="1.16.7-1-amazon2"


#p "Run this script prior to the Demo"
#pe "tmc clustergroup create -n $clustergroup1"
#pe "tmc cluster create -n $cluster1 -r $region -g $clustergroup1 -s $keypair --dry-run > $cluster1.yaml"
#pe "tmc cluster create -f $cluster1.yaml"

#p "Accessing the cluster after making sure it was created"
#pe "tmc cluster provisionedcluster | grep $cluster1"
#pe "tmc cluster provisionedcluster kubeconfig get $cluster1 >> ~/.kube/config"
#pe "kubectx $cluster1"
#clear
#wait

#p "Create a Cluster Role Biding"
#pe "kubectl create clusterrolebinding privileged-cluster-role-binding \
#    --clusterrole=vmware-system-tmc-psp-privileged \
#    --group=system:authenticated"
#clear
#wait

#p "Deploy Contour"
#pe "kubectl apply -f https://projectcontour.io/quickstart/contour.yaml"
#p "Retrieve the external address of Contour’s Envoy load balancer"
#pe "kubectl get -n projectcontour service envoy -o wide"
#p "Create a CNAME record that maps the host in your Ingress object to the ELB address"
#clear
#wait

p "Create a local kind cluster"
pe "kind create cluster --name $cluster3"
pe "kubectx kind-$cluster3"
pe "kubectx $cluster1"
