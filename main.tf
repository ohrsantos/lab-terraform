variable "region" {}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "/home/ubuntu/.aws/credentials"
  profile                 = "orlando.santos.auto2"
}


variable "am_images" {
  type = "map"

  default = {
    "sa-east-1" = "ami-0318cb6e2f90d688b"
    "us-west-1" = "ami-0ad16744583f21877"
  }
}

variable "am_key_pairs" {
  type = "map"

  default = {
    "sa-east-1" = "auto2-orlando-santos-keypair-sa-01"
    "us-east-1" = "auto2-orlando-santos-keypair-us-west-1-01"
    "us-west-1" = "auto2-orlando-santos-keypair-us-west-1-01"
  }
}
resource "aws_security_group" "ssh" {
    name = "allow_ssh"
    description = "Allow SSH connections"
        ingress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"] 
        }

        egress {
            from_port       = 0
            to_port         = 0
            protocol        = "-1"
            cidr_blocks     = ["0.0.0.0/0"]
        }
}

resource "aws_instance" "box-tst" { 
    ami = "${lookup(var.am_images, var.region)}"
    instance_type = "t2.micro"
    key_name      =  "${lookup(var.am_key_pairs, var.region)}"
    vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
    tags {
        Name = "Test Machine"
    }

    provisioner "remote-exec" {
        inline = [ 
            "hostname",
            "ip addr",
            "sudo apt-get update",
            "sudo apt-get install -y git htop",
            "cd ~",
            "git clone https://github.com/ohrsantos/ohrs-setup.git;cd ohrs-setup;./install.sh",
            "sudo bash -c echo 'ClientAliveInterval 120 >> /etc/ssh/sshd_config'",
            "sudo bash -c echo 'ClientAliveCountMax 720 >> /etc/ssh/sshd_config'"
       ]
    }   
        connection {
             type     = "ssh"
             user     = "ubuntu"
             private_key = "${file("/home/ubuntu/.aws/auto2-orlando-santos-keypair-sa-01.pem")}"
       }


} 
