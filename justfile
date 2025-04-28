# Default command to run when 'just' is executed without arguments
default: start

# Check for NVIDIA GPU availability
check-gpu:
    @if command -v nvidia-smi &> /dev/null; then echo "NVIDIA GPU detected:"; nvidia-smi; else echo "WARNING: NVIDIA GPU not detected. GPU acceleration may not be available."; fi

# Start all services using the helper script (includes health checks and browser opening)

# Ensures the script is executable first.
start: check-gpu
    @echo "Ensuring start script is executable..."
    @chmod +x ./start-services.sh
    @echo "Starting services via script..."
    @./start-services.sh

# Stop running services (keeps containers and networks)
stop:
    @echo "Stopping services..."
    @docker compose stop

# Stop and remove containers and networks (keeps volumes)
down:
    @echo "Stopping and removing containers and networks..."
    @docker compose down

# Stop and remove containers, networks, AND associated volumes (use with caution!)
clean:
    @echo "Stopping and removing containers, networks, and volumes..."
    @docker compose down --volumes

# Rebuild images, then stop and start services
rebuild: down
    @echo "Rebuilding images and restarting services..."
    @docker compose up -d --build --force-recreate
    # Note: This bypasses the start-services.sh health checks and browser opening.
    # Run 'just start' afterwards if you need that behavior.

# Follow logs for all services
logs:
    @echo "Following logs for all services..."
    @docker compose logs -f

# Follow logs for a specific service (e.g., just logs ollama)
logs-service service:
    @echo "Following logs for service '{{ service }}'..."
    @docker compose logs -f {{ service }}

# List running services and their status
status:
    @echo "Checking service status..."
    @docker compose ps

# Pull the latest images for all services
pull:
    @echo "Pulling latest images..."
    @docker compose pull
