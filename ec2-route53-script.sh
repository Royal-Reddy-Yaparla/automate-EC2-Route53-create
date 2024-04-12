#!/bin/bash

###############################################
# Author: ROYAL REDDY
# Date: 11-04
# Version: V1
# Purpose: Create EC2 instances and Route53 DNS records
################################################


# aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --count 1 --instance-type t2.micro 
# --key-name nv_keypair --security-group-ids sg-0ad71420a0b2e2f78 --subnet-id subnet-08a8ac34932166a4b
# --tags Key=Name,Value=Script

INSTANCE="t2.micro"
PRIVATE_IP=""
DOMAIN_NAME="royalreddy.co.in"

CREATE_EC2(){
    aws ec2 run-instances --image-id ami-0f3c7d07486cad139  --instance-type $2 \
--key-name nv_keypair --security-group-ids sg-0ad71420a0b2e2f78 --subnet-id subnet-08a8ac34932166a4b \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" --query 'Instances[0].PrivateIpAddress' --output text
}
INSTANCE=("mongodb")

for i in "${INSTANCE[@]}"
do
    echo "Name: $i"
    if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ];then 
        INSTANCE="t3.medium"
    fi
    PRIVATE_IP=$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139  --instance-type $INSTANCE \
--key-name nv_keypair --security-group-ids sg-0ad71420a0b2e2f78 --subnet-id subnet-08a8ac34932166a4b \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" --query 'Instances[0].PrivateIpAddress' --output text
)
    aws route53 change-resource-record-sets \
  --hosted-zone-id Z07439021R4NQF6C9ULT9 \
  --change-batch "
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
    "Action"              : "CREATE"
    ,"ResourceRecordSet"  : {
        "Name"              :  "$i.$DOMAIN_NAME"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
             "Value"         : "$PRIVATE_IP"
        }]
      }
    }]
  }
  "
done 
