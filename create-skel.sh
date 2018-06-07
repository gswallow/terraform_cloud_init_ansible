#!/bin/bash
if [ ! -f "_bootstrap.tf" ]; then
  cat > _bootstrap.tf << 'EOF'
variable "HOSTGROUP" {}
variable "REPO" {}

module "cloud_init_ansible" {
  source = "github.com/gswallow/terraform_cloud_init_ansible"
  ENV = "${var.ENV}"
  ORG = "${var.ORG}"
  HOSTGROUP = "${var.HOSTGROUP}"
  REPO = "${var.REPO}"

  CREATE_SSM_PARAMETERS = "false"
  CREATE_ANSIBLE_GIT_KEY = "false"
  ANSIBLE_GIT_KEY = "~/.ssh/ansible_rsa"
}
EOF
fi
