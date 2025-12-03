############################################################
# 1. Origin Access Identity (OAI) para que CloudFront acceda a S3
############################################################

resource "aws_cloudfront_origin_access_identity" "frontend_oai" {
  comment = "OAI for frontend S3 bucket"
}

############################################################
# 2. CloudFront Distribution para servir el FRONTEND desde S3
############################################################

resource "aws_cloudfront_distribution" "frontend_distribution" {
  enabled             = true
  default_root_object = "index.html"

  ############################################################
  # Origin: tu bucket S3 privado
  ############################################################
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "s3-frontend-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_oai.cloudfront_access_identity_path
    }
  }

  ############################################################
  # Comportamiento default (solo GET/HEAD)
  ############################################################
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-frontend-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ############################################################
  # No restricciones geográficas
  ############################################################
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  ############################################################
  # Certificado de CloudFront (HTTPS)
  ############################################################
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
