
variable "config_file" {
  type        = string
  description = "The path of configuration YAML file."

  validation {
    condition     = fileexists(var.config_file)
    error_message = "File does not exist."
  }
}
