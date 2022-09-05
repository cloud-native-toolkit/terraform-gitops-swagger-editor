locals {
  name          = "swaggereditor"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  #yaml_dir      = "${path.cwd}/.tmp/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  cluster_type = var.cluster_type == "kubernetes" ? "kubernetes" : "openshift"
  values_content = {
    swaggereditor = {
    clusterType = local.cluster_type
    ingressSubdomain = var.cluster_ingress_hostname
    "sso.enabled" = var.enable_sso
    tlsSecretName = var.tls_secret_name
    }
  }
  layer = "services"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource gitops_module module {
  depends_on = [null_resource.create_yaml]

  name = local.name
  namespace = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  branch = local.application_branch
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
