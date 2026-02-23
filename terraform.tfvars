# terraform.tfvars

# Network Details (You MUST replace these with real IDs from your AWS Console)
vpc_id          = "vpc-1"
subnet_ids      = ["subnet-1", "subnet-2"]

# Target Details
api_hostname    = "" # Replace with your internal endpoint
api_path        = "/"

name            = "canary-test"
runtime_version = "syn-nodejs-puppeteer-13.1" 
frequency       = 5 # Run every 5 minutes

# SNS Topic (Optional - leave blank if you didn't configure the alarm)
alert_sns_topic = ""