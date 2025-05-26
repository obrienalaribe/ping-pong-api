# Ping Pong API

This repository contains a complete production-ready setup for deploying the JavaScript ping-pong-api service to Google Kubernetes Engine (GKE)

## 📋 Overview

- **Application**: Node.js ping-pong API service
- **Container**: Docker with multi-stage build for lean, secure images
- **Infrastructure**: GKE cluster provisioned with Terraform
- **Deployment**: Helm charts
- **CI/CD**: GitHub Actions for automated build and deployment
- **Security**: Network policies, resource limits, and security contexts

## 🏗️ Architecture

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
```

## 📁 Project Structure

```
ping-pong-devops/
├── docker/
│   └── Dockerfile                 # Multi-stage Docker build
├── terraform/
│   ├── main.tf                   # GKE cluster configuration
│   ├── variables.tf              # Terraform variables
│   ├── outputs.tf                # Terraform outputs
│   
├── helm/
│   └── ping-pong-api/
│       ├── Chart.yaml            # Helm chart metadata
│       ├── values.yaml           # Default values
│       ├── values-prod.yaml      # Production values
│       └── templates/
│           ├── deployment.yaml   # Kubernetes deployment
│           ├── service.yaml      # Kubernetes service
│           ├── ingress.yaml      # Ingress configuration
│           ├── configmap.yaml    # ConfigMap
│           ├── networkpolicy.yaml # Network security policy
│           └── hpa.yaml          # Horizontal Pod Autoscaler
├── .github/
│   └── workflows/
│       ├── build-and-deploy.yml  # Main CI/CD pipeline
│       └── terraform.yml         # Infrastructure deployment
├── src/                          # Application source code
│   ├── package.json
│   ├── server.js
│   └── ...
├── scripts/
│   ├── setup.sh                 # Initial setup script
│   └── deploy.sh                # Manual deployment script
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- Google Cloud Platform account with billing enabled
- `gcloud` CLI installed and configured
- `terraform` >= 1.0
- `kubectl` installed
- `helm` >= 3.0
- Docker installed

### 1. Initial Setup

```bash
# Clone this repository
git clone <your-repo-url>
cd ping-pong-api

```

### 2. Infrastructure Deployment

```bash
# Navigate to terraform directory
cd terraform

gcloud auth application-default login

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars

# Initialize and apply Terraform
terraform init
terraform plan
terraform apply
```

### 3. Application Deployment

```bash
# Get GKE cluster credentials
gcloud container clusters get-credentials ping-pong-cluster --region eu-central1

# Deploy using Helm
helm upgrade --install ping-pong-api ./helm/ping-pong-api \
  --values ./helm/ping-pong-api/values-prod.yaml \
  --namespace ping-pong --create-namespace
```

## 🐳 Docker Configuration

### Multi-stage Dockerfile Features:
- **Security**: Non-root user, minimal base image (node:18-alpine)
- **Performance**: Multi-stage build to reduce image size
- **Caching**: Optimized layer caching for faster builds
- **Health checks**: Built-in health monitoring

### Build locally:
```bash
docker build -f docker/Dockerfile -t ping-pong-api:latest .
docker run -p 3000:3000 ping-pong-api:latest
```

## ☁️ GKE Infrastructure

### Terraform Configuration Features:
- **Security**: Private cluster with authorized networks
- **Scalability**: Node auto-scaling and cluster autoscaler
- **Monitoring**: GKE monitoring and logging enabled
- **Networking**: VPC-native cluster with custom subnets
- **Cost Optimization**: Preemptible nodes for non-production workloads

### Key Security Features:
- Private cluster with no public IP addresses on nodes
- Network policies enabled
- Workload Identity for secure GCP service access
- Binary Authorization for container image security

## ⚓ Helm Charts

### Production Configuration:
- **Replicas**: Minimum 2 replicas with HPA
- **Resources**: CPU/Memory requests and limits
- **Health**: Readiness and liveness probes
- **Security**: Security contexts and network policies
- **Ingress**: Google Cloud Load Balancer integration

### Deployment Commands:
```bash
# Install/upgrade in production
helm upgrade --install ping-pong-api ./helm/ping-pong-api \
  --values ./helm/ping-pong-api/values-prod.yaml \
  --namespace default --create-namespace

```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows:

