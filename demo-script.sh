#!/bin/bash
. demo-magic.sh
clear
## Assumes TMC CLI is installed and ready to be configured
## Assumes you have two TMC accounts and have previously configured two contexts
## Assumes you have a cluster pre-configured with contur  kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
## Retrieve the external address of Contour’s Envoy load balancer:
## kubectl get -n projectcontour service envoy -o wide
## NAME    TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)
## envoy   LoadBalancer   10.100.161.248   a9be.eu-west-1.elb.amazonaws.com   80:30724/TCP,443:32097/TCP   4m58s   app=envoy
## How you configure DNS depends on your platform:
## On AWS, create a CNAME record that maps the host in your Ingress object to the ELB address.

export clustergroup1=mvp1
export clustergroup2=mvp2
export cluster1=dagobah
export cluster2=kind-harlem
export cluster3=brooklyn
export region=us-east-1
export keypair=tmc-key-pair
export version="1.18.6-2-amazon2"
export devuser=gborges@pivotal.io
export workspace1=faas-fe # if you change this, make sure to change the image-policy and network-policy files as well
export namespace1=frontend
export namespace2=backend
export upgradeversion="1.18.8-1-amazon2"



## DevOps Persona

#p "Let's take a tour around the TMC cli"
#p "Create a new cluster group and a new cluster"
#pe "tmc clustergroup create -n $clustergroup2"
#pe "tmc cluster create -n $cluster3 -r $region -g $clustergroup2 -s $keypair --version $version --dry-run > $cluster3.yaml"
#pe "bat $cluster3.yaml"
#wait
#clear

#pe "tmc cluster create -f $cluster3.yaml"
#wait
#clear

#p "Attaching an existent cluster"
#pe "tmc cluster attach -n $cluster2 -g $clustergroup2"
#pe "bat k8s-attach-manifest.yaml"
#pe "kubectx $cluster2"
#pe "kubectl cluster-info"
#pe "kubectl apply -f k8s-attach-manifest.yaml"
#wait
#clear

p "Create Workspaces and Namespaces"
pe "kubectx $cluster1"
pe "tmc workspace create -n $workspace1"
pe "tmc cluster namespace create -c $cluster1 -n $namespace1 -k $workspace1"
#pe "tmc cluster namespace create -c $cluster3 -n $namespace2 -k $workspace1"
wait
clear

p "Creating Image Registry Policy for the Workspaces"
pe "bat image-policy.yaml"
pe "tmc workspace image-policy create --workspace-name $workspace1 -f image-policy.yaml"
wait
clear

p "Applying Cluster Access Policy to Developers"
pe "tmc cluster iam add-binding $cluster1 -u $devuser -r cluster.view"
pe "tmc workspace iam add-binding $workspace1 -u gborges@pivotal.io -r workspace.admin"
wait
clear

# Developer Persona

p "Login with dev user"
pe "tmc login switch"
pe "tmc c list"
wait
clear

p "Try to deploy an image from docker.io"
pe "kubectl create deploy nginx --image=nginx -n $namespace1"
wait
clear

## Switch to the UI for applying the policies to both workspaces as workspace.edit

p "After applying the policies on the workspaces" # use the web interface to add workspace.edit role to the user
pe "kubectl create deploy nginx --image=nginx -n $namespace1" # maybe use the same application here?? and then chage the repo?
pe "kubectl get all -n $namespace1"
pe "kubectl describe deploy nginx -n $namespace1"
wait 
clear 

p "Deploy an application to the frontend namespace using gcr repo"
pe "bat petclinic.yaml"
pe "kubectl apply -f petclinic.yaml -n $namespace1"
pe "kubectl get ingress -n $namespace1"
wait
clear

#p "Checking internal communication"
#pe "kubectl run busybox --rm -it --image=gcr.io/fe-gborges/busybox -n backend -- /bin/sh"
#pe "curl "

#p "Checking internal communication"
#pe "kubectl run busybox --rm -it --image=datica/busybox-dig -- /bin/sh"

# Show how to run the inspection

# How to setup to setup AWS account

p "Let's run some Day-2 operations"
pe "tmc login switch"
wait 
clear

p "Run inspection on the cluster"
pe "tmc cluster inspection create -h"
pe "tmc cluster inspection create -c $cluster3 --inspection-type CIS"
wait
clear

p "Upgrading the cluster"
pe "tmc cluster upgrade $cluster3 $clusterversion"
wait
clear


# Cleanup 
#p "Cleaning up"
#pe "tmc cluster namespace delete -c harlem -n frontend -k faas-fe"
#pe "tmc cluster namespace delete -c harlem -n backend -k faas-fe"
#pe "tmc workspace delete -n faas-fe"
#pe "tmc workspace delete -n faas-be"
p "Cleaning up"
pe "tmc cluster namespace delete $namespace1 $cluster1"
pe "tmc workspace delete $workspace1"
pe "tmc cluster iam remove-binding $cluster1 -u $devuser -r cluster.view"
pe "tmc cluster delete $cluster3"
wait
clear

p "Detach $cluster2 on UI"


