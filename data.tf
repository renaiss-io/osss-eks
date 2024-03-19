data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

data "aws_route53_zone" "zone" {
  zone_id = var.hosted_zone_id
}
