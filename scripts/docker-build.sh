#!/usr/bin/env bash
set -euo pipefail

echo '🚧 Building Docker images...'

# Log files
RAILS_LOG="/tmp/docker-build-rails.log"
SIDEKIQ_LOG="/tmp/docker-build-sidekiq.log"

# Build Rails image
echo "🛠️  Building Rails Docker image..."
if ! docker build -t blog_app:latest -f Dockerfile.rails . 2>&1 | tee "$RAILS_LOG"; then
  echo "❌ Rails build failed. See log: $RAILS_LOG"
  exit 1
fi

# Build Sidekiq image
echo "🛠️  Building Sidekiq Docker image..."
if ! docker build -t blog_app_sidekiq:latest -f Dockerfile.sidekiq . 2>&1 | tee "$SIDEKIQ_LOG"; then
  echo "❌ Sidekiq build failed. See log: $SIDEKIQ_LOG"
  exit 1
fi

echo '🎉 All Docker images built successfully.'
