#!/bin/bash
set -e

ROLE=$1
SESSION_NAME=$2

# Ensure variables are set
if [ -z "$ROLE" ]; then
  echo "Error: ROLE (1st argument) is not provided."
  exit 1
fi

if [ -z "$SESSION_NAME" ]; then
  echo "Error: SESSION_NAME (2nd argument) is not provided."
  exit 1
fi

echo "Assuming role: $ROLE with session name: $SESSION_NAME"

# Unset AWS credentials stored in the environment
unset AWS_SESSION_TOKEN
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

# Assume the IAM role
cred=$(aws sts assume-role --role-arn "$ROLE" \
                           --role-session-name "$SESSION_NAME" \
                           --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
                           --output text) || {
    echo "Failed to assume role $ROLE"
    exit 2
}

# Parse credentials
ACCESS_KEY_ID=$(echo "$cred" | awk '{ print $1 }')
export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID

SECRET_ACCESS_KEY=$(echo "$cred" | awk '{ print $2 }')
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY

SESSION_TOKEN=$(echo "$cred" | awk '{ print $3 }')
export AWS_SESSION_TOKEN=$SESSION_TOKEN

# Output the assumed identity for verification
aws sts get-caller-identity
echo "Successfully assumed role: $ROLE"
