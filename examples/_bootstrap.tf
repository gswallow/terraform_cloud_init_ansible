variable "HOSTGROUP" { default = "example" }
variable "REPO" { default = "git@github.com:example/repo.git" }

module "cloud_init_ansible" {
  source = "github.com/gswallow/terraform_cloud_init_ansible"
  ENV = "${var.ENV}"
  ORG = "${var.ORG}"
  HOSTGROUP = "${var.HOSTGROUP}"
  REPO = "${var.REPO}"

  CREATE_SSM_PARAMETERS = "true"
  CREATE_ANSIBLE_GIT_KEY = "true"
  ANSIBLE_GIT_KEY = "example_rsa"
}
