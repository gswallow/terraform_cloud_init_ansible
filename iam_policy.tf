# The policy statements get attached to the IAM role's
# policy, allowing instances that use sts:AssumeRole to
# use permission herein
resource "aws_iam_policy" "read_ansible_ssm_parameters" {
  name = "ReadAnsibleSSMParameters"
  count = "${var.CREATE_SSM_PARAMETERS == true ? 1 : 0 }"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "ssm:GetParameter" ],
      "Resource": [ "${aws_ssm_parameter.ansible_git.arn}" ]
    }
  ]
}
EOF
}
