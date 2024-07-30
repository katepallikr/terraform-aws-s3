terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 5.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      environment = var.environment
      project     = var.project_name
      application = "Static Website"
      automation  = "terraform"
    }
  }
}

locals {
  bucket_prefix = "${var.name_prefix}-static-website-${lower(var.environment)}-"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket_prefix = local.bucket_prefix
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
  depends_on = [
    aws_s3_bucket_policy.website_bucket,
    aws_s3_bucket_public_access_block.website_bucket
  ]
}

resource "aws_s3_bucket_policy" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.allow_public_access.json
  depends_on = [aws_s3_bucket_public_access_block.website_bucket]
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    sid     = "PublicReadAccess"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_versioning" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_integer" "content_version" {
  min = 1
  max = 3
  keepers = {
    "bucket" = aws_s3_bucket.website_bucket.bucket
  }
}

resource "aws_s3_object" "index" {
  key    = "index.html"
  bucket = aws_s3_bucket.website_bucket.id
  content = templatefile("${path.module}/files/index.html", {
    content_version = random_integer.content_version.result
  })
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  key    = "error.html"
  bucket = aws_s3_bucket.website_bucket.id
  source = "${path.module}/files/error.html"
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  key    = "style.css"
  bucket = aws_s3_bucket.website_bucket.id
  source = "${path.module}/files/style.css"
  content_type = "text/css"
}