1. **Build and Deploy** (`.github/workflows/build-and-deploy.yml`)
   - Triggers on push to main branch
   - Builds Docker image
   - Pushes to Google Artifact Registry
   - Deploys to GKE using Helm

2. **Infrastructure** (`.github/workflows/terraform.yml`)
   - Manages Terraform state
   - Plans and applies infrastructure changes
   - Triggered manually or on terraform file changes

### Required GitHub Secrets:
```
GCP_PROJECT_ID          # Your GCP project ID
GCP_SA_KEY              # Service account key (base64 encoded)
GKE_CLUSTER_NAME        # GKE cluster name
GKE_CLUSTER_ZONE        # GKE cluster zone/region
DOCKER_REGISTRY         # Artifact Registry URL
```

## 🔒 Security Best Practices

### Network Security:
- Private GKE cluster
- Network policies restricting pod-to-pod communication
- Ingress with SSL/TLS termination
- VPC firewall rules

### Container Security:
- Non-root user in containers
- Read-only root filesystem
- Security contexts with dropped capabilities
- Resource limits to prevent resource exhaustion

### Access Control:
- Workload Identity for GCP service access
- RBAC for Kubernetes resources
- Service accounts with minimal permissions

## 📊 Monitoring and Observability

### Built-in Monitoring:
- GKE monitoring and logging
- Application health checks
- Resource usage metrics
- Horizontal Pod Autoscaler metrics

### Endpoints:
- **Application**: `/ping` (returns "pong")
- **Health**: `/health` (health check endpoint)
- **Metrics**: `/metrics` (Prometheus metrics - if implemented)

## 🔧 Configuration

### Environment Variables:
```yaml
# Application configuration
PORT: 3000
NODE_ENV: production
LOG_LEVEL: info

# GCP configuration  
GCP_PROJECT_ID: your-project-id
GKE_CLUSTER_NAME: ping-pong-cluster
GKE_CLUSTER_ZONE: us-central1
```

### Helm Values Customization:
```yaml
# values-prod.yaml example
replicaCount: 3
image:
  repository: gcr.io/your-project/ping-pong-api
  tag: latest
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
```

## 🚨 Troubleshooting

### Common Issues:

1. **GKE Cluster Access**:
   ```bash
   gcloud container clusters get-credentials ping-pong-cluster --region us-central1
   ```

2. **Helm Deployment Issues**:
   ```bash
   helm list -A
   kubectl get pods -n ping-pong
   kubectl logs -n ping-pong deployment/ping-pong-api
   ```

3. **Networking Issues**:
   ```bash
   kubectl get ingress -n ping-pong
   kubectl describe ingress ping-pong-api -n ping-pong
   ```

## 📈 Scaling and Performance

### Horizontal Pod Autoscaler:
- Scales based on CPU utilization (70% threshold)
- Min replicas: 2, Max replicas: 10
- Configurable via Helm values

### Cluster Autoscaler:
- Automatically scales node pools based on demand
- Configured in Terraform with min/max node counts

## 🔄 Updates and Maintenance

### Application Updates:
```bash
# Update application image
helm upgrade ping-pong-api ./helm/ping-pong-api \
  --set image.tag=v1.2.0 \
  --namespace production
```

### Infrastructure Updates:
```bash
cd terraform
terraform plan
terraform apply
```

## 📝 Design Decisions and Rationale

### Docker Multi-stage Build:
- **Why**: Reduces final image size by excluding build dependencies
- **Security**: Uses minimal alpine base image and non-root user
- **Performance**: Optimizes Docker layer caching

### Private GKE Cluster:
- **Why**: Enhanced security by removing public IP addresses from nodes
- **Trade-off**: Requires bastion host or VPN for direct access
- **Benefit**: Reduces attack surface significantly

### Helm over kubectl:
- **Why**: Template management and configuration flexibility
- **Benefit**: Environment-specific configurations
- **Maintenance**: Easier rollbacks and upgrades

### GitHub Actions over other CI/CD:
- **Why**: Native integration with GitHub repositories
- **Cost**: Free for public repositories
- **Features**: Rich ecosystem of actions and integrations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the established patterns
4. Test changes in development environment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

For questions or issues, please open a GitHub issue or contact the development team.