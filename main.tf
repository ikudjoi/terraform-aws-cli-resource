variable "cmd" {
  description = "The command used to create the resource."
}

variable "role_arn" {
  description = "The role arn to assume in order to run the cli command."
}

variable "dependency_ids" {
  description = "IDs or ARNs of any resources that are a dependency of the resource created by this module."
  type        = list(string)
  default     = []
}

data "aws_caller_identity" "id" {
}

locals {
  assume_role_cmd = "source ${path.module}/assume_role.sh ${var.role_arn}"
}

resource "null_resource" "cli_resource" {
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash -c '${local.assume_role_cmd} && ${var.cmd}'"
  }

  # By depending on the null_resource, the cli resource effectively depends on the existance
  # of the resources identified by the ids provided via the dependency_ids list variable.
  depends_on = [null_resource.dependencies]
}

resource "null_resource" "dependencies" {
  triggers = {
    dependencies = join(",", var.dependency_ids)
  }
}

output "id" {
  description = "The ID of the null_resource used to provison the resource via cli. Useful for creating dependencies between cli resources"
  value       = null_resource.cli_resource.id
}

