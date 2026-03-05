# Azure Deployment Guide

## Overview

This Spring Boot application is configured to work with Azure services using the Azure SDK for Java. The application supports:

- **Azure Database for MySQL/PostgreSQL** for persistent data storage
- **Azure Key Vault** for secure secret management
- **Application Insights** for monitoring and observability
- **Managed Identity** for secure authentication

## Dependencies

The application uses:

- **azure-identity** (1.10.4): For Azure authentication (Managed Identity, Service Principal)
- **azure-security-keyvault-secrets** (4.7.3): For Azure Key Vault integration
- **applicationinsights-runtime-attach** (3.4.13): For Application Insights monitoring
- **mysql-connector-j** (8.0.33): For MySQL database connections
- **postgresql** (42.6.0): For PostgreSQL connections (optional)

## Environment Variables

### Required for Production

```bash
# Database Configuration
AZURE_DB_URL=jdbc:mysql://your-server.mysql.database.azure.com:3306/your-db
AZURE_DB_USERNAME=user@your-server
AZURE_DB_PASSWORD=your-password

# Spring Profile
SPRING_PROFILES_ACTIVE=prod,azure

# Port (optional, defaults to 8080)
PORT=8080
```

### Optional: Azure Key Vault

```bash
AZURE_KEYVAULT_ENDPOINT=https://your-keyvault.vault.azure.net/

# For Service Principal (if not using Managed Identity)
AZURE_TENANT_ID=your-tenant-id
AZURE_CLIENT_ID=your-client-id
AZURE_CLIENT_SECRET=your-client-secret
```

### Optional: Application Insights

```bash
# Option 1: Connection String (recommended)
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=your-key;IngestionEndpoint=https://your-region.in.applicationinsights.azure.com/

# Option 2: Legacy Instrumentation Key
APPINSIGHTS_INSTRUMENTATIONKEY=your-instrumentation-key
```

## Authentication Methods

### 1. Managed Identity (Recommended for Azure Resources)

Managed Identity is the **recommended** approach for applications running on Azure VMs, App Service, AKS, or Container Instances.

**No additional configuration needed** - Azure SDK automatically detects Managed Identity.

#### Enable Managed Identity on Azure Resource:
- **Azure App Service**: Go to "Identity" > Enable "System assigned"
- **Azure VM**: Go to "Identity" > Enable "System assigned"
- **AKS**: Configure workload identity during cluster setup

**Grant permissions to Key Vault:**
```bash
# Using Azure CLI
az keyvault set-policy --name your-keyvault \
  --object-id <managed-identity-id> \
  --secret-permissions get list
```

### 2. Service Principal (For Development/CI/CD)

For local development or CI/CD pipelines:

```bash
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
```

## Database Configuration

### Azure Database for MySQL

```bash
export AZURE_DB_URL="jdbc:mysql://your-server.mysql.database.azure.com:3306/your-database?serverTimezone=UTC&sslMode=REQUIRED"
export AZURE_DB_USERNAME="user@your-server"
export AZURE_DB_PASSWORD="your-password"
```

### Azure Database for PostgreSQL

```bash
export AZURE_DB_URL="jdbc:postgresql://your-server.postgres.database.azure.com:5432/your-database?sslmode=require"
export AZURE_DB_USERNAME="user@your-server"
export AZURE_DB_PASSWORD="your-password"
```

Update `spring.datasource.driverClassName` and `spring.jpa.database-platform` in `application-azure.properties` accordingly.

## Local Development with Docker Compose

For local development that simulates Azure resources:

```bash
docker-compose up -d

# The app will be available at http://localhost:8080
# MySQL is available at localhost:3306
```

## Deployment

### 1. Azure App Service

```bash
# Build Docker image
docker build -t ghcr.io/your-username/your-repo:latest -f Dockerfile .

# Push to GitHub Container Registry
docker push ghcr.io/your-username/your-repo:latest

# Deploy using Azure CLI
az webapp config container set \
  --name your-app-service \
  --resource-group your-resource-group \
  --docker-custom-image-name ghcr.io/your-username/your-repo:latest \
  --docker-registry-server-url https://ghcr.io \
  --docker-registry-server-user <github-username> \
  --docker-registry-server-password <github-token>

# Configure environment variables
az webapp config appsettings set \
  --resource-group your-resource-group \
  --name your-app-service \
  --settings SPRING_PROFILES_ACTIVE=prod,azure \
  AZURE_DB_URL="jdbc:mysql://..." \
  AZURE_DB_USERNAME="..." \
  AZURE_DB_PASSWORD="..."
```

