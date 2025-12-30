#!/bin/bash
set -euo pipefail

# Configuration
IMAGE_NAME="formae-agent"
IMAGE_TAG="latest"
AWS_REGION="$(aws configure get region)"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPOSITORY="${ECR_REGISTRY}/${IMAGE_NAME}"

echo "==> Building container image..."
podman build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "==> Authenticating with ECR..."
aws ecr get-login-password --region "${AWS_REGION}" | \
    podman login --username AWS --password-stdin "${ECR_REGISTRY}"

echo "==> Ensuring ECR repository exists..."
if ! aws ecr describe-repositories --repository-names "${IMAGE_NAME}" --region "${AWS_REGION}" &>/dev/null; then
    echo "    Repository does not exist, creating..."
    aws ecr create-repository --repository-name "${IMAGE_NAME}" --region "${AWS_REGION} --no-cli-pager"
else
    echo "    Repository already exists"
fi

echo "==> Tagging image..."
podman tag "${IMAGE_NAME}:${IMAGE_TAG}" "${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "==> Pushing image to ECR..."
podman push "${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "==> Successfully pushed ${ECR_REPOSITORY}:${IMAGE_TAG}"
