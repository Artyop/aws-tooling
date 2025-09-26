#!/usr/bin/env bash

# quota code for VPCs per Region
VPC_QUOTA_CODE="L-F678F1CE"
SERVICE_CODE="vpc"

regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
total=0

echo "VPC usage by region:"
for region in $regions; do
  # Count VPCs
  count=$(aws ec2 describe-vpcs --region "$region" --query "length(Vpcs)" --output text 2>/dev/null || echo "0")

  # Get quota
  quota=$(aws service-quotas get-service-quota \
            --region "$region" \
            --service-code "$SERVICE_CODE" \
            --quota-code "$VPC_QUOTA_CODE" \
            --query "Quota.Value" \
            --output text 2>/dev/null || echo "N/A")

  # prettyfi quota number, makes it appears like "35" instead of "35.0"
  # numerical verification is needed because in some case 
  # no quota is set and N/A is retrieved
  if [[ "$quota" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    quota=$(echo "$quota" | awk '{printf "%d", $1}')
  fi

  printf "%-15s %s/%s\n" "$region" "$count" "$quota"
  
  # same reason for quota, let's be sure it's numerical before 
  if [[ "$count" =~ ^[0-9]+$ ]]; then
    total=$(( total + count ))
  fi
done

echo "Total VPCs across regions: $total"
