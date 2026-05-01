variable "subscription_id" {
    type = string 
    description = "Azure subscription id"
}

variable "ENV" {
    type = string
    description = "The prefix which should be used for all resources in this environment
    default = "dev"
}

variable "LOCATION" {
    type = string 
    description = "Region which will be used by default for all resources"
    default = "ЗАПОВНИ"
}