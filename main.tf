provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "example.sh"
    content      = <<-EOF
      #!/bin/bash
      echo "foo" > ~ubuntu/hello-world.txt
    EOF
  }
}

resource "aws_instance" "app_server" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = ["default"]

  tags = {
    Name = "terraform-assignment"
  }

  user_data = data.cloudinit_config.user_data.rendered
}
