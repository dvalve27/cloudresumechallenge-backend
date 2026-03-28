# Core HTML Files
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "index.html"
  source       = "../index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "style.css"
  source       = "../style.css"
  content_type = "text/css"
}

# Recursive Folder Uploads
resource "aws_s3_object" "assets_folder" {
  for_each = fileset("assets", "**/*") 
  bucket   = aws_s3_bucket.terraformbucket.id
  key      = "assets/${each.key}"
  source   = "assets/${each.key}" 
}

resource "aws_s3_object" "error_folder" {
  for_each = fileset("error_files", "**/*")  
  bucket   = aws_s3_bucket.terraformbucket.id
  key      = "error_files/${each.key}"
  source   = "error_files/${each.key}" 
}

resource "aws_s3_object" "config_js" {
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "config.js"
  
  # This tells Terraform to fill in the blank
  content = templatefile("${path.module}/config.js.tftpl", {
    api_url = aws_apigatewayv2_api.counter_api.api_endpoint
  })
  
  content_type = "application/javascript"
}