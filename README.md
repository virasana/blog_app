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

## Redis as a Queue in Sidekiq

Redis acts as a **fast in-memory queue**, but it is **just a storage layer**—it does not process jobs itself. Sidekiq workers read jobs from Redis and execute them, coordinating work across multiple Sidekiq instances.

### Key behaviors

- **Job lifecycle:** Jobs are pushed to Redis queues, picked up by Sidekiq workers, and marked as **in progress** while being processed.  
- **Heartbeat:** Workers periodically update a heartbeat in Redis to signal they are alive; if a worker dies, jobs can be retried.  
- **Reaper:** A background process monitors jobs stuck in progress due to worker failure and moves them back to the queue for retry.  
- **Coordination:** Multiple Sidekiq instances can safely pull jobs from the same Redis queues because Redis operations like `RPOP` are atomic.  

**Summary:** Redis holds the jobs and tracks their state, while Sidekiq handles execution, retries, and coordination among workers.

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

### Prerequisites

* Access to a Kubernetes cluster.  I use [kind](https://kind.sigs.k8s.io/)
* install ruby.  I use:

```bash
 ruby 4.0.1 (2026-01-13 revision e04267a14b) +PRISM [x86_64-linux]
 ```
   I installed ruby with [mise](https://mise.jdx.dev/)

```bash
# from the repo root directory
mise install
```

### Dev Environment

* Build docker images

```bash
scripts/docker-build.sh
```

* Run the following script to deploy the solution to your local Kubernetes cluster:

```bash
scripts/k8s-up.sh
```

```bash
# output
✅ Blogapp deployed successfully. You can view the application by port-forwarding:
kubectl port-forward svc/blog-app-rails 3000:3000
```














