# Define where the frontend files live relative to this terraform folder
variable "frontend_path" {
  type        = string
  default     = "../../cloudresumechallenge-frontend"
  description = "The path to the frontend repository"
}

# Core HTML Files
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "index.html"
  source       = "${var.frontend_path}/index.html"
  content_type = "text/html"
  
  # Tracks changes to the file content
  etag         = filemd5("${var.frontend_path}/index.html")
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "style.css"
  source       = "${var.frontend_path}/style.css"
  content_type = "text/css"
  
  # Tracks changes to the file content
  etag         = filemd5("${var.frontend_path}/style.css")
}

# Recursive Folder Uploads (Assets)
resource "aws_s3_object" "assets_folder" {
  for_each     = fileset("${var.frontend_path}/assets", "**/*") 
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "assets/${each.key}"
  source       = "${var.frontend_path}/assets/${each.key}"
  etag         = filemd5("${var.frontend_path}/assets/${each.key}")
}

# Recursive Folder Uploads (Error Files)
resource "aws_s3_object" "error_folder" {
  for_each     = fileset("${var.frontend_path}/error_files", "**/*")  
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "error_files/${each.key}"
  source       = "${var.frontend_path}/error_files/${each.key}"
  etag         = filemd5("${var.frontend_path}/error_files/${each.key}")
}

# The Dynamic Config File (remains in the backend repo as a template)
resource "aws_s3_object" "config_js" {
  bucket       = aws_s3_bucket.terraformbucket.id
  key          = "config.js"
  
  # This uses the template file located in your backend/terraform folder
  content = templatefile("${path.module}/config.js.tftpl", {
    api_url = aws_apigatewayv2_api.counter_api.api_endpoint
  })
  
  content_type = "application/javascript"
}