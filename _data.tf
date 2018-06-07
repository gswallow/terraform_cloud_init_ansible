provider "aws" {}
provider "tls" {}
provider "local" {}

data "template_file" "redhat" {
  template = "${file("${path.module}/files/redhat.txt")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${var.ENV}"
    HOSTGROUP= "${var.HOSTGROUP}"
    REPO = "${var.REPO}"
  }
}

data "template_file" "debian" {
  template = "${file("${path.module}/files/debian.txt")}"
  vars {
    ORG = "${var.ORG}"
    ENV = "${var.ENV}"
    HOSTGROUP = "${var.HOSTGROUP}"
    REPO = "${var.REPO}"
  }
}

output "redhat_user_data" {
  value = "${data.template_file.redhat.rendered}"
}

output "debian_user_data" {
  value = "${data.template_file.debian.rendered}"
}
