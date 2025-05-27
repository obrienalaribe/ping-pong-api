# Ping Pong API

Automated deployment of the ping-pong API service on Google Kubernetes Engine (GKE) using Infrastructure-as-Code (IaC) and CI/CD pipeline.

## Overview

- **Application**: Node.js ping-pong API service exposing `/ping` endpoint
- **Container**: Multi-stage Docker build with security best practices
- **Infrastructure**: GKE cluster provisioned with Terraform
- **Ingress**: Nginx Ingress Controller with optional Cloudflare DNS
- **Deployment**: Helm charts with 2 replicas
- **CI/CD**: GitHub Actions for automated build and deployment

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions  │───▶│ Google Artifact │
│                 │    │                  │    │   Registry      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                 │                        │
                                 ▼                        │
┌─────────────────┐    ┌──────────────────┐             │
│   Terraform     │───▶│   GKE Cluster    │◀────────────┘
│Infrastructure   │    │                  │
└─────────────────┘    └──────────────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │   Helm Charts    │
                        │ (2+ replicas)    │
                        └──────────────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │ Nginx Ingress    │
                        │ Controller       │
                        └──────────────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │ Optional         │
                        │ Cloudflare DNS   │
                        └──────────────────┘
```

## Getting Started

### Prerequisites

- Google Cloud SDK with `gcloud` installed
- Terraform >= 1.0.0
- kubectl
- Helm 3
- Docker

### Setup Instructions

1. **Clone the repository**
```bash
git clone https://github.com/obrienalaribe/ping-pong-api.git
cd ping-pong-api
```

2. **Configure GCP Project**
```bash
gcloud config set project YOUR_PROJECT_ID
gcloud auth login
```

3. **Initialize Terraform**
```bash
cd terraform
terraform init
```

4. **Deploy Infrastructure**
```bash
terraform plan
terraform apply
```

5. **Deploy Application**
```bash
connect to cluster using the kubectl_config_command from your terraform output (gcloud container clusters get-credentials ping-pong-cluster ...))

cd ..
chmod u+x install.sh 
./install.sh # installs app and nginx ingress controller
```


## Development

### Building the Docker Image

The application is built with CI/CD using a multi-stage Dockerfile. check `.github/workflows` for more details.

You can use a workflow_dispatch to build and deploy the image with a custom tag you provide.

## Infrastructure Details

### GKE Cluster Configuration

- **Network**: 
- **Autoscaling**: Enabled with min/max node limits

### Nginx Ingress

- **Type**: Internal Load Balancer
- **Health Checks**: Configured for `/ping` endpoint


## 🐳 Docker Configuration

### Multi-stage Dockerfile Features:
- **Security**: Non-root user, minimal base image (node:18-alpine)
- **Performance**: Multi-stage build to reduce image size

### Build locally:
```bash
docker build -t ping-pong-api:latest .
docker run -p 3000:3000 ping-pong-api:latest
```

## ☁️ GKE Infrastructure

### Terraform Configuration Features:
- **Security**: Custom VPC with private Google access and authorized networks
- **Scalability**: Node auto-scaling and cluster autoscaler
- **Networking**: VPC-native cluster with custom subnets
- **Cost Optimization**: Preemptible nodes to manage cost for demo

### Key Security Features:
- Private cluster with no public IP addresses on nodes
- NAT Gateway for egress on worker nodes
- Workload Identity for secure GCP service access

## ⚓ Helm Charts

### Production Configuration:
- **Replicas**: Minimum 2 replicas with HPA
- **Resources**: CPU/Memory requests and limits
- **Health**: Readiness and liveness probes
- **Ingress**: Nginx Ingress Controller

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows:

1. **Build and Deploy** (`.github/workflows/build-and-deploy.yml`)
   - Triggers on PR/push to feature branch and main branch
   - Builds Docker image
   - Pushes to Google Artifact Registry
   - Deploys to GKE using Helm


### Required GitHub Secrets:
```
GCP_PROJECT_ID          # Your GCP project ID
GCP_SA_KEY              # Service account key (Ideally should be federated with token based access)
```

### Endpoints:
- **Application**: `/ping` (returns "pong")


## 📝 Design Decisions

### Docker Multi-stage Build:
- **Why**: Reduces final image size by excluding build dependencies
- **Security**: Uses minimal alpine base image and non-root user

### Private GKE Cluster:
- **Why**: Enhanced security by removing public IP addresses from nodes
- **Trade-off**: Requires bastion host or VPN for direct access
- **Benefit**: Reduces external attack surface