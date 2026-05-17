# Remote state backend configuration
# - Uses an S3 bucket to store the Terraform state file centrally.
# - `key` is the path within the bucket where the state is stored.
# - `encrypt` ensures server-side encryption is enabled for the object.
terraform {
  backend "s3" {
    bucket = "terraform-backend-microsvc"
    key    = "global/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
