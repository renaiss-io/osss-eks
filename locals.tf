locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = "us-east-1"

  vpc_cidr = "10.123.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]

  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  intra_subnets   = ["10.123.5.0/24", "10.123.6.0/24"]
  db_subnets      = ["10.123.7.0/24", "10.123.8.0/24"]

  tags = merge(var.tags, {
    application       = "osss"
    terraform_managed = "true"
  })
}
