# 🚀 Deployment Guide - VPS Setup

## Deployment ke VPS untuk Production

---

## 📋 Prerequisites

- VPS dengan Linux (Ubuntu 20.04+ recommended)
- Python 3.8+
- Nginx (untuk reverse proxy)
- Domain/subdomain (optional)
- DeepSeek API key

---

## 🔧 Setup di VPS

### **Step 1: Install Dependencies**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python & pip
sudo apt install python3 python3-pip python3-venv -y

# Install Nginx
sudo apt install nginx -y

# Install supervisor (untuk process management)
sudo apt install supervisor -y
```

### **Step 2: Upload Backend**

```bash
# Via git
git clone your-repo-url
cd central-news/backend

# Or via scp
scp -r backend/ user@vps:/var/www/central-news/
```

### **Step 3: Setup Backend**

```bash
cd /var/www/central-news/backend

# Run setup
chmod +x setup.sh
./setup.sh

# Edit .env dengan production config
nano .env
```

**Production .env:**

```env
DEEPSEEK_API_KEY=your_production_key
FLASK_PORT=5000
FLASK_HOST=127.0.0.1  # Localhost (Nginx will proxy)
FLASK_DEBUG=False     # Production mode!
CACHE_DURATION_HOURS=6
UPDATE_INTERVAL_HOURS=6
```

### **Step 4: Configure Supervisor**

Create `/etc/supervisor/conf.d/central-news-api.conf`:

```ini
[program:central-news-api]
command=/var/www/central-news/backend/venv/bin/python3 api_server.py
directory=/var/www/central-news/backend
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/central-news-api.log
environment=PATH="/var/www/central-news/backend/venv/bin"
```

Create `/etc/supervisor/conf.d/central-news-scheduler.conf`:

```ini
[program:central-news-scheduler]
command=/var/www/central-news/backend/venv/bin/python3 scheduler.py
directory=/var/www/central-news/backend
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/central-news-scheduler.log
environment=PATH="/var/www/central-news/backend/venv/bin"
```

**Reload supervisor:**

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start central-news-api
sudo supervisorctl start central-news-scheduler
```

### **Step 5: Configure Nginx**

Create `/etc/nginx/sites-available/central-news-api`:

```nginx
server {
    listen 80;
    server_name api.centralnews.yourdomain.com;  # Your domain
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # CORS headers
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
        add_header Access-Control-Allow-Headers "Content-Type";
    }
}
```

**Enable site:**

```bash
sudo ln -s /etc/nginx/sites-available/central-news-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### **Step 6: SSL dengan Let's Encrypt (Optional)**

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d api.centralnews.yourdomain.com
```

---

## 🔍 Monitoring

### **Check Logs:**

```bash
# API server logs
sudo tail -f /var/log/central-news-api.log

# Scheduler logs
sudo tail -f /var/log/central-news-scheduler.log

# Nginx logs
sudo tail -f /var/log/nginx/access.log
```

### **Check Status:**

```bash
# Supervisor status
sudo supervisorctl status

# Nginx status
sudo systemctl status nginx

# Test API
curl http://localhost:5000/api/health
```

---

## 🔄 Update & Restart

```bash
# Update code
cd /var/www/central-news/backend
git pull

# Restart services
sudo supervisorctl restart central-news-api
sudo supervisorctl restart central-news-scheduler
```

---

## 💾 Backup

### **Cache Backup:**

```bash
# Backup cache
tar -czf cache-backup-$(date +%Y%m%d).tar.gz cache/

# Restore cache
tar -xzf cache-backup-20241209.tar.gz
```

---

## 📊 Performance

### **Expected Load:**

```
CPU: Low (~5% during summary generation)
RAM: ~100MB per worker
Disk: ~50MB for cache
Network: Minimal (RSS fetching only)
```

### **Scaling:**

```
Single VPS: 
- Handle 1000+ requests/day easily
- 6 categories × 4 updates = 24 AI calls/day
- Very low resource usage
```

---

## 🎯 Production Checklist

- [ ] VPS dengan Python 3.8+
- [ ] DeepSeek API key ready
- [ ] Domain/subdomain configured
- [ ] Nginx installed & configured
- [ ] SSL certificate (optional)
- [ ] Supervisor configured
- [ ] Firewall configured (port 80/443)
- [ ] Logs rotation setup
- [ ] Monitoring setup
- [ ] Backup strategy

---

**Ready untuk production deployment!** 🚀

