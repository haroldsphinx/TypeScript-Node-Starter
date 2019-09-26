#variable "aws_access_key" {
#  description = "AWS access key, must pass on command line using -var"
#}

#variable "aws_secret_key" {
#  description = "AWS secret access key, must pass on command line using -var"
#}

variable "aws_region" {
  description = "North Virginia"
  default     = "us-east-1"
}

variable "azs" {
  type    = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ec2_amis" {
  description = "Ubuntu Server 16.04 LTS (HVM)"
  type        = "map"

  default = {
    "us-east-1" = "ami-059eeca93cf09eebd"
    "us-east-2" = "ami-0782e9ee97725263d"
    "us-west-1" = "ami-0ad16744583f21877"
    "us-west-2" = "ami-0e32ec5bc225539f5"
  }
}

variable "key_pair_name" {
  description = "key pair name to attach to instance"
  default     = "paystack"
}
