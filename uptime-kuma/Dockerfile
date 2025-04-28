FROM louislam/uptime-kuma:1

RUN apt-get update \
 && apt-get install -y iputils-ping \
 && rm -rf /var/lib/apt/lists/*

CMD ["npm", "run", "start"]