module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name               = data.aws_route53_zone.zone.name
  zone_id                   = var.hosted_zone_id
  wait_for_validation       = true
  subject_alternative_names = ["*.${data.aws_route53_zone.zone.name}"]
}
