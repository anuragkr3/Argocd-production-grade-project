# Expose key values after terraform apply for easy reference
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}
output "bastion_public_ip" {
  description = "Public IP address of the bastion host (use to SSH)"
  value       = module.bastion_host.public_ip
}
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}