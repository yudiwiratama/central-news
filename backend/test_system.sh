#!/bin/bash

# Test script untuk backend system

echo "=================================================="
echo "🧪 TESTING CENTRAL NEWS BACKEND"
echo "=================================================="

# Activate venv
if [ -d "venv" ]; then
    echo "🔌 Activating virtual environment..."
    source venv/bin/activate
else
    echo "❌ Virtual environment not found! Run ./setup.sh first"
    exit 1
fi

# Check API key
if [ ! -f ".env" ]; then
    echo "❌ .env file not found! Copy from .env.example"
    exit 1
fi

# Load .env
export $(cat .env | grep -v '^#' | xargs)

if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "❌ DEEPSEEK_API_KEY not set in .env!"
    exit 1
fi

echo "✓ API key found"
echo ""

# Test 1: RSS Fetcher
echo "=================================================="
echo "📌 TEST 1: RSS Fetcher"
echo "=================================================="
python3 rss_fetcher.py
echo ""

# Test 2: AI Summarizer (single category)
echo "=================================================="
echo "📌 TEST 2: AI Summarizer"
echo "=================================================="
python3 ai_summarizer.py
echo ""

# Test 3: Summary Manager (dengan caching)
echo "=================================================="
echo "📌 TEST 3: Summary Manager"
echo "=================================================="
python3 summary_manager.py
echo ""

# Test 4: API Server (background)
echo "=================================================="
echo "📌 TEST 4: API Server"
echo "=================================================="
echo "Starting API server in background..."
python3 api_server.py &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Test endpoints
echo ""
echo "Testing endpoints..."

echo "1. Health check:"
curl -s http://localhost:5000/api/health | python3 -m json.tool

echo ""
echo "2. Get ekonomi summary:"
curl -s http://localhost:5000/api/summary/ekonomi | python3 -m json.tool

echo ""
echo "3. Cache info:"
curl -s http://localhost:5000/api/cache/info | python3 -m json.tool

# Stop server
echo ""
echo "Stopping test server..."
kill $SERVER_PID

echo ""
echo "=================================================="
echo "✅ ALL TESTS COMPLETE!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Run API server:"
echo "   python3 api_server.py"
echo ""
echo "2. Or run scheduler:"
echo "   python3 scheduler.py"
echo ""
echo "3. Update Flutter app to connect to:"
echo "   http://localhost:5000"
echo ""

