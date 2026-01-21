#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

if ! docker images 2>/dev/null | grep -E 'blog_app' || ! docker images 2>/dev/null | grep -E 'blog_app_sidekiq'; then
    echo "🚧 Building docker images." 1>&2
    "${SCRIPT_DIR}/docker-build.sh"
fi

# Create Kubernetes secret for Rails application
if ! kubectl get secret rails-secret; then
    echo "🔐 Creating rails-secret in Kubernetes."
    kubectl create secret generic rails-secret \
    --from-literal=SECRET_KEY_BASE=$(bundle exec rails secret) \
    -n blogapp
else
    echo '⚠️  rails-secret already exists. Skipping creation.' 1>&2
fi

# Load docker images into kind cluster
echo "🚛 Loading docker images into kind cluster." 1>&2
kind load docker-image blog_app:latest --name blogapp
kind load docker-image blog_app_sidekiq:latest --name blogapp

# Deploy blogapp helm chart
echo "🚀 Deploying blogapp to Kubernetes cluster using Helm." 1>&2
helm upgrade --install blogapp blog-app-chart/ --namespace=blogapp --create-namespace

# Run db migrations
echo "🛠️  Running database migrations." 1>&2
kubectl exec -it deployment/blog-app-rails -n blogapp -- bin/rails db:create db:migrate

echo "✅ Blogapp deployed successfully. You can view the application by port-forwarding:"
echo "kubectl port-forward svc/blog-app-rails 3000:3000"