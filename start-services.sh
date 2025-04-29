#!/bin/bash

# Check for NVIDIA GPU
if command -v nvidia-smi &>/dev/null; then
  echo "NVIDIA GPU detected"
  nvidia-smi
else
  echo "WARNING: NVIDIA GPU not detected. GPU acceleration will not be available."
fi

# Start services
echo "Starting services with docker compose..."
docker compose down
docker compose up -d

echo "Waiting for services to be ready..."

# Wait for Ollama to be ready
echo "Checking Ollama health..."
until docker compose exec -T open-webui curl -s --fail http://ollama:11434/api/tags >/dev/null 2>&1; do
  echo "Waiting for Ollama to be ready..."
  sleep 2
done
echo "Ollama is ready!"

# Wait for Open WebUI to be ready
echo "Checking Open WebUI health..."
until docker compose exec -T open-webui curl -s --fail http://open-webui:8080 >/dev/null 2>&1; do
  echo "Waiting for Open WebUI to be ready..."
  sleep 2
done
echo "Open WebUI is ready!"

# Wait for Uptime Kuma to be ready
echo "Checking Uptime Kuma health..."
until docker compose exec -T open-webui curl -s --fail http://uptime-kuma:3001/health >/dev/null 2>&1; do
  echo "Waiting for Uptime Kuma to be ready..."
  sleep 2
done
echo "Uptime Kuma is ready!"

# Open browser based on OS type
echo "Opening services in browser..."

open_browser() {
  local url=$1
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "$url" &>/dev/null || (echo "Could not open browser automatically. Please visit: $url")
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    open "$url" &>/dev/null || (echo "Could not open browser automatically. Please visit: $url")
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win"* ]]; then
    start "$url" &>/dev/null || (echo "Could not open browser automatically. Please visit: $url")
  else
    echo "Could not detect OS for browser opening. Please visit: $url"
  fi
}

echo "All services are ready!"
echo "-------------------------------------"
echo "Open WebUI: http://localhost:8080"
echo "Uptime Kuma: http://localhost:3001"
echo "-------------------------------------"

# Open services in browser
open_browser "http://localhost:8080"
open_browser "http://localhost:3001"

echo "Services started successfully!"
