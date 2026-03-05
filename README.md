# Spring Boot Demo Application - Azure Ready

A comprehensive Spring Boot application with REST API, JPA database integration, Swagger documentation, and full Azure deployment support.

## Features

- ✅ REST API with CRUD operations
- ✅ JPA/H2 database integration
- ✅ Swagger/OpenAPI documentation
- ✅ CORS configuration
- ✅ Health check endpoints
- ✅ Docker containerization
- ✅ Azure Application Insights integration
- ✅ Azure Key Vault integration
- ✅ Multi-environment configuration
- ✅ CI/CD with GitHub Actions

## Local Development

### Prerequisites

- Java 17
- Maven 3.6+
- Docker (optional)

### Running Locally

```bash
# Clone the repository
git clone https://github.com/dnayenshwar-kale/mit-wpu-code.git
cd mit-wpu-code

# Build and run with Maven
mvn clean spring-boot:run

# Or build and run with Docker
docker build -t demo-app .
docker run -p 8080:8080 demo-app
```

### API Endpoints

- `GET /api/hello` - Hello world endpoint
- `GET /api/persons` - List all persons
- `POST /api/persons` - Create a new person
- `GET /actuator/health` - Health check
- `GET /v3/api-docs` - OpenAPI specification
- `GET /swagger-ui.html` - Swagger UI

## Azure Deployment Options

### 1. Azure Kubernetes Service (AKS)

#### Prerequisites

- Azure CLI installed and logged in
- AKS cluster created
- Azure Container Registry or GitHub Container Registry access

#### Deployment Steps

```bash
# Set your Azure subscription
az account set --subscription <your-subscription-id>

# Get AKS credentials
az aks get-credentials --resource-group <resource-group> --name <aks-cluster-name>

# Update the deployment manifest with your values
# Edit azure/aks-deployment.yaml

# Deploy to AKS
kubectl apply -f azure/aks-deployment.yaml

# Check deployment status
kubectl get pods
kubectl get services
```

### 2. Azure App Service

#### Prerequisites

- Azure App Service created
- Azure Database (MySQL/PostgreSQL/SQL Server) provisioned

#### Deployment Steps

1. **Configure App Service:**
   - Go to your App Service in Azure Portal
   - Navigate to "Configuration" > "Application settings"
   - Add the environment variables from `azure/appservice-config.env`

2. **Deploy using GitHub Actions:**
   - Go to your repository > Actions > "Deploy to Azure"
   - Click "Run workflow"
   - Select environment and target "appservice"

3. **Manual deployment:**
   ```bash
   # Build and push Docker image
   docker build -t ghcr.io/your-username/your-repo:latest .
   docker push ghcr.io/your-username/your-repo:latest

   # Deploy to App Service
   az webapp config container set \
     --name <app-service-name> \
     --resource-group <resource-group> \
     --docker-custom-image-name ghcr.io/your-username/your-repo:latest \
     --docker-registry-server-url https://ghcr.io \
     --docker-registry-server-user <github-username> \
     --docker-registry-server-password <github-token>
   ```

### 3. Azure Virtual Machine

#### Prerequisites

- Azure VM with Ubuntu/Debian
- Docker installed on VM
- SSH access to VM

#### Deployment Steps

1. **Copy deployment script to VM:**
   ```bash
   scp azure/vm-deploy.sh azureuser@<vm-public-ip>:/home/azureuser/
   ```

2. **Run deployment script:**
   ```bash
   ssh azureuser@<vm-public-ip>
   chmod +x vm-deploy.sh
   sudo ./vm-deploy.sh
   ```

3. **Using GitHub Actions:**
   - Configure the required secrets in your repository
   - Run the "Deploy to Azure" workflow with target "vm"

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SPRING_PROFILES_ACTIVE` | Active Spring profiles | `default` |
| `AZURE_DB_URL` | Azure database JDBC URL | - |
| `AZURE_DB_USERNAME` | Database username | - |
| `AZURE_DB_PASSWORD` | Database password | - |
| `APPINSIGHTS_INSTRUMENTATIONKEY` | Application Insights key | - |
| `AZURE_KEYVAULT_URI` | Key Vault URI | - |
| `PORT` | Server port | `8080` |

### Application Profiles

- `default`: Development with H2 database
- `prod`: Production configuration
- `azure`: Azure-specific settings

## Monitoring

### Health Checks

- `/actuator/health` - Overall health status
- `/actuator/health/db` - Database health
- `/health` - Simple health check
- `/ready` - Readiness probe
- `/live` - Liveness probe

### Azure Application Insights

Configure the `APPINSIGHTS_INSTRUMENTATIONKEY` environment variable to enable Application Insights monitoring.

## Security

### Azure Key Vault Integration

The application supports Azure Key Vault for secret management. Configure the following environment variables:

- `AZURE_KEYVAULT_URI`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`

### CORS Configuration

CORS is configurable via application properties:

```properties
app.cors.allowed-origins=https://yourdomain.com
app.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
app.cors.allowed-headers=*
app.cors.allow-credentials=true
```

## CI/CD

The project includes GitHub Actions workflows for:

- **CI/CD Pipeline**: Automated build, test, and Docker image push
- **Azure Deployment**: Manual deployment to Azure services

### Required GitHub Secrets

For Azure deployment, configure these secrets in your repository:

- `AZURE_CREDENTIALS`: Azure service principal credentials
- `AZURE_RESOURCE_GROUP`: Azure resource group name
- `AZURE_AKS_CLUSTER`: AKS cluster name (for AKS deployment)
- `AZURE_APP_SERVICE_NAME`: App Service name (for App Service deployment)
- `AZURE_VM_NAME`: VM name (for VM deployment)
- `AZURE_DB_URL`: Database connection URL
- `AZURE_DB_USERNAME`: Database username
- `AZURE_DB_PASSWORD`: Database password
- `APPINSIGHTS_INSTRUMENTATIONKEY`: Application Insights instrumentation key

## Database Migration

For production deployments, update the database configuration:

1. Create an Azure Database (MySQL/PostgreSQL/SQL Server)
2. Update the JDBC URL in environment variables
3. Set `spring.jpa.hibernate.ddl-auto=validate` in production
4. Run database migrations manually or use Flyway/Liquibase

## Troubleshooting

### Common Issues

1. **Container fails to start**: Check environment variables and database connectivity
2. **Health check failures**: Verify database connection and actuator endpoints
3. **CORS issues**: Check CORS configuration in application properties
4. **Azure deployment failures**: Verify Azure credentials and resource permissions

### Logs

- Application logs: Check container logs or Azure Monitor
- Health check logs: Available at `/actuator/health`
- Database logs: Configure in application properties

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.