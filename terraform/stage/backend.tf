terraform {
  backend "gcs" {
    bucket = "en-tf-bucket-1"
    prefix = "terraform/state/stage"
  }
}
