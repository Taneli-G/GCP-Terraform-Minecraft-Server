terraform  {
    backend "gcs" {
        bucket = "moose-hunters-mineservu-bucket-tfstate"
        prefix = "terraform/state"
    }
}