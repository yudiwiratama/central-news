"""
RSS News Fetcher
Fetches news from Indonesian RSS feeds per category
"""

import feedparser
import requests
from datetime import datetime
from typing import List, Dict, Optional
import re


class RSSFetcher:
    """Fetch and parse RSS feeds"""
    
    # RSS Feeds per category (matching Flutter app)
    FEEDS = {
        'hukum_politik': [
            {
                'url': 'https://www.antaranews.com/rss/politik.xml',
                'source': 'Antara News Politik'
            },
            {
                'url': 'https://www.antaranews.com/rss/hukum.xml',
                'source': 'Antara News Hukum'
            },
        ],
        'ekonomi': [
            {
                'url': 'https://djpb.kemenkeu.go.id/portal/id/berita.feed?type=rss',
                'source': 'DJPB Kemenkeu'
            },
            {
                'url': 'https://www.antaranews.com/rss/ekonomi.xml',
                'source': 'Antara News Ekonomi'
            },
            {
                'url': 'https://www.cnbcindonesia.com/market/rss',
                'source': 'CNBC Indonesia Market'
            },
        ],
        'pendidikan': [
            {
                'url': 'https://www.detik.com/edu/rss',
                'source': 'Detik Edu'
            },
            {
                'url': 'https://edukasi.sindonews.com/rss',
                'source': 'Sindonews Edukasi'
            },
        ],
        'kesehatan': [
            {
                'url': 'https://kemkes.go.id/id/rss/article/kegiatan-kemenkes',
                'source': 'Kementerian Kesehatan'
            },
            {
                'url': 'https://health.detik.com/rss',
                'source': 'Detik Health'
            },
        ],
        'teknologi': [
            {
                'url': 'https://www.cnbcindonesia.com/tech/rss',
                'source': 'CNBC Indonesia Tech'
            },
            {
                'url': 'https://www.antaranews.com/rss/tekno.xml',
                'source': 'Antara News Tekno'
            },
        ],
        'nasional': [
            {
                'url': 'https://rss.tempo.co/nasional',
                'source': 'Tempo Nasional'
            },
            {
                'url': 'https://www.cnnindonesia.com/nasional/rss',
                'source': 'CNN Indonesia Nasional'
            },
        ],
    }
    
    @staticmethod
    def clean_html(text: str) -> str:
        """Remove HTML tags and clean text"""
        if not text:
            return ""
        
        # Remove HTML tags
        clean = re.sub(r'<[^>]+>', '', text)
        
        # Decode HTML entities
        clean = clean.replace('&nbsp;', ' ')
        clean = clean.replace('&amp;', '&')
        clean = clean.replace('&lt;', '<')
        clean = clean.replace('&gt;', '>')
        clean = clean.replace('&quot;', '"')
        clean = clean.replace('&#39;', "'")
        
        # Remove extra whitespace
        clean = re.sub(r'\s+', ' ', clean).strip()
        
        return clean
    
    @classmethod
    def fetch_feed(cls, url: str, source: str, max_items: int = 20) -> List[Dict]:
        """Fetch and parse a single RSS feed"""
        try:
            # Set User-Agent to avoid blocking
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
            
            response = requests.get(url, headers=headers, timeout=15)
            response.raise_for_status()
            
            feed = feedparser.parse(response.content)
            
            news_items = []
            for entry in feed.entries[:max_items]:
                item = {
                    'title': entry.get('title', '').strip(),
                    'description': cls.clean_html(entry.get('description', '')),
                    'link': entry.get('link', ''),
                    'pub_date': entry.get('published', ''),
                    'source': source,
                }
                
                # Only add if has title and link
                if item['title'] and item['link']:
                    news_items.append(item)
            
            print(f"✓ Fetched {len(news_items)} items from {source}")
            return news_items
            
        except Exception as e:
            print(f"✗ Error fetching {source}: {e}")
            return []
    
    @classmethod
    def fetch_category(cls, category: str, max_items: int = 20) -> List[Dict]:
        """Fetch all feeds for a category"""
        if category not in cls.FEEDS:
            print(f"✗ Unknown category: {category}")
            return []
        
        all_news = []
        feeds = cls.FEEDS[category]
        
        print(f"\n📰 Fetching {category.upper()}...")
        
        for feed in feeds:
            items = cls.fetch_feed(feed['url'], feed['source'], max_items)
            all_news.extend(items)
        
        print(f"✓ Total {len(all_news)} items for {category}")
        return all_news
    
    @classmethod
    def fetch_all_categories(cls, max_items_per_feed: int = 20) -> Dict[str, List[Dict]]:
        """Fetch news from all categories"""
        results = {}
        
        for category in cls.FEEDS.keys():
            results[category] = cls.fetch_category(category, max_items_per_feed)
        
        return results


if __name__ == '__main__':
    # Test fetcher
    print("Testing RSS Fetcher...")
    
    # Test single category
    ekonomi_news = RSSFetcher.fetch_category('ekonomi', max_items=5)
    print(f"\nEkonomi news count: {len(ekonomi_news)}")
    
    if ekonomi_news:
        print("\nSample news:")
        print(f"Title: {ekonomi_news[0]['title']}")
        print(f"Source: {ekonomi_news[0]['source']}")
        print(f"Description: {ekonomi_news[0]['description'][:100]}...")

