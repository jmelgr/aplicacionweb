############################################################
# 1. Bucket S3 para el FRONTEND
############################################################

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "app-frontend-bucket-2025"
}

resource "aws_s3_bucket_public_access_block" "frontend_block" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

############################################################
# 2. Política para permitir que CloudFront lea el contenido
############################################################

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "AllowCloudFrontRead",
        Effect : "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.frontend_oai.iam_arn
        },
        Action : "s3:GetObject",
        Resource : "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}

############################################################
# 3. Subida automática de archivos del build (dist/)
############################################################

resource "aws_s3_object" "frontend_files" {
  for_each = fileset("../../frontend/dist", "**/*")

  bucket = aws_s3_bucket.frontend_bucket.bucket
  key    = each.value
  source = "../../frontend/dist/${each.value}"
  etag   = filemd5("../../frontend/dist/${each.value}")

  content_type = lookup(
    {
      "html" = "text/html"
      "js"   = "application/javascript"
      "css"  = "text/css"
      "svg"  = "image/svg+xml"
      "png"  = "image/png"
      "jpg"  = "image/jpeg"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )
}

