# 1. The base bucket (Keep it private)
resource "aws_s3_bucket" "terraformbucket" {
  bucket = "dannyresumebucket" 
}

# 2. Block all public access (Safety lock turned ON)
resource "aws_s3_bucket_public_access_block" "publiceaccess" {
  bucket = aws_s3_bucket.terraformbucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. CloudFront Origin Access Control (The "Digital Key")
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac-${aws_s3_bucket.terraformbucket.id}"
  description                       = "Grant CloudFront access to S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 4. The Secure Bucket Policy (Only CloudFront allowed)
resource "aws_s3_bucket_policy" "cloudfront_oac_access" {
  bucket = aws_s3_bucket.terraformbucket.id

  # Ensure the policy is only created AFTER the public access block is updated
  depends_on = [aws_s3_bucket_public_access_block.publiceaccess]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.terraformbucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

# Note: The aws_s3_bucket_website_configuration is no longer needed 
# when using CloudFront OAC with S3 as a standard origin.