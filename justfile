# Default command to run when 'just' is executed without arguments
default: start

# Check for NVIDIA GPU availability
check-gpu:
    @if command -v nvidia-smi &> /dev/null; then echo "NVIDIA GPU detected:"; nvidia-smi; else echo "WARNING: NVIDIA GPU not detected. GPU acceleration may not be available."; fi

# Check if Docker daemon is running
check-docker:
    @if ! docker info &> /dev/null; then \
        echo "Docker daemon is not running. Attempting to start it..."; \
        if [ "$(uname)" = "Linux" ]; then \
            sudo systemctl start docker; \
        elif [ "$(uname)" = "Darwin" ]; then \
            open -a Docker; \
        else \
            echo "Please start Docker manually for your OS."; \
        fi; \
        sleep 3; \
        if ! docker info &> /dev/null; then \
            echo "ERROR: Docker daemon could not be started. Please start Docker and try again."; \
            exit 1; \
        fi; \
    fi

# Create a backup of all volumes (maintains single backup file)
create-backup:
    @echo "Creating backup of volumes..."
    @mkdir -p ./backups
    @echo "Creating backup of all services..."
    @docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v $$PWD/backups:/archive \
        -v ollama-data:/backup/ollama-data:ro \
        -v open-webui-data:/backup/open-webui-data:ro \
        -v uptime-kuma-data:/backup/uptime-kuma-data:ro \
        offen/docker-volume-backup:latest \
        backup \
        --filename "services-backup" \
        --overwrite \
    && echo "✅ Backup created successfully at ./backups/services-backup.tar.gz" \
    || echo "❌ Backup failed"

# Restore from the backup
restore-backup:
    @echo "Restoring from backup..."
    @if [ ! -f "./backups/services-backup.tar.gz" ]; then \
        echo "❌ Backup file not found: ./backups/services-backup.tar.gz"; \
        exit 1; \
    fi; \
    echo "⚠️  WARNING: This will overwrite current volumes with backup data."; \
    echo "Press Ctrl+C to cancel or Enter to continue..."; \
    read CONFIRM; \
    echo "Stopping services..."; \
    docker compose down; \
    echo "Restoring volumes..."; \
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $$PWD/backups:/archive \
        -v ollama-data:/restore/ollama-data \
        -v open-webui-data:/restore/open-webui-data \
        -v uptime-kuma-data:/restore/uptime-kuma-data \
        offen/docker-volume-backup:latest \
        restore \
        --archive "/archive/services-backup.tar.gz" \
    && echo "✅ Restore completed successfully" \
    || echo "❌ Restore failed"

# Start all services using the helper script (includes health checks and browser opening)
# Ensures the script is executable first.
start: check-docker check-gpu
    @echo "Ensuring start script is executable..."
    @chmod +x ./start-services.sh
    @echo "Starting services via script..."
    @./start-services.sh

# Stop running services (keeps containers and networks)
stop: check-docker create-backup
    @echo "Stopping services..."
    @docker compose stop

# Stop and remove containers and networks (keeps volumes)
down: check-docker create-backup
    @echo "Stopping and removing containers and networks..."
    @docker compose down

# Stop and remove containers, networks, AND associated volumes (use with caution!)
clean: check-docker
    @echo "⚠️  WARNING: This will delete all data in volumes! Consider creating a backup first."
    @echo "Run 'just create-backup' to make a backup before proceeding."
    @echo "Press Ctrl+C to cancel or Enter to continue..."
    @read CONFIRM
    @echo "Stopping and removing containers, networks, and volumes..."
    @docker compose down --volumes

# Rebuild images, then stop and start services
rebuild: check-docker down
    @echo "Rebuilding images and restarting services..."
    @docker compose up -d --build --force-recreate
    # Note: This bypasses the start-services.sh health checks and browser opening.
    # Run 'just start' afterwards if you need that behavior.

# Follow logs for all services
logs: check-docker
    @echo "Following logs for all services (including watchtower)..."
    @docker compose logs -f

# Follow logs for a specific service (e.g., just logs ollama | just logs watchtower)
logs-service service: check-docker
    @echo "Following logs for service '{{ service }}'..."
    @docker compose logs -f {{ service }}

# List running services and their status
status: check-docker
    @echo "Checking service status (including watchtower)..."
    @docker compose ps

# Pull the latest images for all services
pull: check-docker
    @echo "Pulling latest images (including watchtower)..."

