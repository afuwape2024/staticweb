output "staticweb_bucket" {
    value =aws_s3_bucket.staticweb_bucket.id
}

output "staticweb_bucket_ownership" {
    value = aws_s3_bucket_ownership_controls.staticweb_bucket_ownership.id
}

output "public_access_block" {
    value = aws_s3_bucket_public_access_block.public_access_block.id
}

output "staticweb_bucket_website" {
    value = aws_s3_bucket_website_configuration.staticweb_bucket_website.id
}

output "public_read" {
    value = aws_s3_bucket_policy.public_read.id
}


