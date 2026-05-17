# Lookup the latest Ubuntu Jammy AMI published by Canonical
# - most_recent=true ensures the AMI is the newest matching the filters
# - Use owner ID for Canonical so the search is restricted to official images
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}