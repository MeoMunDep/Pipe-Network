# 🌐 Pipe Network - PoP Cache Node Setup (Linux)

This guide walks you through installing, configuring, and running a Pipe Network CDN PoP (Point-of-Presence) Cache Node on Linux.

---

## 📋 Requirements

**Minimum Recommended System Specs:**

* **CPU:** 4+ cores
* **RAM:** 16GB+
* **Disk:** 100GB+ SSD
* **Network:** 1Gbps+

---

## ⚙️ 1. System Preparation

### Create a dedicated user (optional)

```bash
sudo su -
sudo useradd -m -s /bin/bash popcache
sudo usermod -aG sudo popcache
```

### Install required dependencies

```bash
sudo apt update -y
sudo apt install -y libssl-dev ca-certificates
```

---

## 🚀 2. System Optimization

### Create sysctl config for networking

```bash
sudo bash -c 'cat > /etc/sysctl.d/99-popcache.conf << EOL
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
EOL'

sudo sysctl -p /etc/sysctl.d/99-popcache.conf
```

### Set file limits

```bash
sudo bash -c 'cat > /etc/security/limits.d/popcache.conf << EOL
*    soft nofile 65535
*    hard nofile 65535
EOL'
```

Log out and back in for limits to take effect.

---

## 📦 3. Install the Binary

```bash
sudo mkdir -p /opt/popcache/logs
cd /opt/popcache
# Download from: https://download.pipe.network/
```

> 🔑 You’ll need an **invite code** from the [registration form](https://airtable.com/apph9N7T0WlrPqnyc/pagSLmmUFNFbnKVZh/form)

---

## 🛠 4. Configuration

Create the configuration file:

```bash
./pop create-config /opt/popcache
nano /opt/popcache/config.json
```

### Sample `config.json`

```json
{
  "pop_name": "your-pop-name",
  "pop_location": "Your Location, Country",
  "invite_code": "your-invite-code",
  "server": {
    "host": "0.0.0.0",
    "port": 443,
    "http_port": 80,
    "workers": 0
  },
  "cache_config": {
    "memory_cache_size_mb": 8192,
    "disk_cache_path": "./cache",
    "disk_cache_size_gb": 100,
    "default_ttl_seconds": 86400,
    "respect_origin_headers": true,
    "max_cacheable_size_mb": 1024
  },
  "api_endpoints": {
    "base_url": "https://dataplane.pipenetwork.com"
  },
  "identity_config": {
    "node_name": "your-node-name",
    "name": "Your Name",
    "email": "your.email@example.com",
    "website": "https://your-site.com",
    "twitter": "your_twitter",
    "discord": "your_discord",
    "telegram": "your_telegram",
    "solana_pubkey": "YOUR_SOLANA_ADDRESS"
  }
}
```

Validate config:

```bash
./pop --validate-config
```

---

## 🔁 5. Systemd Service Setup

```bash
sudo nano /etc/systemd/system/popcache.service
```

Paste:

```ini
[Unit]
Description=POP Cache Node
After=network.target

[Service]
Type=simple
User=popcache
Group=popcache
WorkingDirectory=/opt/popcache
ExecStart=/opt/popcache/pop
Restart=always
RestartSec=5
LimitNOFILE=65535
StandardOutput=append:/opt/popcache/logs/stdout.log
StandardError=append:/opt/popcache/logs/stderr.log
Environment=POP_CONFIG_PATH=/opt/popcache/config.json

[Install]
WantedBy=multi-user.target
```

Start the service:

```bash
sudo systemctl daemon-reload
sudo systemd-analyze verify popcache
sudo systemctl enable --now popcache
```

Check status:

```bash
sudo systemctl status popcache
```

---

## 📑 6. Logs

### Live log view

```bash
tail -f /opt/popcache/logs/stdout.log
tail -f /opt/popcache/logs/stderr.log
```

### Journal logs

```bash
sudo journalctl -u popcache -f
```

### Enable log rotation

```bash
sudo nano /etc/logrotate.d/popcache
```

```bash
/opt/popcache/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 popcache popcache
    sharedscripts
    postrotate
    systemctl reload popcache >/dev/null 2>&1 || true
    endscript
}
```

---

## 🔥 7. Firewall Configuration

### UFW

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### iptables

```bash
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

---

## 📊 8. Monitoring

Basic endpoints:

```bash
curl http://localhost/state
curl http://localhost/metrics
curl http://localhost/health
```

---

## 🧯 9. Troubleshooting

### Common issues:

* **Check logs**

  ```bash
  sudo journalctl -u popcache -n 100
  ```

* **Permissions**

  ```bash
  sudo chmod 755 /opt/popcache/pop
  sudo chown -R popcache:popcache /opt
  ```

* **Ports in use**

  ```bash
  sudo netstat -tuln | grep -E ':(80|443)'
  ```

---

## 🙋 Support

* 📩 Get an invite: [Pipe Network Invite Form](https://airtable.com/apph9N7T0WlrPqnyc/pagSLmmUFNFbnKVZh/form)
* 💬 Ask on Discord, Twitter, or Telegram
* 🌐 [https://pipe.network](https://pipe.network)


