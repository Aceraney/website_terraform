resource "aws_s3_bucket" "web_bucket" {
  bucket = var.s3_name
}

resource "aws_s3_bucket_public_access_block" "static_site_bucket_public_access" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.web_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}





resource "aws_s3_bucket_policy" "cloudfront_s3_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

locals {
  content_type_map = {
    "js"   = "application/javascript"
    "html" = "text/html"
    "css"  = "text/css"
    "min"  = "application/javascript"
  }
}

resource "aws_s3_object" "provision_source_files" {
  bucket = aws_s3_bucket.web_bucket.id

  # webfiles/ is the Directory contains files to be uploaded to S3
  for_each = fileset("source/", "**/*.*")

  key          = each.value
  source       = "source/${each.value}"
  content_type = lookup(local.content_type_map, reverse(split(".", "${each.value}"))[0], each.value)
  etag         = filemd5("source/${each.value}")
}

