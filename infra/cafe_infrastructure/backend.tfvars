bucket         = "cafe-tf-state-bc05753e" #aws_s3_bucket output value goes here
key            = "terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "cafe-lock" #aws_dynamodb_table goes here
encrypt        = true