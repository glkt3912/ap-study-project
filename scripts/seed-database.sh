#!/bin/bash

# Database seeding script (past exam questions only)
# Usage: ./scripts/seed-database.sh [container_name]

CONTAINER_NAME=${1:-ap-study-project-ap-study-backend-1}

echo "🌱 Seeding past exam questions in container: $CONTAINER_NAME"
echo "📝 Note: Only past exam questions are seeded. Study plan templates are handled separately."

# Check if container is running
if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
  echo "❌ Container $CONTAINER_NAME is not running"
  echo "Available containers:"
  docker ps --format "table {{.Names}}\t{{.Status}}"
  exit 1
fi

# Execute seed command in the container
echo "Running seed command for past exam questions..."
docker exec $CONTAINER_NAME npx tsx src/infrastructure/database/seeds/index.ts

if [ $? -eq 0 ]; then
  echo "✅ Past exam questions seeding completed successfully"
  echo "📚 Study plan templates are not included in seed data for data protection"
else
  echo "❌ Database seeding failed"
  exit 1
fi