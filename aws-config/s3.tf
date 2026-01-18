resource "random_id" "config_bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "aws-config-logs-${random_id.config_bucket_suffix.hex}"

  force_destroy = true
}

# --- Public Access Block ---
resource "aws_s3_bucket_public_access_block" "config_bucket_block" {
  bucket = aws_s3_bucket.config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Encryption ---
resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket_encryption" {
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- Versioning ---

resource "aws_s3_bucket_versioning" "config_bucket_versioning" {
  bucket = aws_s3_bucket.config_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


data "aws_iam_policy_document" "config_bucket_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.config_bucket.arn,
      "${aws_s3_bucket.config_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id
  policy = data.aws_iam_policy_document.config_bucket_policy.json
}
