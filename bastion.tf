# Bastion Host
# TODO ideally in ASG
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

module "bastion_sg" {
  source      = "modules/sg"
  name        = "${var.app_name}-Bastion-SG"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description = "ssh"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      description = "all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

resource "aws_instance" "bastion" {
  ami                             = "${data.aws_ami.ubuntu.id}"
  instance_type                   = "${var.bastion_instance_class}"
  key_name                        = "${var.ssh_key_name}"
  security_groups                 = ["${module.bastion_sg.this_security_group_id}"]
  subnet_id                       = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address     = true
  # vpc_security_group_ids

  tags {
    Name = "Bastion"
  }
}
output "bastion_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
