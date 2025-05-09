<!-- Generated by SpecStory -->

# Docker Compose for Monitoring Containers (2025-04-28 05:29:39)

_**User**_

Create a docker compose file that will accomplish all of the rules I've defined in the project. I want to be able to have full monitoring of Open WebUI and Ollama containers using uptime-kuma according to this part of the Open WebUI docs: @https://docs.openwebui.com/getting-started/advanced-topics/monitoring/ 

---

_**Assistant**_



---

```diff
- 
+ version: '3.8'
+ 
+ services:
+   ollama:
+     image: ollama/ollama:latest
+     container_name: ollama
+     volumes:
+       - ollama-data:/root/.ollama
+     ports:
+       - "11434:11434"
+     deploy:
+       resources:
+         reservations:
+           devices:
+             - driver: nvidia
+               count: 1
+               capabilities: [gpu]
+     networks:
+       - ai-network
+     healthcheck:
+       test: ["CMD", "curl", "-f", "http://localhost:11434/api/health"]
+       interval: 30s
+       timeout: 10s
+       retries: 3
+       start_period: 15s
+     restart: unless-stopped
+ 
+   open-webui:
+     image: ghcr.io/open-webui/open-webui:latest
+     container_name: open-webui
+     volumes:
+       - open-webui-data:/app/backend/data
+     ports:
+       - "8080:8080"
+     environment:
+       - OLLAMA_API_BASE=http://ollama:11434
+       - DISABLE_AUTH=true
+       - ENABLE_SIGNUP=false
+     depends_on:
+       ollama:
+         condition: service_healthy
+     networks:
+       - ai-network
+     healthcheck:
+       test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
+       interval: 30s
+       timeout: 10s
+       retries: 3
+       start_period: 15s
+     restart: unless-stopped
+ 
+   uptime-kuma:
+     image: louislam/uptime-kuma:1
+     container_name: uptime-kuma
+     volumes:
+       - uptime-kuma-data:/app/data
+     ports:
+       - "3001:3000"
+     depends_on:
+       ollama:
+         condition: service_healthy
+       open-webui:
+         condition: service_healthy
+     networks:
+       - ai-network
+     restart: unless-stopped
+ 
+ networks:
+   ai-network:
+     driver: bridge
+ 
+ volumes:
+   ollama-data:
+     name: ollama-data
+   open-webui-data:
+     name: open-webui-data
+   uptime-kuma-data:
+     name: uptime-kuma-data 
```

---

```diff
- 
+ # OpenWebUI + Ollama Docker Compose Setup
+ 
+ This Docker Compose configuration provides an AI stack with three main services:
+ 
+ - **Ollama**: AI model server with NVIDIA GPU support
+ - **Open WebUI**: Web interface for interacting with Ollama models
+ - **Uptime Kuma**: Monitoring solution for service health
+ 
+ ## Requirements
+ 
+ - Docker and Docker Compose
+ - NVIDIA GPU with compatible drivers
+ - NVIDIA Container Toolkit installed
+ 
+ ## Usage
+ 
+ 1. Start the services:
+    ```bash
+    docker compose up -d
+    ```
+ 
+ 2. Access the services:
+    - Open WebUI: http://localhost:8080
+    - Uptime Kuma: http://localhost:3001
+ 
+ ## Uptime Kuma Configuration
+ 
+ After starting the services, configure Uptime Kuma to monitor both Ollama and Open WebUI:
+ 
+ 1. Access Uptime Kuma at http://localhost:3001
+ 2. Create a new account during first login
+ 3. Add monitors for both services:
+ 
+ ### Basic Health Check for Open WebUI
+ 
+ 1. Click "Add New Monitor"
+ 2. Configure:
+    - Monitor Type: HTTP(s)
+    - Name: Open WebUI Health
+    - URL: http://open-webui:8080/health
+    - Monitoring Interval: 60 seconds
+    - Retry Count: 3
+ 
+ ### Basic Health Check for Ollama
+ 
+ 1. Click "Add New Monitor"
+ 2. Configure:
+    - Monitor Type: HTTP(s)
+    - Name: Ollama Health
+    - URL: http://ollama:11434/api/health
+    - Monitoring Interval: 60 seconds
+    - Retry Count: 3
+ 
+ ## Volume Data
+ 
+ All services use persistent volumes:
+ - Ollama data: `/root/.ollama`
+ - Open WebUI data: `/app/backend/data`
+ - Uptime Kuma data: `/app/data`
+ 
+ ## Additional Configuration
+ 
+ For more advanced monitoring options, including Model Connectivity and Response Testing, refer to the [Open WebUI Monitoring Documentation](https://docs.openwebui.com/getting-started/advanced-topics/monitoring/). 
```

---

The Docker Compose setup is ready with all three services: Ollama (with GPU support), Open WebUI (without authentication), and Uptime Kuma for monitoring. All services use the shared ai-network and have persistent volumes configured.

The setup follows all your specified requirements including:
- NVIDIA GPU configuration for Ollama
- Proper authentication settings for Open WebUI
- Correct port mappings
- Service dependencies with health checks
- Persistent volumes mapped correctly

The README includes instructions for starting the services and configuring Uptime Kuma monitors according to the Open WebUI documentation. After running `docker compose up -d`, you'll be able to access Open WebUI at port 8080 and Uptime Kuma at port 3001, where you can set up monitoring for both services.

---

