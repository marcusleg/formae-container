#!/bin/bash
set -euo pipefail

# Configuration
IMAGE_NAME="formae-agent"
IMAGE_TAG="latest"
AWS_REGION="$(aws configure get region)"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
SERVICE_NAME="formae-agent"
ECR_ACCESS_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/AppRunnerECRAccessRole"

# Check if service already exists
echo "==> Checking if App Runner service already exists..."
if aws apprunner list-services --region "${AWS_REGION}" --output json --no-cli-pager | grep -q "\"ServiceName\": \"${SERVICE_NAME}\""; then
    echo "==> App Runner service '${SERVICE_NAME}' already exists"
    echo "    Service name: ${SERVICE_NAME}"
    echo "    Region: ${AWS_REGION}"
    echo "    Skipping creation."
    exit 0
fi

echo "==> Creating App Runner service..."

# Create the App Runner service
aws apprunner create-service \
    --service-name "${SERVICE_NAME}" \
    --source-configuration "ImageRepository={ImageIdentifier=${ECR_REPOSITORY}:${IMAGE_TAG},ImageRepositoryType=ECR,ImageConfiguration={Port=49684}},AutoDeploymentsEnabled=true,AuthenticationConfiguration={AccessRoleArn=${ECR_ACCESS_ROLE_ARN}}" \
    --instance-configuration "Cpu=0.25 vCPU,Memory=0.5 GB" \
    --network-configuration "IngressConfiguration={IsPubliclyAccessible=false}" \
    --health-check-configuration "Protocol=HTTP,Path=/api/v1/health,Interval=10,Timeout=5,HealthyThreshold=1,UnhealthyThreshold=5" \
    --region "${AWS_REGION}" \
    --no-cli-pager

echo ""
echo "==> App Runner service creation initiated"
echo "    Service name: ${SERVICE_NAME}"
echo "    Region: ${AWS_REGION}"
