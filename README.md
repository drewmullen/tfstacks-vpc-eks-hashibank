# tfstacks-vpc-eks-hashibank
This configuration deploys a stack with 5 components (VPC, EKS Fargate, K8s RBAC, K8s namespace, K8s addons, HashiBank WebApp) across 3 different deployments (development, production, disaster recovery) to demonstrate using deferred changes in a stack.

When planning this stack for the first time, only the VPC and EKS cluster will be planned and the remainder of the resources will be deferred until after the initial plan is applied.

## Pre-requisites

* You must enable AWS OIDC authentication for your stack following instructions at: https://developer.hashicorp.com/terraform/language/stacks/authenticate 

* Edit the deployments.tfdeploy.hcl file to fill in the following missing information:
  * INSERT YOUR AUDIENCE HERE: the audience you configured when setting up OIDC authentication
  * INSERT YOUR ARN HERE: the arn of the role you created in AWS
  * INSERT HCP TERRAFORM ORG NAME: your HCP Terraform org name
  * INSERT AWS ACCOUNT NUMBER: the account number of your AWS account
  * INSERT ROLE NAME TO BE CREATED: A name for a role that will be created in your AWS account
  * INSERT USERNAME TO BE CREATED: A username that will be created for your kubernetes cluster

## Things to try
* Connect your forked version of this repository to a new Stack in HCP Terraform.
* Instead of manually applying a deployment, try uncommenting the orchestration block at the bottom of the deployments.tfdeploy.hcl file to auto-approve the development deployment.
* After applying a deployment you can grab out the hostname from the deploy-hashibank kubernetes_ingress_v1.hashibank resource in state to check that your HashiBank WebApp is up and running.