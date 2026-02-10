# 🤖 Central News - AI Summary Backend

Backend system untuk generate AI-powered news summaries menggunakan **DeepSeek API**.

---

## 🎯 Fitur

- ✅ **RSS Fetcher** - Fetch berita dari 13+ sumber
- ✅ **AI Summarization** - Summary otomatis dengan DeepSeek AI
- ✅ **Caching System** - Hemat API calls dengan disk cache
- ✅ **REST API** - Flask server untuk Flutter app
- ✅ **Auto-Update** - Scheduled updates setiap X jam
- ✅ **Per-Category** - Summary terpisah per kategori

---

## 📁 File Structure

```
backend/
├── requirements.txt          # Python dependencies
├── .env.example              # Environment variables template
├── rss_fetcher.py            # Fetch RSS feeds
├── ai_summarizer.py          # DeepSeek AI summarization
├── summary_manager.py        # Cache & summary management
├── api_server.py             # Flask REST API server
├── scheduler.py              # Auto-update scheduler
├── setup.sh                  # Setup script
├── test_system.sh            # Test script
└── cache/                    # Summary cache (auto-created)
```

---

## 🚀 Quick Start

### **1. Setup Environment**

```bash
cd backend

# Run setup script
chmod +x setup.sh
./setup.sh
```

### **2. Configure API Key**

Edit `.env` file:

```bash
nano .env
```

Add your DeepSeek API key:

```env
DEEPSEEK_API_KEY=sk-your-actual-deepseek-api-key-here
```

### **3. Test Components**

```bash
# Activate venv
source venv/bin/activate

# Test RSS fetcher
python3 rss_fetcher.py

# Test AI summarizer (requires API key)
python3 ai_summarizer.py

# Test summary manager (dengan caching)
python3 summary_manager.py
```

### **4. Run API Server**

```bash
# Start Flask server
python3 api_server.py
```

Server akan berjalan di: **http://localhost:5000**

### **5. Test API**

```bash
# Health check
curl http://localhost:5000/api/health

# Get summary untuk ekonomi
curl http://localhost:5000/api/summary/ekonomi

# Get all summaries
curl http://localhost:5000/api/summaries

# Force refresh
curl -X POST http://localhost:5000/api/refresh/ekonomi
```

---

## 📡 API Endpoints

### **GET /api/summaries**

Get summaries untuk semua kategori

```bash
curl http://localhost:5000/api/summaries
```

**Response:**
```json
{
  "success": true,
  "data": {
    "ekonomi": {
      "category": "ekonomi",
      "summary": "Ringkasan berita ekonomi...",
      "highlights": ["Headline 1", "Headline 2"],
      "news_count": 45,
      "generated_at": "2024-12-09T10:30:00"
    },
    ...
  }
}
```

### **GET /api/summary/:category**

Get summary untuk kategori tertentu

```bash
curl http://localhost:5000/api/summary/teknologi
```

**Parameters:**
- `refresh=true` - Force refresh (skip cache)
- `max_news=20` - Max news items to process

### **POST /api/refresh/:category**

Force refresh summary untuk kategori

```bash
curl -X POST http://localhost:5000/api/refresh/ekonomi
```

### **GET /api/health**

Health check

```bash
curl http://localhost:5000/api/health
```

### **GET /api/cache/info**

Cache statistics

```bash
curl http://localhost:5000/api/cache/info
```

---

## ⚙️ Configuration

Edit `.env` file:

```env
# DeepSeek API
DEEPSEEK_API_KEY=your_api_key_here
DEEPSEEK_API_BASE=https://api.deepseek.com/v1

# Server
FLASK_PORT=5000
FLASK_HOST=0.0.0.0
FLASK_DEBUG=True

# Summary Config
MAX_NEWS_PER_CATEGORY=20
SUMMARY_MAX_LENGTH=500
CACHE_DURATION_HOURS=6

# Rate Limiting
MAX_REQUESTS_PER_HOUR=100
UPDATE_INTERVAL_HOURS=6
```

---

## 💾 Caching System

### **How It Works:**

1. **First Request** → Fetch RSS + Call AI → Cache result
2. **Subsequent Requests** → Serve from cache (no API call!)
3. **Cache Expires** (after 6 hours) → Auto refresh

### **Benefits:**

- ✅ **Hemat API Calls** - Reuse summary untuk 6 jam
- ✅ **Faster Response** - Serve dari cache (instant)
- ✅ **Cost Effective** - Minimal API usage
- ✅ **Reliable** - Fallback to cache if API down

### **Cache Location:**

```
backend/cache/
├── summary_ekonomi.cache
├── summary_teknologi.cache
└── ...
```

---

## 🤖 AI Summarization

### **Model:** DeepSeek Chat

### **Prompt Template:**

