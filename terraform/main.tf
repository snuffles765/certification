provider "aws" {
  region = "us-east-1"
}

variable "subnet_id" {
  default = "subnet-0ee089a33dba6fbc7"
}

variable "vpc_id" {
  default = "vpc-0b2ea4ec8edac3524"
}

variable "image_id" {
  default = "ami-04505e74c0741db8d"
}

resource "aws_s3_bucket" "bk" {
   bucket = "boxfuse.snuffles999"
}

resource "tls_private_key" "key" {
 algorithm = "RSA"
 rsa_bits  = 4096
}

resource "aws_key_pair" "aws_key" {
 key_name   = "aws-ssh-key"
 public_key = tls_private_key.key.public_key_openssh
}

resource "aws_security_group" "builder_group" {
  name        = "builder_group"
  vpc_id      = "${var.vpc_id}"


  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "production_group" {
  name        = "production_group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    description = "tomcat access"
    from_port   = 0
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "builder_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.aws_key.key_name
  vpc_security_group_ids = ["${aws_security_group.builder_group.id}"]
  subnet_id = "${var.subnet_id}"
}

resource "aws_instance" "production_instance" {
  ami = "${var.image_id}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.aws_key.key_name
  vpc_security_group_ids = ["${aws_security_group.production_group.id}"]
  subnet_id = "${var.subnet_id}"
}