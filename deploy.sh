#!/bin/bash

APP_NAME="flask-app"
IMAGE="cath0806/$APP_NAME"
NEW_TAG=$1
OLD_TAG=$2

echo "🔄 Deploying version $NEW_TAG..."

docker pull $IMAGE:$NEW_TAG
docker stop $APP_NAME || true && docker rm $APP_NAME || true

docker run -d --name $APP_NAME -p 80:5000 $IMAGE:$NEW_TAG

echo "⏳ Waiting for app to become healthy..."
sleep 10

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)

if [ "$STATUS" != "200" ]; then
  echo "❌ Health check failed! Reverting to $OLD_TAG..."
  docker stop $APP_NAME && docker rm $APP_NAME
  docker run -d --name $APP_NAME -p 80:5000 $IMAGE:$OLD_TAG
  exit 1
else
  echo "✅ Deployment successful."
fi
