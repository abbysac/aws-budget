resource "aws_budgets_budget" "ec2" {
  name         = "budget-acc-monthly"
  budget_type  = "COST"
  limit_amount = "4"
  limit_unit   = "USD"
  #   time_period_end   = "2087-06-15_00:00"
  #   time_period_start = "2017-07-01_00:00"
  time_unit = "MONTHLY"

  # cost_filter {
  #   name = "Service"
  #   values = [
  #     "Amazon Elastic Compute Cloud - Compute",
  #   ]
  # }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = ["arn:aws:sns:us-east-1:224761220970:budget-updates-topic"]
    # subscriber_email_addresses = ["camleous@yahoo.com", "abbysac@gmail.com"]
    # }

  }
}



resource "aws_ses_domain_identity" "domain" {
  domain = "userportfolio.tk"
}


resource "aws_ses_domain_mail_from" "mail_from" {
  domain           = "userportfolio.tk"
  mail_from_domain = "bounce.${aws_ses_domain_identity.domain.domain}"
}
resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.domain.domain
}


resource "aws_route53_record" "dkim_records" {
  zone_id  = "Z01977742940BQL6YBRPT" # Replace with your Route53 Zone ID
  for_each = var.dkim_record_names
  name     = each.value
  type     = "CNAME"
  ttl      = 300
  #records  = [aws_ses_domain_dkim.dkim.dkim_tokens[count.index]]
  records = [var.dkim_record_values[each.key]]
}

# output "dkim_tokens" {
#   value = aws_ses_domain_dkim.dkim.dkim_tokens
# }
output "dkim_tokens" {
  description = "DKIM tokens (record names) created in Route 53"
  value = {
    for key, record in aws_route53_record.dkim_records :
    key => record.name
  }
}


resource "aws_budgets_budget" "link" {
  for_each     = toset(var.linked_accounts)
  name         = "budget-link-monthly"
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
  #   time_period_end   = "2087-06-15_00:00"
  #   time_period_start = "2017-07-01_00:00"
  time_unit = "MONTHLY"

  cost_filter {
    name = "LinkedAccount"
    values = [
      "752338767189"
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 60
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["camleous@yahoo.com", "abbysac@gmail.com"]
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }
}

# resource "aws_route53_record" "example_amazonses_verification_record" {
#   zone_id = "Z01977742940BQL6YBRPT"
#   name    = "_dmarc.userportfolio.tk"
#   type    = "TXT"
#   ttl     = "600"
#   # records = [aws_ses_domain_identity.domain.verification_token]
#   records = ["v=spf1 include:amazonses.com ~all"]
# }

# resource "aws_route53_record" "mail_from" {
#   zone_id = "Z01977742940BQL6YBRPT"
#   name    = "_dmarc.userportfolio.tk"
#   type    = "MX"
#   ttl     = "600"
#   # records = [aws_ses_domain_identity.domain.verification_token]
#   records = ["10 feedback-smtp.us-east-1.amazonses.com"]
# }

