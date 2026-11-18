locals {
  tags = {
    creationMethod  = "terraform"
    creationProject = var.project_name
    terraformSetup  = "true"
  }
}

resource "aws_s3_bucket" "terraform_setup" {
  bucket        = "${var.project_name}-terraform-states-${data.aws_caller_identity.current.account_id}"
  tags          = local.tags
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_setup" {
  bucket = aws_s3_bucket.terraform_setup.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_setup" {
  bucket = aws_s3_bucket.terraform_setup.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_setup" {
  bucket                  = aws_s3_bucket.terraform_setup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_setup" {
  name         = "${var.project_name}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.tags
}

resource "local_file" "terraform_states_s3_bucket_name" {
  content  = aws_s3_bucket.terraform_setup.id
  filename = "terraform_states_s3_bucket_name.txt"
}
