#!/bin/bash
if [ ! -f "_bootstrap.tf" ]; then
  cat > _bootstrap.tf << 'EOF'
variable "HOSTGROUP" { default = "default" }
variable "ANSIBLE_PLAYBOOKS_REPO" {}

module "cloud_init_ansible" {
  source = "../../modules/cloud_init_ansible"
  ENV = "${var.ENV}"
  ORG = "${var.ORG}"
  HOSTGROUP = "${var.HOSTGROUP}"
  ANSIBLE_PLAYBOOKS_REPO = "${var.ANSIBLE_PLAYBOOKS_REPO}"

  STORE_ANSIBLE_GIT_KEY = "false"
  ANSIBLE_GIT_KEY = "~/.ssh/ansible_rsa"
  ENABLE_AWS_MANAGEMENT_AGENTS = "true"
  CREATE_AWS_MANAGEMENT_POLICY = "false"
}
EOF
fi
