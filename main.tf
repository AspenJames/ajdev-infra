terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.55.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
  backend "s3" {
    bucket = "ajdev-terraform-state"
    key    = "aspenjames/ajdev-infra"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}

################################################################################
# EC2 Module
################################################################################

module "ajdev-node" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.3.0"

  name = var.name

  ami                         = data.aws_ami.alpine_linux.id
  instance_type               = "t3.micro"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/files/user_data.tftpl", {
    compose_path    = "${path.module}/files/docker-compose.yml"
    env_file_path   = "${path.module}/files/env"
    rc_service_path = "${path.module}/files/rc_service"
  })
  user_data_replace_on_change = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
  key_name = aws_key_pair.this.key_name

  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 20
    },
  ]

  tags = var.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.name
  cidr = "10.99.0.0/18"

  azs            = ["${var.region}a"] # , "${var.region}b", "${var.region}c"]
  public_subnets = ["10.99.0.0/24"]   # , "10.99.1.0/24", "10.99.2.0/24"]
  # private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  # database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  tags = var.tags
}

data "aws_ami" "alpine_linux" {
  most_recent = true
  owners      = ["538276064493"]

  filter {
    name   = "name"
    values = ["alpine-*-x86_64-uefi-tiny-*"]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.name
  description = "HTTP, HTTPS, SSH, & ping"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["http-80-tcp", "https-443-tcp", "all-icmp", "ssh-tcp"]

  tags = var.tags
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "this" {
  private_key_pem = tls_private_key.this.private_key_pem
}

resource "aws_key_pair" "this" {
  public_key = data.tls_public_key.this.public_key_openssh
  tags       = var.tags
}
