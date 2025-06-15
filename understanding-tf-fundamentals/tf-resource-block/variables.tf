variable "tags" {
  description = "Default tags for this project."
  type        = map(string)
  default = {
    Name        = "Terraform Mastery Project"
    Environment = "Dev"
  }
}
