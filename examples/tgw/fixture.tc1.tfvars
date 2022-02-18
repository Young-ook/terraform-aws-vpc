aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "tgw-tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
client_instances = [
  {
    name          = "win"
    max_size      = 1
    instance_type = "t3.large"
    image_id      = "ami-04a18ed8b7b44aced" # Windows Server 2019 English Full Base (ap-northeast-2)
    key_name      = "your_keypair"
  },
]
