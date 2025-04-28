# OpenWebUI + Ollama Docker Compose Setup

This Docker Compose configuration provides an AI stack with three main services:

- **Ollama**: AI model server with NVIDIA GPU support
- **Open WebUI**: Web interface for interacting with Ollama models
- **Uptime Kuma**: Monitoring solution for service health

## Requirements

- Docker and Docker Compose
- NVIDIA GPU with compatible drivers
- NVIDIA Container Toolkit installed

## Usage

1. Start the services:
   ```bash
   just start
   ```

2. Access the services:
   - Open WebUI: http://localhost:8080
   - Uptime Kuma: http://localhost:3001

## Uptime Kuma Configuration

After starting the services, configure Uptime Kuma to monitor both Ollama and Open WebUI:

1. Access Uptime Kuma at http://localhost:3001
2. Create a new account during first login (not really yet)
3. Add monitors for both services:

### Basic Health Check for Open WebUI

1. Click "Add New Monitor"
2. Configure:
   - Monitor Type: HTTP(s)
   - Name: Open WebUI Health
   - URL: http://open-webui:8080/health
   - Monitoring Interval: 60 seconds
   - Retry Count: 3

### Basic Health Check for Ollama

1. Click "Add New Monitor"
2. Configure:
   - Monitor Type: HTTP(s)
   - Name: Ollama Health
   - URL: http://ollama:11434/api/health
   - Monitoring Interval: 60 seconds
   - Retry Count: 3

## Volume Data

All services use persistent volumes:
- Ollama data: `/root/.ollama`
- Open WebUI data: `/app/backend/data`
- Uptime Kuma data: `/app/data`

## Additional Configuration

For more advanced monitoring options, including Model Connectivity and Response Testing, refer to the [Open WebUI Monitoring Documentation](https://docs.openwebui.com/getting-started/advanced-topics/monitoring/). 