```
Berikut adalah kumpulan berita terkini kategori {category}:

1. [News title 1]
   [Description...]
   Sumber: [Source]

2. [News title 2]
   ...

Tugas Anda:
1. Buat rangkuman komprehensif dalam Bahasa Indonesia
2. Fokus pada tema utama, tren, dan poin penting
3. Maksimal 500 kata
4. Gunakan format paragraf yang mudah dibaca
5. Objektif dan informatif
```

### **Parameters:**

```python
model="deepseek-chat"
max_tokens=800
temperature=0.3  # Lower = more factual
```

---

## 🔄 Auto-Update Scheduler

Run scheduler untuk auto-update summary:

```bash
python3 scheduler.py
```

**Features:**
- ✅ Update otomatis setiap 6 jam (configurable)
- ✅ Runs in background
- ✅ Logs semua aktivitas
- ✅ Error handling

**Use Case:**
- Jalankan di VPS
- Auto-update summary tanpa manual trigger
- Always fresh news summaries

---

## 🧪 Testing

### **1. Test RSS Fetcher:**

```bash
python3 rss_fetcher.py
```

**Expected output:**
```
📰 Fetching EKONOMI...
✓ Fetched 15 items from DJPB Kemenkeu
✓ Fetched 20 items from Antara News Ekonomi
✓ Total 35 items for ekonomi
```

### **2. Test AI Summarizer:**

```bash
export DEEPSEEK_API_KEY=your_key
python3 ai_summarizer.py
```

**Expected output:**
```
✓ AI Summarizer initialized
🤖 Generating summary for ekonomi...
✓ Summary generated (450 chars)
```

### **3. Test Full System:**

```bash
python3 summary_manager.py
```

**Expected output:**
```
📰 FETCHING ALL CATEGORY SUMMARIES
✓ Summary generated for ekonomi
✓ Summary generated for teknologi
...
✓ All summaries ready!
```

### **4. Test API Server:**

```bash
# Terminal 1: Run server
python3 api_server.py

# Terminal 2: Test endpoints
curl http://localhost:5000/api/health
curl http://localhost:5000/api/summary/ekonomi
```

---

## 📊 Categories (sesuai Flutter app)

```
hukum_politik  - Hukum & Politik
ekonomi        - Ekonomi
pendidikan     - Pendidikan
kesehatan      - Kesehatan
teknologi      - Teknologi
nasional       - Nasional
```

---

## 💰 Cost Estimation

### **DeepSeek Pricing** (sangat murah):

- Input: ~$0.14 per 1M tokens
- Output: ~$0.28 per 1M tokens

### **Estimated Usage:**

Per summary:
- Input: ~3,000 tokens (20 news articles)
- Output: ~500 tokens (summary)
- Cost: ~$0.0006 per summary

Per kategori per hari (4 updates):
- 6 categories × 4 updates = 24 summaries
- Cost: ~$0.015 per day
- **~$0.45 per month** 💰

### **With Caching (6 hour TTL):**

- 6 categories × 4 updates = 24 summaries/day
- **~$0.015/day** or **~$0.45/month**

---

## 🔧 Troubleshooting

### **Error: No module named 'feedparser'**

```bash
source venv/bin/activate
pip install -r requirements.txt
```

### **Error: API key not set**

```bash
# Check .env file
cat .env

# Or set directly
export DEEPSEEK_API_KEY=your_key
```

### **Error: CORS blocked (web)**

Already handled with `flask-cors`

### **Error: Port 5000 in use**

```bash
# Change port in .env
FLASK_PORT=5001
```

---

## 🚀 Deployment (VPS)

### **1. Setup di VPS:**

```bash
# Clone/Upload project
cd /path/to/backend

# Run setup
./setup.sh

# Edit .env dengan API key
nano .env
```

### **2. Run dengan systemd:**

Create `/etc/systemd/system/central-news-api.service`:

```ini
[Unit]
Description=Central News AI Summary API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/backend
Environment="PATH=/path/to/backend/venv/bin"
ExecStart=/path/to/backend/venv/bin/python3 api_server.py
Restart=always

[Install]
WantedBy=multi-user.target
```

**Enable & start:**

```bash
sudo systemctl enable central-news-api
sudo systemctl start central-news-api
sudo systemctl status central-news-api
```

### **3. Run Scheduler:**

Create `/etc/systemd/system/central-news-scheduler.service`:

```ini
[Unit]
Description=Central News AI Summary Scheduler
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/backend
Environment="PATH=/path/to/backend/venv/bin"
ExecStart=/path/to/backend/venv/bin/python3 scheduler.py
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## 📚 Documentation

- **README.md** - This file (setup & usage)
- **API_DOCUMENTATION.md** - Complete API reference
- **DEPLOYMENT_GUIDE.md** - VPS deployment guide

---

## 🎯 Next Steps

1. ✅ Setup backend (`./setup.sh`)
2. ✅ Add API key to `.env`
3. ✅ Test components
4. ✅ Run API server
5. ✅ Update Flutter app to fetch summaries
6. ✅ Deploy to VPS (optional)

---

**Backend siap untuk testing di laptop!** 🚀

Run `./setup.sh` untuk memulai! 

