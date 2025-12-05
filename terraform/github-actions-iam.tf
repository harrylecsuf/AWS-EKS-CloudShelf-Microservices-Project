# terraform/github-actions-iam.tf
# IAM Policy for existing GitHub Actions user

# Reference the existing IAM user (created manually)
data "aws_iam_user" "gh_actions" {
  user_name = "gh-actions-cloudshelf"
}

# IAM Policy for ECR Access
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
        Sid    = "ECRRepositoryAccess"
        Effect = "Allow"
        Action = [
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${local.project_name}/*"
      },
      {
        Sid    = "ECRImagePush"
        Effect = "Allow"
        Action = [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpart"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${local.project_name}/*"
      }
    ]
  })

  tags = local.common_tags
}

# Attach ECR Policy to GitHub Actions User
resource "aws_iam_user_policy_attachment" "gh_actions_ecr" {
  user       = data.aws_iam_user.gh_actions.user_name
  policy_arn = aws_iam_policy.gh_actions_ecr.arn
}

# IAM Policy for EKS Access
resource "aws_iam_policy" "gh_actions_eks" {
  name        = "${local.project_name}-gh-actions-eks-policy"
  description = "EKS permissions for GitHub Actions deployments"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSClusterAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

# Attach EKS Policy to GitHub Actions User
resource "aws_iam_user_policy_attachment" "gh_actions_eks" {
  user       = data.aws_iam_user.gh_actions.user_name
  policy_arn = aws_iam_policy.gh_actions_eks.arn
}