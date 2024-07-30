# Terraform S3 Static Website Module

This Terraform module provisions an AWS S3 bucket configured for static website hosting.

## Features

- Creates an S3 bucket with website hosting enabled
- Configures bucket policy for public read access
- Enables versioning on the bucket
- Uploads a sample index.html, error.html, and style.css file
- Randomly selects a content version for demonstration purposes

## Usage

```hcl
module "static_website" {
  source      = "app.terraform.io/<YOUR_ORG>/s3-static-website/aws"
  version     = "1.0.0"
  
  name_prefix = "my-website"
  environment = "dev"
  aws_region  = "us-west-2"
}
