variable "access_key" {
  description = "The access key for the IAM user"
}

variable "secret_key" {
  description = "The secret key for the IAM user"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "eu-west-1"
}
