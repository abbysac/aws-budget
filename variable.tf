variable "aws_profile" {
  description = "The AWS CLI profile to use for authentication"
  type        = string
  default     = "default" # Optional, replace "default" with your preferred profile if necessary
}

variable "linked_accounts" {
  type    = list(string)
  default = ["752338767189"]
}

variable "dkim_record_names" {
  type        = map(string)
  description = "Map of DKIM record names"
  default = {
    "record1" = "73peoyuibqxkou7l2fme3z6clovcgysy._domainkey.userportfolio.tk"
    "record2" = "4zkhh3q6fjjnhm6zkhmj2yo5qzfdl5t7._domainkey.userportfolio.tk"
    "record3" = "yzpdkfuvfb6ucjwqmktf5klebsj3eew6._domainkey.userportfolio.tk"
  }
}

variable "dkim_record_values" {
  type        = map(string)
  description = "Map of DKIM record values corresponding to each DKIM record name"
  default = {
    "record1" = "73peoyuibqxkou7l2fme3z6clovcgysy.dkim.amazonses.com"
    "record2" = "4zkhh3q6fjjnhm6zkhmj2yo5qzfdl5t7.dkim.amazonses.com"
    "record3" = "yzpdkfuvfb6ucjwqmktf5klebsj3eew6.dkim.amazonses.com"
  }
}
