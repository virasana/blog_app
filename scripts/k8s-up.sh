#!/usr/bin/env bash

# Create Kubernetes secret for Rails application
if ! kubectl get secret rails-secret; then
    kubectl create secret generic rails-secret \
    --from-literal=SECRET_KEY_BASE=$(bundle exec rails secret) \
    -n blogapp
else
    echo '⚠️  rails-secret already exists. Skipping creation.' 1>&2
fi

# Deploy blogapp helm chart
helm upgrade --install blogapp blog-app-chart/ --namespace=blogapp --create-namespace

# Run db migrations
kubectl exec -it deployment/blog-app-rails -n blogapp -- bin/rails db:create db:migrate

echo "✅ Blogapp deployed successfully. You can view the application by port-forwarding:"
echo "kubectl port-forward svc/blog-app-rails 3000:3000"