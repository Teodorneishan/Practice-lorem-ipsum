# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.0"
#     }
#   }

#   required_version = ">= 0.12.31"
# }

provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-static-website-lorem-ipsum"
  #  acl = "private"
  #   versioning {
  #   enabled = false
  # }
  #  website {
  #   index_document = "lorem.html"
  #   error_document = "error.html"
  # }
}

resource "aws_s3_bucket_versioning" "versioning_my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_website_configuration" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "lorem.html"
  }

  error_document {
    key = "error.html"
  }

  # routing_rule {
  #   condition {
  #     key_prefix_equals = "docs/"
  #   }
  #   redirect {
  #     replace_key_prefix_with = "documents/"
  #   }
  # }
}

#resource "aws_s3_bucket_ownership_controls" "my_bucket" {
 # bucket = aws_s3_bucket.my_bucket.id
#
#  rule {
 #   object_ownership = "BucketOwnerPreferred"
##  }
#}

# resource "aws_s3_bucket_acl" "my_bucket_acl" {
#   bucket = aws_s3_bucket.my_bucket.bucket
#   acl    = "private"
# }

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
# resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
#   bucket = aws_s3_bucket.my_bucket.bucket
#   # rule {
#   #   object_ownership = "BucketOwnerEnforced"
#   # }
#   ownership_controls {
#     rules = "BucketOwnerPreferred"
#   }
#   depends_on = [aws_s3_bucket_acl.my_bucket_acl]
# }


resource "aws_s3_bucket_public_access_block" "s3Public" {
  bucket = "${aws_s3_bucket.my_bucket.id}"
  block_public_acls = false
  block_public_policy = false
  restrict_public_buckets = false
  ignore_public_acls = false
}


# Create a bucket policy to enable bucket ownership controls
# resource "aws_s3_bucket_policy" "my_bucket_policy" {
#   bucket = aws_s3_bucket.my_bucket.bucket

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       # {
#       #   "Effect"    = "Allow"
#       #   "Principal": "*"
#       #   "Action"    = [
#       #     "s3:GetBucketAcl",
#       #     "s3:PutBucketAcl"
#       #   ]
#       # },
#       {
#         "Sid": "ModifyBucketPolicy",
#         "Principal": "*",
#         "Action": [
#           "s3:GetBucketPolicy",
#           "s3:PutBucketPolicy"
#         ],
#         "Effect": "Allow",
#         "Resource": "arn:aws:s3:::my-static-website-lorem-ipsum"
#       },
#       {
#         "Sid": "AccessS3Console",
#         "Principal": "*",
#         "Action": [
#           "s3:GetBucketLocation",
#           "s3:ListAllMyBuckets"
#         ],
#         "Effect": "Allow",
#         "Resource": "arn:aws:s3:::*"
#       }
#     ]
#   })
# }


resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.bucket

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ModifyBucketPolicy",
            "Principal": "*",
            "Effect": "Allow"
            "Action": [
              "s3:GetBucketPolicy",
              "s3:PutBucketPolicy"
            ],
            "Resource": [
                "arn:aws:s3:::my-static-website-lorem-ipsum",
                "arn:aws:s3:::my-static-website-lorem-ipsum/*"
            ]
       },
       {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
              "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::my-static-website-lorem-ipsum",
                "arn:aws:s3:::my-static-website-lorem-ipsum/*"
            ]
        }
    ]
  })
}




# resource "aws_s3_bucket_policy" "my_bucket_policy" {
#   bucket = aws_s3_bucket.my_bucket.bucket

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "AllowCloudFrontServicePrincipalReadOnly",
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "cloudfront.amazonaws.com"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::my-static-website-lorem-ipsum/*",
#             "Condition": {
#                 "StringEquals": {
#                     "AWS:SourceArn": "arn:aws:cloudfront::167730638447:distribution/"
#                 }
#             }
#         },
#         {
#             "Sid": "AllowLegacyOAIReadOnly",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E2RYP7GDAQ6Z9L"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::my-static-website-lorem-ipsum/*"
#         }
#     ]
#   })
# }




# resource "aws_s3_bucket_policy" "bucket_policy" {
#   bucket = aws_s3_bucket.my_bucket.bucket

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "AllowACLPolicies"
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = [
#           "s3:GetBucketAcl",
#           "s3:PutBucketAcl"
#         ]
#         Resource = [
#           aws_s3_bucket.my_bucket.arn,
#           "${aws_s3_bucket.my_bucket.arn}/*"
#         ]
#       },
#     ]
#   })
# }

locals {
  s3_origin_id = "my-static-website-lorem-ipsum"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "lorem.html"
  source = "lorem.html"
  #acl    = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "image" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "loremIpsum.jpg"
  source = "loremIpsum.jpg"
  #acl    = "public-read"
  content_type = "image/jpg"
}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "my-static-website-lorem-ipsum"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "my-cloudfront"
  default_root_object = "lorem.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.my_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

#resource "aws_cloudfront_distribution" "my_distribution" {
#  origin {
##    domain_name = aws_s3_bucket.my_bucket.bucket_regional_domain_name
#    origin_id   = "S3Origin"
  #}

  #enabled             = true
 # is_ipv6_enabled     = true
 # default_root_object = "lorem.html"

 # default_cache_behavior {
 #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
 #   cached_methods   = ["GET", "HEAD"]
  #  target_origin_id = "S3Origin"

  #  forwarded_values {
 #     query_string = false
 #     cookies {
 #       forward = "none"
 #     }
 #   }
#
 #   min_ttl                = 0
#    default_ttl            = 3600
 #   max_ttl                = 86400
#    compress               = true
 #   viewer_protocol_policy = "redirect-to-https"
#  }

 # viewer_certificate {
 #   acm_certificate_arn = "arn:aws:acm:eu-central-1:YOUR_ACCOUNT_ID:certificate/YOUR_CERTIFICATE_ID"
 #   ssl_support_method  = "sni-only"
 #}

#  restrictions {
 #   geo_restriction {
 #     restriction_type = "none"
 #   }
 # }
#}

#output "cloudfront_url" {
#  value = aws_cloudfront_distribution.my_distribution.domain_name
#}

# output "s3_bucket_url" {
#   value = aws_s3_bucket.my_bucket.bucket_regional_domain_name
# }



