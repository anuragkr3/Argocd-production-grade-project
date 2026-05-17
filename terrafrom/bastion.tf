# Security Group for Bastion
# - Allows SSH access to the bastion host. For production, replace 0.0.0.0/0 with
#   a limited CIDR (your office/home IP) or a VPN/security appliance.
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: Replace with your IP for better security
  }

  # Allow all outbound traffic from the bastion (typical for jump hosts)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}


# Bastion Host
# - Uses the community module to create a lightweight EC2 instance used as a jump host.
# - Key considerations: restrict SSH access (ingress above), ensure key_name exists,
#   and monitor/rotate access keys.
module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name          = "bastion-host"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "projects"         # SSH key pair name present in the AWS account
  monitoring    = true

  subnet_id              = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true  # Required to SSH directly from the internet

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Role        = "bastion"
  }
}