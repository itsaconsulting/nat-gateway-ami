packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

data "amazon-ami" "al2023-arm64-latest" {
  filters = {
    virtualization-type = "hvm"
    name                = "al2023-ami-2023*arm64"
    root-device-type    = "ebs"
  }
  owners      = ["amazon"]
  most_recent = true
}

source "amazon-ebs" "al2023" {
  ami_name      = "aws-nat-gateway-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region
  subnet_id     = var.subnet_id
  source_ami    = data.amazon-ami.al2023-arm64-latest.id
  ssh_username  = "ec2-user"
  ssh_interface = "session_manager"

  imds_support     = "v2.0"
  pause_before_ssm = "1m"

  # this policy copied from the AWS Managed Document for AmazonSSMManagedInstanceCore as of 9/26/2024
  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
      Effect = "Allow"
      Action = [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply"
      ]
      Resource = ["*"]
    }
  }
}

build {
  name = "aws-nat-gateway"
  sources = [
    "source.amazon-ebs.al2023"
  ]
  provisioner "file" {
    source      = "conf/custom-ip-forwarding.conf"
    destination = "/tmp/custom-ip-forwarding.conf"
  }
  provisioner "shell" {
    script = "scripts/bootstrap.sh"
  }
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}

