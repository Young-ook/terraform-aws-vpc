[[English](README.md)] [[한국어](README.ko.md)]

# VPC Bluprint
This is VPC Blueprint example helps you compose complete VPC, which is a isolated secure network on AWS. With this VPC Blueprint example, you describe the configuration for the desired state of your AWS global network, such as the Virtual Private Cloud (VPC), Transit Gateway (TGW), Peered VPCs, as an Infrastructure as Code (IaC) template/blueprint. Once a blueprint is configured, you can use it to stamp out consistent environments across multiple AWS accounts and Regions using your automation workflow tool, such as Jenkins, CodePipeline. VPC Blueprint also helps you implement relevant security controls needed to operate workloads from multiple teams in the pre-configured secure network.
Also, this VPC blueprint shows you how to establish a hybrid network ceonnection between an isolated network and a control plane network with TGW.

## Setup
## Download
Download this example on your workspace
```
git clone https://github.com/Young-ook/terraform-aws-vpc
cd terraform-aws-vpc/examples/blueprint
```

Then you are in **blueprint** directory under your current workspace. There is an exmaple that shows how to use terraform configurations to create and manage VPCs and VPC peerings on your AWS account. Please make sure that you have installed the terraform before moving to the next step.

First of all, you have to create two VPCs on your AWS account for hybrid connectivity simulation. One is an AWS VPC network and the other one is called 'corp' that simulates on-premises network.

Run terraform:
```
terraform init
terraform apply -target module.vpc -target module.corp
```
Also you can use the *-var-file* option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file fixture.tc1.tfvars
terraform apply -var-file fixture.tc1.tfvars
```

Then, you can then create a transit gateway (TGW) to connect the two VPCs. Once you're done applying terraforms, you can ping an EC2 instance on the 'corp' network to an EC2 instance running on the 'vpc' network with private IP.
```
terraform apply -target module.tgw -target module.vm
```

## Verify Transit Gateway (TGW) Connections
Move to the EC2 service page on the AWS Management Conosol and select Instances button on the left side menu. Find an instance that you launched. Select the instance and click *Connect* button on top of the window. After then you will see three tabs EC2 Instance Connect, Session Manager, SSH client. Select Session Manager tab and follow the instruction on the screen.

![aws-ec2-tgw-ping](images/aws-ec2-tgw-ping.png)

## Clean up
To destroy all infrastrcuture, run terraform:
```
terraform destroy
```

If you don't want to see a confirmation question, you can use quite option for terraform destroy command
```
terraform destroy --auto-approve
```

**[DON'T FORGET]** You have to use the *-var-file* option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file fixture.tc1.tfvars
```
