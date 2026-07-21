#!/usr/bin/env bash
set -e

# Default region
REGION="us-east-1"

# Print helper
function title_name {
  echo ""
  echo "------------------------------------------------------------"
  echo "--- $1"
  echo "------------------------------------------------------------"
}

title_name "Init resources on LocalStack"

# ============================
# 1. Queues generator SQS
# ============================

QUEUES=(
  "my-queue"
  "my-dlq"
  "auditing-queue"
  "acl-queue"
)

title_name "Generate queues SQS"

for QUEUE in "${QUEUES[@]}"; do
  echo "   - Generating queue: $QUEUE"
  awslocal sqs create-queue \
    --queue-name "$QUEUE" \
    --attributes '{"VisibilityTimeout":"30"}' \
    >/dev/null
done

# ============================
# 2. Topic generator SNS
# ============================

TOPICS=(
  "my-topic"
)

title_name "Topic generator SNS"

for TOPIC in "${TOPICS[@]}"; do
  echo "   - Topic generaion: $TOPIC"
  awslocal sns create-topic --name "$TOPIC" >/dev/null
done

# ============================
# 3. Subscriptions generator SNS -> SQS
# ============================

title_name "Subscriptions generator SNS -> SQS"

for TOPIC in "${TOPICS[@]}"; do
  TOPIC_ARN="arn:aws:sns:${REGION}:000000000000:${TOPIC}"

  for QUEUE in "${QUEUES[@]}"; do
    QUEUE_URL=$(awslocal sqs get-queue-url --queue-name "$QUEUE" --query 'QueueUrl' --output text)
    QUEUE_ARN="arn:aws:sqs:${REGION}:000000000000:${QUEUE}"

    echo "   - Subscriptions $QUEUE a $TOPIC"

    awslocal sns subscribe \
      --topic-arn "$TOPIC_ARN" \
      --protocol sqs \
      --notification-endpoint "$QUEUE_ARN" \
      >/dev/null
  done
done

# ============================
# 4. Validating created resources
# ============================

title_name "Validating created resources"

title_name "Queue SQS:"
awslocal sqs list-queues

title_name "Topic SNS:"
awslocal sns list-topics

title_name "LocalStack initialized successfully"
