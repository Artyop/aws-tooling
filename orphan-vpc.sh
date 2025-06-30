#!/bin/bash

# This script assumes that you're already logged through aws cli 
# on the region you want to perform your search
OUTPUT_FILE="orphan-vpcs.txt"

> "$OUTPUT_FILE"

VPC_IDS=$(aws ec2 describe-vpcs --query 'Vpcs[*].{VpcId:VpcId}' --output text)

for VPC_ID in $VPC_IDS; do
    echo "Checking VPC: $VPC_ID"

    INTERFACES=$(aws ec2 describe-network-interfaces \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'NetworkInterfaces[*].NetworkInterfaceId' \
        --output text)

    if [[ -z "$INTERFACES" ]]; then
        echo "$VPC_ID" >> "$OUTPUT_FILE"
        echo "No ENI found. Added to $OUTPUT_FILE"
    fi
done
