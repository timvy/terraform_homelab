terraform {
  backend "s3" {
    bucket = "tofu-backend"
    # Semaphore puts the state file in environment subfolders /env:/docker
    # key                         = "env:/docker/terraform.tfstate"
    key                         = "terraform.tfstate"
    region                      = "main" # this is required, but will be skipped!
    skip_credentials_validation = true   # this will skip AWS related validation
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
