# BLOG APP - Ruby on Rails

This sample project demonstrates some of the fundamentals that I have learned about Ruby on Rails:

# Architecture

           ┌───────────────────┐
           │   User / Browser  │
           └────────┬──────────┘
                    │ HTTP Requests
                    │  - Create Post
                    │  - Read Post(s)
                    │  - Update Post
                    │  - Delete Post
                    │  - Enqueue per Post Job
                    ▼
           ┌───────────────────┐
           │    Rails Server   │
           │  (blog_app)       │
           │  Deployment       │
           │  - Handles CRUD   │
           │  - Enqueues Jobs  │
           └───────┬───────────┘
                   │ Background Jobs
                   ▼
           ┌───────────────────┐
           │   Sidekiq Worker  │
           │  Deployment       │
           │  - Processes Jobs │
           │  - Notifications  │
           └───────┬───────────┘
                   │ Stores / Retrieves
                   ▼
           ┌───────────────────┐
           │      Redis        │
           │  Deployment       │
           │  - Queue Backend  │
           │  - Cache / State  │
           └───────────────────┘





## Application Overview

This Ruby on Rails application demonstrates a simple **blog platform** with background job processing:

- Users can **create, read, update, and delete blog posts**.  
- When a new post is created, a **Sidekiq background job** can be enqueued to perform tasks asynchronously (e.g., notifications).  
- **Sidekiq uses Redis** as a queue backend to manage jobs reliably, with at-least-once delivery semantics.  
- The architecture is containerised using **Docker** and can be deployed to **Kubernetes** using a Helm chart.  
- Redis handles both **job queues** and **data caching**, while Rails handles HTTP requests and the application logic.  
- The design separates concerns:
  - Rails server → handles user requests and business logic  
  - Sidekiq → handles background processing  
  - Redis → stores queues and provides ephemeral data for jobs  

This setup demonstrates how to build a **scalable, containerized Rails application** with background processing, queue reliability, and a clean separation of concerns.


## Routing & Controllers
- RESTful resources (`resources :posts`)  
- Custom member routes (`enqueue_notifier`)  
- Routing helpers (`posts_path`, etc.)  
- Health check endpoint (`/up`)  

## Actions & Callbacks
- Controller actions (`index`, `show`, `new`, `edit`, `create`, `update`, `destroy`)  
- Before-action callbacks (`before_action :set_post`)  
- Private methods for internal use (`set_post`, `post_params`)  

## Models & Validations
- ActiveRecord models (`Post < ApplicationRecord`)  
- Validations (`validates :title, presence: true`)  
- Database migrations and schema evolution  
- Importance of nullable vs non-nullable columns  

## Background Jobs with Sidekiq
- Creating jobs (`PostNotifierJob < ApplicationJob`)  
- Enqueuing jobs from controller (`perform_later`)  
- Queue names with symbols (`queue_as :default`)  
- Jobs are stateless and idempotent  
- Logging using `Rails.logger` instead of `puts`  

## Redis & Sidekiq Internals
- Redis as a queue backend (not just key-value store)  
- At-least-once delivery semantics  
- Heartbeat mechanism to track worker liveness  
- Reaper logic to detect dead workers and re-enqueue jobs  
- Mapping of process → job → message in Redis  
- Distributed coordination using Redis locks  

## Development & Deployment
- Using Docker for Rails app and Redis  
- Running Sidekiq separately from Rails server  
- Building production Docker images  
- Helm chart for Kubernetes deployment  
- Port-forwarding to access services locally  
- Keeping a clean local Docker environment  

## Miscellaneous Rails Features
- Rails logging and log levels (`debug`, `info`)  
- Rails asset precompilation  
- Symbols in Ruby (`:default`) and their purpose  

## Deploy to Kubernetes

### Dev Environment

* Run the following script to deploy the solution to your local Kubernetes cluster:

```bash
scripts/k8s-up.sh
```

```bash
# output
✅ Blogapp deployed successfully. You can view the application by port-forwarding:
kubectl port-forward svc/blog-app-rails 3000:3000
```














