#!/usr/bin/env bash
set -euo pipefail

echo '🚧 Building Docker image for Rails server...'
docker build -t blog-app:latest -f Dockerfile.rails . \
  > >(tee /tmp/docker-build-rails.log) \
  2> >(tee /tmp/docker-build-rails.log >&2) &

echo '🚧 Building Docker image for Sidekiq server...'
docker build -t blog-app:latest -f Dockerfile.sidekiq . \
  > >(tee /tmp/docker-build-sidekiq.log) \
  2> >(tee /tmp/docker-build-sidekiq.log >&2) &

# Wait for both builds to finish
wait

echo '✅ Docker images built successfully.'
echo 'You can view the build logs at:'
echo '  - /tmp/docker-build-rails.log'
echo '  - /tmp/docker-build-sidekiq.log'
