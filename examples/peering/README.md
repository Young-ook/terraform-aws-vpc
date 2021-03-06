# VPC Peering

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-vpc
cd terraform-aws-vpc/examples/peering
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-vpc/blob/main/examples/peering/main.tf) is the example of terraform configuration file to create vpc peering.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file tc1.tfvars
terraform apply -var-file tc1.tfvars
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
