# modules/canary-infra/main.tf


resource "aws_s3_bucket" "canary_artifacts" {
  bucket_prefix = "canary-artifacts-"
  force_destroy = true 
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.canary_artifacts.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.canary_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. Shared Security Group
# This allows all canaries to talk to the VPC Endpoints and your Internal API.

resource "aws_security_group" "canary_sg" {
  name        = "canary-shared-sg"
  description = "Security group for Synthetics Canaries"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow outbound to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS from self"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }
  ingress{
    description = "Allow HTTP from self"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
  }
    ingress{
    description = "Allow from self"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self        = true
  }
}

# 3. VPC Endpoints 
# Creates a path for Canaries to reach S3 and CloudWatch without Internet.

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_route_table.selected.id]
}

resource "aws_vpc_endpoint" "monitoring" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.monitoring"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.canary_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.canary_sg.id]
  private_dns_enabled = true
}

# 4. Shared IAM Role
resource "aws_iam_role" "canary_role" {
  name = "canary-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "canary_policy" {
  name = "canary-policy"
  role = aws_iam_role.canary_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3Access"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:GetBucketLocation"]
        Resource = [aws_s3_bucket.canary_artifacts.arn, "${aws_s3_bucket.canary_artifacts.arn}/*"]
      },
      {
        Sid      = "CloudWatchMetrics"
        Effect   = "Allow"
        Action   = ["cloudwatch:PutMetricData"]
        Resource = "*"
        Condition = { StringEquals = { "cloudwatch:namespace" : "CloudWatchSynthetics" } }
      },
      {
        Sid      = "Logs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/cwsyn-*"
      },
      {
        Sid      = "VPCAccess"
        Effect   = "Allow"
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}
