resource "kubernetes_namespace_v1" "namespace" {
  metadata { name = "osss" }
}

resource "helm_release" "osss" {
  name  = "osss"
  chart = "../osss"
  # chart            = "osss"
  # repository       = "https://renaiss-io.github.io/osss"
  # version          = "1.0.0"
  namespace        = kubernetes_namespace_v1.namespace.id
  create_namespace = false

  set {
    name  = "global.domain"
    value = data.aws_route53_zone.zone.name
  }

  values = [
    yamlencode({
      planka = {
        enabled = var.planka

        # Enable oidc in planka
        oidc = {
          enabled = true
        }
      }

      # Use NLB
      ingress-nginx = {
        controller = {
          service = {
            annotations = {
              "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
              "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = module.acm.acm_certificate_arn
            }
          }
        }
      }
    }),
    yamlencode(var.override_helm_vars)
  ]
}

# Manage records in route 53 public zone with external dns
resource "helm_release" "external-dns" {
  repository       = "https://charts.bitnami.com/bitnami"
  name             = "external-dns"
  chart            = "external-dns"
  namespace        = "kube-system"
  version          = "7.0.0"
  create_namespace = false

  values = [
    yamlencode({
      provider      = "aws"
      txtOwnerId    = var.hosted_zone_id
      domainFilters = [data.aws_route53_zone.zone.name]
      aws           = { zoneType = "public" }

      podSecurityContext = {
        fsGroup   = 65534
        runAsUser = 0
      }

      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.external_dns_irsa_role.iam_role_arn
        }
      }
  })]
}
