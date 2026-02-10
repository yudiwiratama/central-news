"""
Flask API Server for News Summaries
Serves AI-generated summaries to Flutter app
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv
import os
from summary_manager import SummaryManager
from datetime import datetime

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter web

# Initialize Summary Manager
api_key = os.getenv('DEEPSEEK_API_KEY')
if not api_key:
    print("⚠️  WARNING: DEEPSEEK_API_KEY not set!")
    print("   Set it in .env file or environment variable")

try:
    summary_manager = SummaryManager(api_key) if api_key else None
    print("✓ API Server initialized")
except Exception as e:
    print(f"✗ Error initializing summary manager: {e}")
    summary_manager = None


@app.route('/')
def index():
    """API Info"""
    return jsonify({
        'name': 'Central News - AI Summary API',
        'version': '1.0.0',
        'status': 'running',
        'endpoints': {
            'summaries': '/api/summaries (GET all summaries)',
            'category': '/api/summary/<category> (GET single category)',
            'refresh': '/api/refresh/<category> (POST refresh summary)',
            'health': '/api/health (GET server health)',
            'cache': '/api/cache/info (GET cache info)',
        },
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'manager_ready': summary_manager is not None,
        'api_key_set': api_key is not None,
        'timestamp': datetime.now().isoformat(),
    })


@app.route('/api/summaries')
def get_all_summaries():
    """Get summaries for all categories"""
    if not summary_manager:
        return jsonify({
            'error': 'Summary manager not initialized. Check API key.'
        }), 500
    
    try:
        force_refresh = request.args.get('refresh', 'false').lower() == 'true'
        max_news = int(request.args.get('max_news', '20'))
        
        summaries = summary_manager.get_all_summaries(
            force_refresh=force_refresh,
            max_news=max_news
        )
        
        return jsonify({
            'success': True,
            'data': summaries,
            'timestamp': datetime.now().isoformat(),
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/summary/<category>')
def get_category_summary(category):
    """Get summary for a specific category"""
    if not summary_manager:
        return jsonify({
            'error': 'Summary manager not initialized. Check API key.'
        }), 500
    
    try:
        force_refresh = request.args.get('refresh', 'false').lower() == 'true'
        max_news = int(request.args.get('max_news', '20'))
        
        summary = summary_manager.get_summary(
            category,
            force_refresh=force_refresh,
            max_news=max_news
        )
        
        return jsonify({
            'success': True,
            'data': summary,
            'timestamp': datetime.now().isoformat(),
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/refresh/<category>', methods=['POST'])
def refresh_category_summary(category):
    """Force refresh summary for a category"""
    if not summary_manager:
        return jsonify({
            'error': 'Summary manager not initialized. Check API key.'
        }), 500
    
    try:
        max_news = int(request.args.get('max_news', '20'))
        
        # Clear cache first
        summary_manager.clear_cache(category)
        
        # Generate new summary
        summary = summary_manager.get_summary(
            category,
            force_refresh=True,
            max_news=max_news
        )
        
        return jsonify({
            'success': True,
            'data': summary,
            'message': f'Summary refreshed for {category}',
            'timestamp': datetime.now().isoformat(),
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/cache/info')
def get_cache_info():
    """Get cache information"""
    if not summary_manager:
        return jsonify({
            'error': 'Summary manager not initialized.'
        }), 500
    
    try:
        cache_info = summary_manager.get_cache_info()
        return jsonify({
            'success': True,
            'data': cache_info,
            'timestamp': datetime.now().isoformat(),
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/cache/clear', methods=['POST'])
def clear_cache():
    """Clear all cache"""
    if not summary_manager:
        return jsonify({
            'error': 'Summary manager not initialized.'
        }), 500
    
    try:
        category = request.args.get('category')
        summary_manager.clear_cache(category)
        
        return jsonify({
            'success': True,
            'message': f'Cache cleared for {category}' if category else 'All cache cleared',
            'timestamp': datetime.now().isoformat(),
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


if __name__ == '__main__':
    port = int(os.getenv('FLASK_PORT', '5000'))
    host = os.getenv('FLASK_HOST', '0.0.0.0')
    debug = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    
    print("\n" + "="*50)
    print("🚀 CENTRAL NEWS - AI SUMMARY API SERVER")
    print("="*50)
    print(f"📡 Running on: http://{host}:{port}")
    print(f"🔑 API Key set: {'Yes' if api_key else 'No'}")
    print(f"💾 Cache enabled: Yes")
    print(f"⏱️  Cache duration: {os.getenv('CACHE_DURATION_HOURS', '6')} hours")
    print("="*50)
    print("\nEndpoints:")
    print("  GET  /api/summaries          - Get all summaries")
    print("  GET  /api/summary/<category> - Get single summary")
    print("  POST /api/refresh/<category> - Force refresh")
    print("  GET  /api/cache/info         - Cache statistics")
    print("  POST /api/cache/clear        - Clear cache")
    print("  GET  /api/health             - Health check")
    print("\n" + "="*50 + "\n")
    
    app.run(host=host, port=port, debug=debug)

