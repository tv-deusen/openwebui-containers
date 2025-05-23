<!-- Generated by SpecStory -->

# Understanding Docker Compose Healthchecks (2025-04-28 16:54:45)

_**User**_

Explain how healthcheck works

---

_**Assistant**_

Docker Compose “healthcheck” lets you tell Docker how to verify that each container is actually up and serving traffic before you consider it “healthy.”  Under the hood Docker will:

1. Run your specified test command inside the container.
2. Wait up to timeout for it to succeed.
3. Retry it every interval—up to retries times.
4. (Optionally) ignore failures during an initial start_period grace window.
5. Mark the container as UNHEALTHY if it still fails after all retries.

You can then use `docker ps` (look for the HEALTH column) or even conditionally block downstream services (with v2.1+ `depends_on.condition: service_healthy`) until a dependency is healthy.

Here’s how it’s set up in your compose file:

```22:27:docker-compose.yml
    healthcheck:
      test: ["CMD-SHELL", "echo > /dev/tcp/localhost/11434 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
```
- **test**: attempts a TCP open to port 11434 (the Ollama API port)  
- **interval**: wait 30 seconds between checks  
- **timeout**: if the test command hangs longer than 10 s, consider that a failure  
- **retries**: after 3 consecutive failures, mark the container unhealthy  
- **start_period**: allow a 30 s warm-up before counting failures  

```48:52:docker-compose.yml
    healthcheck:
      test: ["CMD-SHELL", "wget -q -O - http://localhost:8080 || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 20
```
- **test**: does an HTTP GET on port 8080 (Open WebUI’s web UI)  
- **interval**: every 10 seconds  
- **timeout**: give up after 5 s  
- **retries**: allow up to 20 failures (so it can survive a longer startup)  

And similarly for Uptime Kuma (checking `http://localhost:3001/health`).  

Once marked “healthy,” Docker knows the service is ready, and, if you’re using health-aware dependencies, it won’t start dependent containers until this check passes.

---

