variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "logging-stack"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type; pick t3.micro for free-tier but may be underpowered."
}

variable "root_volume_size_gb" {
  type    = number
  default = 30
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key (will be uploaded as an AWS key pair)."
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  type        = string
  description = "Path to your private key (for output convenience)"
  default     = "~/.ssh/id_rsa"
}

variable "key_name" {
  type        = string
  description = "Name for the keypair in AWS"
  default     = "logging-stack-key"
}

variable "admin_ip_cidr" {
  type        = string
  description = "CIDR that can SSH to the instance (for safety)."
  default     = "0.0.0.0/0"
}

variable "allow_cidr" {
  type        = string
  description = "CIDR for allowing access to Kibana/Grafana from your IP (default open)."
  default     = "0.0.0.0/0"
}

variable "repo_url" {
  type        = string
  description = "Git URL of your repo that contains docker-compose.yml"
  default     = "https://github.com/mihikagaonkar/distributed-logging.git"
}
