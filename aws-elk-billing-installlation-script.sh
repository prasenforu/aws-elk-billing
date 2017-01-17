#!/bin/bash

# This is "aws-elk-billing" Installation script
# This will do everything for you. Just edit few lines in # Important ## section
# Copy this script in Amazon linux (EC2) in home directory and run
# It will run other than EC2, just change username
# You can put in userdata as  well.

# Install docker, git and docker-compose

sudo yum update -y
sudo yum install docker git -y
sudo service docker start
sudo chkconfig docker on
sudo groupadd docker
sudo usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Download (clone) aws-elk-billing from github

mkdir -p /home/ec2-user/docker-aws-elk-billing/aws-elk-billing
git clone https://github.com/prasenforu/aws-elk-billing.git /home/ec2-user/docker-aws-elk-billing/aws-elk-billing/

# Important ##

# Change below input as per your configuration
# Sample S3_BUCKET_NAME, S3_REPORT_PATH & S3_REPORT_NAME provided

cat > /home/ec2-user/prod.env <<EOF
AWS_ACCESS_KEY_ID=<ACCESS KEY>
AWS_SECRET_ACCESS_KEY=<SECRET ACCESS KEY>
S3_BUCKET_NAME=tcsawscoe-adb-pkar
S3_REPORT_PATH=/aws_billing_report
S3_REPORT_NAME=aws_billing_report
EOF

chmod 600 /home/ec2-user/prod.env
mv /home/ec2-user/prod.env /home/ec2-user/docker-aws-elk-billing/aws-elk-billing/prod.env

# Starting docker container for aws-elk-billing, firstime it will take time.

sudo /usr/local/bin/docker-compose -f /home/ec2-user/docker-aws-elk-billing/aws-elk-billing/docker-compose.yml up -d

# Status of docker container for aws-elk-billing

sudo docker ps -a

# For restarting 
# sudo /usr/local/bin/docker-compose -f /home/ec2-user/docker-aws-elk-billing/aws-elk-billing/docker-compose.yml restart

