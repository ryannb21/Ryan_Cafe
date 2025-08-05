terraform {
  backend "s3" {
    #This configuration is meant to be provided via backend.tfvars
    #You will find the sample code in lines 1-6 of sample.tfvars.example
    #Copy and paste into your backend.tfvars file and populate your own values
    #Then run: terraform init -backend-config=backend.tfvars
  }
}