### 2. Azure Container Instances (ACI)

```bash
export RESOURCE_GROUP="your-resource-group"
export REGISTRY_NAME="your-registry"
export APP_NAME="demo-app"
export IMAGE_NAME="ghcr.io/your-username/your-repo:latest"

az container create \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --image $IMAGE_NAME \
  --registry-login-server ghcr.io \
  --registry-username <github-username> \
  --registry-password <github-token> \
  --cpu 1 --memory 1 \
  --ports 8080 \
  --environment-variables \
    SPRING_PROFILES_ACTIVE=prod,azure \
    AZURE_DB_URL="jdbc:mysql://..." \
    AZURE_DB_USERNAME="..." \
    AZURE_DB_PASSWORD="..."
```

### 3. Azure Kubernetes Service (AKS)

```bash
# Update deployment manifests
kubectl apply -f azure/aks-deployment.yaml

# Create secrets for sensitive data
kubectl create secret generic db-secret \
  --from-literal=url="jdbc:mysql://..." \
  --from-literal=username="..." \
  --from-literal=password="..."

kubectl create secret generic appinsights-secret \
  --from-literal=instrumentationkey="..."
```

## Application Insights Configuration

The application uses the Application Insights Java agent for automatic instrumentation.

### Features Enabled

- **Dependency tracking**: Auto-tracks calls to databases, HTTP services
- **Exception tracking**: Automatically captures unhandled exceptions
- **Performance metrics**: Tracks request latency, throughput
- **Custom metrics**: Can be added via code

### Configuration

Set the connection string:

```bash
export APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=your-key;IngestionEndpoint=https://your-region.in.applicationinsights.azure.com/"
```

View metrics in Azure Portal:
1. Go to your Application Insights resource
2. Navigate to "Live Metrics"
3. Monitor application performance in real-time

## Key Vault Integration

The application is configured to read secrets from Azure Key Vault.

### Setting up Key Vault

```bash
# Create a Key Vault
az keyvault create --name my-keyvault --resource-group my-rg

# Add secrets
az keyvault secret set --vault-name my-keyvault \
  --name db-password \
  --value <your-db-password>

# Grant access (for Managed Identity)
az keyvault set-policy --name my-keyvault \
  --object-id <managed-identity-object-id> \
  --secret-permissions get list
```

### Accessing Secrets in Code

To access Key Vault secrets programmatically:

```java
// Example (not yet implemented in this app)
// You can manually integrate using Azure Identity and Key Vault SDKs
```

## Health Checks

The application provides health endpoints for Azure load balancers:

- `GET /health` - Simple health check
- `GET /ready` - Readiness probe (checks dependencies)
- `GET /live` - Liveness probe
- `GET /actuator/health` - Detailed health information

Configure health checks in your Azure deployment settings.

## Troubleshooting

### Database Connection Issues

```bash
# Check connectivity to Azure MySQL
mysql -h your-server.mysql.database.azure.com -u user@your-server -p

# Common issues:
# 1. Firewall rules not configured - add your IP in Azure Portal
# 2. SSL/TLS issues - ensure SSL mode is set in connection string
# 3. Authentication - use format "user@server-name" for Azure MySQL
```

### Authentication Failures

```bash
# Check Managed Identity is enabled
az vm identity show --resource-group <rg> --name <vm-name>

# For Service Principal, validate credentials
az login --service-principal \
  -u $AZURE_CLIENT_ID \
  -p $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID
```

### Application Insights Issues

```bash
# Verify connection string
echo $APPLICATIONINSIGHTS_CONNECTION_STRING

# Check ingestion endpoint is accessible
curl -v https://your-region.in.applicationinsights.azure.com/

# View logs
docker logs <container-id>
```

## Best Practices

1. **Use Managed Identity** on Azure resources instead of storing credentials
2. **Store sensitive data** in Azure Key Vault, not in configuration files
3. **Enable SSL/TLS** for database connections
4. **Monitor health endpoints** with load balancers
5. **Use application profiles** to separate dev/prod configurations
6. **Enable Application Insights** for production monitoring
7. **Regular backups** of Azure Database
8. **Implement auto-scaling** for production workloads