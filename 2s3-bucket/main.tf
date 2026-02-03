#create S3 bucket
resource "aws_s3_bucket" "staticweb_bucket" {
    bucket = var.tobi_file

    tags = {
        Name = var.tobi_file
    }
}

# Set ownership controls to ObjectWriter to ensure uploaded objects are owned by the bucket owner.
resource "aws_s3_bucket_ownership_controls" "staticweb_bucket_ownership" {
    bucket = aws_s3_bucket.staticweb_bucket.id

    rule {
        object_ownership = "ObjectWriter"
    }
}

# Configure S3 Public Access Block to prevent public ACLs but allow policy-based public access.
resource "aws_s3_bucket_public_access_block" "public_access_block" {
    bucket = aws_s3_bucket.staticweb_bucket.id

    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = false
    restrict_public_buckets = false
}

# Website configuration (index document is the uploaded object key)
resource "aws_s3_bucket_website_configuration" "staticweb_bucket_website" {
    bucket = aws_s3_bucket.staticweb_bucket.id

    index_document {
        suffix = "main.html"
    }

    depends_on = [
        aws_s3_bucket_public_access_block.public_access_block,
    ]
}

# Upload the site HTML file with embedded CSS and JavaScript
resource "aws_s3_object" "tobi_main_html" {
    bucket       = aws_s3_bucket.staticweb_bucket.id
    key          = "main.html"
    source       = "/workspaces/staticweb/1web-app/main.html"
    content_type = "text/html"
}

# Grant public read access via a bucket policy (policy-based access — works when block_public_policy = false).
resource "aws_s3_bucket_policy" "public_read" {
    bucket = aws_s3_bucket.staticweb_bucket.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Sid = "PublicReadGetObject",
                Effect = "Allow",
                Principal = "*",
                Action = ["s3:GetObject"],
                Resource = "${aws_s3_bucket.staticweb_bucket.arn}/*"
            }
        ]
    })
    depends_on = [
        aws_s3_bucket_public_access_block.public_access_block,
        aws_s3_object.tobi_main_html
    ]
}