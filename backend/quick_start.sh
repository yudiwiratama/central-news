#!/bin/bash

# Quick Start Script - Test AI Summary di Laptop

echo "╔════════════════════════════════════════════════╗"
echo "║  🤖 CENTRAL NEWS - AI SUMMARY QUICK START    ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Check if already setup
if [ ! -d "venv" ]; then
    echo "📦 Running initial setup..."
    ./setup.sh
    echo ""
fi

# Check API key
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "   Create .env from .env.example and add your DEEPSEEK_API_KEY"
    exit 1
fi

# Load .env
export $(cat .env | grep -v '^#' | xargs)

if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "❌ DEEPSEEK_API_KEY not set in .env!"
    echo ""
    echo "Please edit .env and add your API key:"
    echo "  nano .env"
    echo ""
    echo "Get API key from: https://platform.deepseek.com/"
    exit 1
fi

echo "✓ API key configured"
echo ""

# Activate venv
source venv/bin/activate

# Quick test
echo "🧪 Quick test..."
python3 -c "
from rss_fetcher import RSSFetcher
print('✓ RSS Fetcher ready')
from ai_summarizer import AISummarizer
print('✓ AI Summarizer ready')
from summary_manager import SummaryManager
print('✓ Summary Manager ready')
"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  ✅ BACKEND READY!                            ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "🚀 Starting API server..."
echo ""
echo "Server akan running di: http://localhost:5000"
echo ""
echo "Test endpoints:"
echo "  curl http://localhost:5000/api/health"
echo "  curl http://localhost:5000/api/summary/ekonomi"
echo ""
echo "Tekan Ctrl+C untuk stop server"
echo ""
echo "════════════════════════════════════════════════"
echo ""

# Run API server
python3 api_server.py

