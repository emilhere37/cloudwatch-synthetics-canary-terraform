# terraform.tfvars

# Network Details (You MUST replace these with real IDs from your AWS Console)
vpc_id     = "vpc-1" #update VPC Id here
subnet_ids = ["subnet-1", "subnet-2"] # update your subnets here

# Target Details
api_hostname = "URL" # Replace with your internal endpoint
api_path     = "/"

name            = "canary-test"
runtime_version = "syn-nodejs-puppeteer-14"
frequency       = 5 # Run every 5 minutes

# SNS Topic (Optional - leave blank if you didn't configure the alarm)
alert_sns_topic = ""