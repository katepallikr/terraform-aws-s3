output "website_endpoint" {
  description = "URL endpoint of the website"
  value       = "http://${aws_s3_bucket_website_configuration.website_bucket.website_endpoint}"
}

output "bucket_name" {
  description = "Name of the S3 bucket hosting the website"
  value       = aws_s3_bucket.website_bucket.id
}

output "content_version" {
  description = "The content version deployed to the website"
  value       = random_integer.content_version.result
}