resource "aws_iam_policy" "policy" {
  name        = "budget_sns_ses_policy"
  path        = "/"
  description = "budget_sns_ses_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "SNSFullAccess",
        "Effect" : "Allow",
        "Action" : "sns:*",
        "Resource" : "*"
      },
      { "Sid" : "SESFullAccess"
        "Effect" : "Allow",
        "Action" : "ses:SendEmail",
        "Resource" : "*"
      },
      {
        "Sid" : "SMSAccessViaSNS",
        "Effect" : "Allow",
        "Action" : [
          "sms-voice:DescribeVerifiedDestinationNumbers",
          "sms-voice:CreateVerifiedDestinationNumber",
          "sms-voice:SendDestinationNumberVerificationCode",
          "sms-voice:SendTextMessage",
          "sms-voice:DeleteVerifiedDestinationNumber",
          "sms-voice:VerifyDestinationNumber",
          "sms-voice:DescribeAccountAttributes",
          "sms-voice:DescribeSpendLimits",
          "sms-voice:DescribePhoneNumbers",
          "sms-voice:SetTextMessageSpendLimitOverride",
          "sms-voice:DescribeOptedOutNumbers",
          "sms-voice:DeleteOptedOutNumber"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "aws:CalledViaLast" : [
              "sns.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_auto_attach" {
  name       = "budget_policy_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.policy.arn
}


resource "aws_iam_role" "lambda_role" {
  name = "lambda_budget_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "scheduler.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function.zip"
  function_name = "budget_update_alert"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/budget_update_alert"
}


# resource "aws_s3_bucket" "my_bucket" {
#   bucket = "my-import-bucket234"
# }