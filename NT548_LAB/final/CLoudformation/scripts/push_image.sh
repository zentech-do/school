#!/bin/bash

# Load environment variables from .env file
if [ -f scripts/.image.env ]; then
    export $(cat scripts/.image.env | xargs)
else
    echo ".image.env file not found. Please create one with DOCKER_USERNAME and DOCKER_PASSWORD."
    exit 1
fi

# Step 1: Log in to Docker Hub
docker login --username "$DOCKER_USERNAME" --password "$DOCKER_PASSWORD"

# Step 2: Tag each service image for the same repository
docker tag auth-service $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:auth-service
docker tag profile-service $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:profile-service
docker tag task-service $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:task-service
docker tag todo-fe $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:todo-fe

# Step 3: Push each tagged image to the repository
docker push $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:auth-service
docker push $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:profile-service
docker push $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:task-service
docker push $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME:todo-fe

echo "All service images pushed successfully into $DOCKER_USERNAME/$DOCKER_REPOSITORY_NAME!"
