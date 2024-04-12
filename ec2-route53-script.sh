#!/bin/bash

#############################################################################
# Author: ROYAL REDDY
# Date: 11-04
# Version: V1
# Purpose: Automate the process of creating EC2 instances and Route53 records
#############################################################################

INSTANCE=""
PRIVATE_IP=""
DOMAIN_NAME="XXXXXXXX"
HOST_ID="XXXXXXXX"

INSTANCE=("mongodb" "mysql" "redis" "rabbiMQ" "web" "user" "catalogue" "payment" "dispatch" "shipping")

for i in "${INSTANCE[@]}"
do
    echo "Name: $i"
    if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ];then 
        INSTANCE="t3.medium"
    else
        INSTANCE="t2.micro"
    fi
    PRIVATE_IP=$(aws ec2 run-instances --image-id ami-XXXXXXXX  --instance-type $INSTANCE \
--key-name XXXXXXX --security-group-ids sg-XXXXXXXX --subnet-id subnet-XXXXXXXXX \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text
)
echo "$i:$PRIVATE_IP"
# create R53 record, need to make sure already created 
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOST_ID \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
    "Action"              : "CREATE"
    ,"ResourceRecordSet"  : {
        "Name"              :  "'$i'.'$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$PRIVATE_IP'"
        }]
      }
    }]
  }
  '
done 
