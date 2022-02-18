# Hybrid network with AWS Transit Gateway

## Setup
[This](https://github.com/Young-ook/terraform-aws-vpc/blob/main/examples/tgw/main.tf) is the example of terraform configuration file to create hybrid network using transit gateway. First we have to create two VPCs. One is an isolated vpc to place the vpc notebook instance, and the other is a control tower vpc to simulate a corporate data center. Check out and run terraform command.

Run terraform:
```
terraform init
terraform apply -target module.vpc -target module.corp
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file tc1.tfvars -target module.vpc -target module.corp
terraform apply -var-file tc1.tfvars -target module.vpc -target module.corp
```

Run terraform to create other resources:
```
terraform apply
```

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
