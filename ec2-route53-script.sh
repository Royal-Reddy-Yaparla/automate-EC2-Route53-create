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

CREATE_EC2(){
    aws ec2 run-instances --image-id ami-0f3c7d07486cad139  --instance-type $2 \
--key-name nv_keypair --security-group-ids sg-0ad71420a0b2e2f78 --subnet-id subnet-08a8ac34932166a4b \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]"
}
INSTANCE=("mongodb" "mysql" "redis" "rabbiMQ" "web" "user" "catalogue" "payment" "dispatch" "shipping")

for i in "${INSTANCE[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ];then 
        CREATE_EC2 $i "t3.medium"
    else
        CREATE_EC2 $i "t2.micro"
    fi
done 

# aws ec2 describe-instances --instance-ids <EC2_ID> --query 'Reservations[0].Instances[0].{"PrivateIP":PrivateIpAddress,"PublicIP":PublicIpAddress}'
