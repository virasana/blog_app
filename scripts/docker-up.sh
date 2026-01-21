#!/usr/bin/env bash

###########################
# Configuration Variables #
###########################
BLOG_APP_REDIS_CONTAINER_NAME="blog_redis"
BLOG_APP_REDIS_IMAGE="redis:latest"
BLOG_APP_REDIS_PORT=6379

###########################
# Root Guard              #
###########################
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Please run this script as root (sudo)."
    exit 1
fi

###########################
# Start Docker Service    #
###########################
if ! systemctl is-active --quiet docker; then
    echo "Docker service is not running. Starting Docker..."
    systemctl start docker
    if [ $? -ne 0 ]; then
        echo "❌ Failed to start Docker. Aborting."
        exit 1
    fi
    echo "Docker started successfully."
fi

###########################
# Script Starts Here      #
###########################

# Check if the container is already running
if [ "$(docker ps -q -f name=$BLOG_APP_REDIS_CONTAINER_NAME)" ]; then
    echo "Redis container '$BLOG_APP_REDIS_CONTAINER_NAME' is already running."
else
    # Check if the container exists but is stopped
    if [ "$(docker ps -aq -f name=$BLOG_APP_REDIS_CONTAINER_NAME)" ]; then
        echo "Starting existing Redis container..."
        docker start $BLOG_APP_REDIS_CONTAINER_NAME
    else
        # Pull and run Redis container
        echo "Pulling and starting new Redis container..."
        docker run -d \
            --name $BLOG_APP_REDIS_CONTAINER_NAME \
            -p $BLOG_APP_REDIS_PORT:6379 \
            $BLOG_APP_REDIS_IMAGE
    fi
    echo "Redis is running on port $BLOG_APP_REDIS_PORT"
fi
