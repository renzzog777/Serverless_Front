variable "region" {
  description = "Region"
  type        = string
  default     = "us-west-2"
}

variable "account_id" {
  description = "ID"
  type        = number
  default     = 527007648235
}

variable "table-name" {
  description = "DynamoDB Table"
  type        = string
  default     = "myTable"
}
