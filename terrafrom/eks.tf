# Additional security group for EKS resources
# - This SG allows HTTPS traffic from the bastion host's SG (useful for admin/ssh proxying)

resource "aws_security_group" "add_sg_eks" {
  name   = "additional-eks-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    description = "HTTPS from bastion host"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # reference to bastion SG
  }

  # Allow all outbound (egress) — adjust if egress restrictions required
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "additional-eks-sg"
  }
}

# EKS cluster module
# - Uses the community 'terraform-aws-modules/eks/aws' module for best-practice defaults
# - endpoint_public_access=false restricts the control plane endpoint to private access
# - enable_cluster_creator_admin_permissions grants the caller admin RBAC on the cluster

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "terraform-cluster"
  kubernetes_version = "1.34"
  create_cloudwatch_log_group = false  # Disable default log group; manage logging separately for better control
  # Addons managed by the module; `before_compute` ensures ordering for some addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # Disable public access to the API server; use private networking or bastion/proxy
  endpoint_public_access = false

  # Adds the current caller as a cluster-admin in aws-auth (convenience for bootstrapping)
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  additional_security_group_ids = [aws_security_group.add_sg_eks.id]

  # Managed node group configuration
  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}