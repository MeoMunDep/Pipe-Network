# 🌐 Pipe Network — PoP Cache Node Setup (Linux)

A high-performance caching node that distributes content across Pipe's decentralized CDN network. This guide covers setup, configuration, monitoring, and referral systems.

---

## 🧰 Requirements

* **Linux-based OS**
* **RAM**: 4GB+ (more RAM = better rewards)
* **Disk**: 100GB+ free (200–500GB optimal)
* **Internet**: 24/7 uptime required
* **Ports**: 8003, 80, 443 must be open
* **Privileges**: Required for ports 80/443 (run with `sudo` or systemd capabilities)

---

## ⚡ Quick Install

```bash
# Download latest binary
curl -L -o pop "https://dl.pipecdn.app/v0.2.8/pop"

# Make it executable
chmod +x pop

# Create download cache folder
mkdir download_cache

# Run (defaults: 4GB RAM, 100GB disk, ports 8003/443/80)
sudo ./pop
```

---

## ⚙️ Custom Run Example

```bash
sudo ./pop \
  --ram 8 \
  --max-disk 500 \
  --cache-dir /data \
  --pubKey <YOUR_SOLANA_PUBKEY>
```

---

## 📊 Monitoring

```bash
./pop --status           # View metrics
./pop --points-route     # (Future) point system
```

---

## 🧑‍🤝‍🧑 Referral System

* Generate referral:

  ```bash
  ./pop --gen-referral-route
  ```

* Register with referral:

  ```bash
  sudo ./pop --signup-by-referral-route <CODE>
  ```

> Referrer earns 10 points after 7+ days of uptime & good reputation from the referred node.

Check stats at: [https://dashboard.pipenetwork.com/node-lookup](https://dashboard.pipenetwork.com/node-lookup)

---

## 🔁 Systemd Service Setup

```bash
# Create user and directories
sudo useradd -r -m -s /sbin/nologin pop-svc-user -d /home/pop-svc-user
sudo mkdir -p /opt/pop /var/lib/pop /var/cache/pop/download_cache

# Move binary and files
sudo mv -f ~/pop /opt/pop/
sudo chmod +x /opt/pop/pop
sudo mv -f ~/node_info.json /var/lib/pop/ 2>/dev/null || true

# Set ownership
sudo chown -R pop-svc-user:pop-svc-user /opt/pop /var/lib/pop /var/cache/pop

# Create systemd service
sudo tee /etc/systemd/system/pop.service << 'EOF'
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
User=pop-svc-user
Group=pop-svc-user
ExecStart=/opt/pop/pop \
    --ram=12 \
    --pubKey=<YOUR_SOLANA_PUBKEY> \
    --max-disk=175 \
    --cache-dir=/var/cache/pop/download_cache \
    --no-prompt
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
WorkingDirectory=/var/lib/pop

[Install]
WantedBy=multi-user.target
EOF

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable pop.service
sudo systemctl start pop.service
```

### ✅ Helpful Alias

```bash
echo "alias pop='cd /var/lib/pop && /opt/pop/pop'" >> ~/.bashrc
source ~/.bashrc
```

---

## 🔐 Firewall

```bash
sudo ufw allow 8003/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

---

## 💾 Backup & Upgrade

### Backup node

```bash
cp /var/lib/pop/node_info.json ~/node_info.backup-$(date +%F)
```

### Upgrade node

```bash
curl -L -o pop "https://dl.pipecdn.app/v0.2.8/pop"
chmod +x pop
sudo mv ./pop /opt/pop/pop
cd /var/lib/pop
pop --refresh
```

If needed:

```bash
sudo setcap 'cap_net_bind_service=+ep' /opt/pop/pop
```

---

## 🧠 Reputation System

Your node score (0–1) is calculated from:

| Metric       | Weight | Notes                                                       |
| ------------ | ------ | ----------------------------------------------------------- |
| Uptime Score | 40%    | Based on hourly reports; 18+ hours/day = good coverage      |
| Historical   | 30%    | Days with good coverage in last 7 days                      |
| Egress Score | 30%    | Based on data transferred (target: 1TB/day, capped at 100%) |

**Score Impact:**

* `> 0.7` = P2P priority
* `> 0.5` = Referral eligibility

Check:

```bash
./pop --status
```

---

## 📁 File Info

* `node_info.json`: Critical config (do NOT lose it)
* `download_cache/`: Cached files
* **Logs**: Stream to stdout, updated every 5 minutes

---

## 🧼 Decommission Old DevNet1 Node

```bash
sudo systemctl stop dcdnd.service
sudo systemctl disable dcdnd.service
```

---

## 📚 Resources

* **Docs**: [Pipe CDN Docs](https://docs.pipe.network)
* **Dashboard**: [Node Lookup](https://dashboard.pipenetwork.com/node-lookup)
* **Join**: [Register PoP Node](https://airtable.com/apph9N7T0WlrPqnyc/pagSLmmUFNFbnKVZh/form)

