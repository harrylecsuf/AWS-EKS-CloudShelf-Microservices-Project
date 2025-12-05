# terraform/github-actions-iam.tf

# 1. Fetch the user
data "aws_iam_user" "gh_actions" {
  user_name = "gh-actions-cloudshelf"
}

# 2. Define the Policy
resource "aws_iam_policy" "gh_actions_ecr" {
  name        = "${local.project_name}-gh-actions-ecr-policy"
  description = "ECR permissions for GitHub Actions CI/CD"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryAdmin"
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload", # <--- Fixed Typo
          "ecr:CreateRepository"     # <--- Added Missing Permission
        ]
        # Ensure 'local.project_name' matches 'cloudshelf' or use 'cloudshelf' directly here
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${local.project_name}/*"
      }
    ]
  })

  tags = local.common_tags
}

# 3. Attach Policy
resource "aws_iam_user_policy_attachment" "gh_actions_ecr" {
  user       = data.aws_iam_user.gh_actions.user_name
  policy_arn = aws_iam_policy.gh_actions_ecr.arn
}

# ... (Keep the EKS section as is, it looked fine)