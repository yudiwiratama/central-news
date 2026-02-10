#!/bin/bash

# Setup script untuk backend AI Summary System

echo "=================================================="
echo "🚀 CENTRAL NEWS - Backend Setup"
echo "=================================================="

# Check Python
echo ""
echo "📌 Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found! Please install Python 3.8+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
echo "✓ Found: $PYTHON_VERSION"

# Create virtual environment
echo ""
echo "📦 Creating virtual environment..."
if [ -d "venv" ]; then
    echo "⚠️  venv already exists, skipping..."
else
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

# Activate venv
echo ""
echo "🔌 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo ""
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo ""
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Create .env if not exists
if [ ! -f ".env" ]; then
    echo ""
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✓ .env created from .env.example"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env and add your DEEPSEEK_API_KEY!"
else
    echo ""
    echo "✓ .env file already exists"
fi

# Create cache directory
echo ""
echo "💾 Creating cache directory..."
mkdir -p cache
echo "✓ Cache directory ready"

# Summary
echo ""
echo "=================================================="
echo "✅ SETUP COMPLETE!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Edit .env file:"
echo "   nano .env"
echo "   (Add your DEEPSEEK_API_KEY)"
echo ""
echo "2. Test the system:"
echo "   python3 rss_fetcher.py"
echo "   python3 ai_summarizer.py"
echo "   python3 summary_manager.py"
echo ""
echo "3. Run API server:"
echo "   python3 api_server.py"
echo ""
echo "4. Or run scheduler (auto-update):"
echo "   python3 scheduler.py"
echo ""
echo "=================================================="

