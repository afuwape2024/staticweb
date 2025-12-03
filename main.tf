#create S3 bucket
resource "aws_s3_bucket" "staticweb-tobi-bucket123456" {
    bucket = "staticweb-tobi-bucket123456"

    tags = {
        Name = "staticweb-tobi-bucket123456"
    }
}

# Set ownership controls to ObjectWriter to ensure uploaded objects are owned by the bucket owner.
resource "aws_s3_bucket_ownership_controls" "staticweb_bucket_ownership" {
    bucket = aws_s3_bucket.staticweb-tobi-bucket123456.id

    rule {
        object_ownership = "ObjectWriter"
    }
}

# Configure S3 Public Access Block to prevent public ACLs but allow policy-based public access.
resource "aws_s3_bucket_public_access_block" "public_access_block" {
    bucket = aws_s3_bucket.staticweb-tobi-bucket123456.id

    block_public_acls       = true
    ignore_public_acls      = true
    block_public_policy     = false
    restrict_public_buckets = false
}

# Website configuration (index document is the uploaded object key)
resource "aws_s3_bucket_website_configuration" "staticweb_bucket_website" {
    bucket = aws_s3_bucket.staticweb-tobi-bucket123456.id

    index_document {
        suffix = "main.html"
    }

    depends_on = [
        aws_s3_bucket_public_access_block.public_access_block,
    ]
}

# Upload the site HTML file. Do NOT set object ACLs — S3 ACLs are blocked by public access block.
resource "aws_s3_object" "tobi_main_html" {
    bucket       = aws_s3_bucket.staticweb-tobi-bucket123456.id
    key          = "main.html"
    source       = "/Users/oluwagbenroafuwape/Desktop/staticweb/main.html"
    content_type = "text/html"
}

# Grant public read access via a bucket policy (policy-based access — works when block_public_policy = false).
resource "aws_s3_bucket_policy" "public_read" {
    bucket = aws_s3_bucket.staticweb-tobi-bucket123456.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Sid = "PublicReadGetObject",
                Effect = "Allow",
                Principal = "*",
                Action = ["s3:GetObject"],
                Resource = "${aws_s3_bucket.staticweb-tobi-bucket123456.arn}/*"
            }
        ]
    })
    depends_on = [aws_s3_object.tobi_main_html]
}