# Deployment Flow

This application has been packaged as a dockerized and app, and will be deployed to an ubuntu server on AWS, The Deployment is done with High Availability in mind, and the whole flow is orchestrated using Terraform, to get this app up and running all you have to do is:

# Setup Instructions

- Install Terraform https://www.terraform.io/downloads.html
- cd deploy
- terraform init
- terraform plan
- terraform apply
