
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.gitops_swaggereditor.name
        branch      = module.gitops_swaggereditor.branch
        namespace   = module.gitops_swaggereditor.namespace
        server_name = module.gitops_swaggereditor.server_name
        layer       = module.gitops_swaggereditor.layer
        layer_dir   = module.gitops_swaggereditor.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_swaggereditor.layer == "services" ? "2-services" : "3-applications")
        type        = module.gitops_swaggereditor.type
      })
    }
  }
}
