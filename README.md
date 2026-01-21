# BLOG APP - Ruby on Rails

## Overview

This sample project demonstrates some fundamentals of using Ruby on Rails.

## Notes

[scripts/start_redis.sh](scripts/start_redis.sh) --> use this to start the redis server.  I am using Docker to keep parity with production.  

## Sidekiq / Redis

Redis will be utilised by sidekiq to persist jobs.

## Deploy to Kubernetes

### Dev Environment

* Run the following script to deploy the solution to your local Kubernetes cluster:

```bash
scripts/k8s-up.sh
```













