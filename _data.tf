provider "aws" {}
provider "local" {}

data "aws_caller_identity" "current" {}

data "template_file" "redhat" {
  template = "${file("${path.module}/files/redhat.txt")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${var.ENV}"
    HOSTGROUP= "${var.HOSTGROUP}"
    ANSIBLE_PLAYBOOKS_REPO = "${var.ANSIBLE_PLAYBOOKS_REPO}"
  }
}

data "template_file" "debian" {
  template = "${file("${path.module}/files/debian.txt")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${var.ENV}"
    HOSTGROUP = "${var.HOSTGROUP}"
    ANSIBLE_PLAYBOOKS_REPO = "${var.ANSIBLE_PLAYBOOKS_REPO}"
  }
}

output "redhat_user_data" {
  value = "${data.template_file.redhat.rendered}"
}

output "debian_user_data" {
  value = "${data.template_file.debian.rendered}"
}
