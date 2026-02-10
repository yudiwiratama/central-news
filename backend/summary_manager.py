"""
Summary Manager with Caching
Manages AI summaries with disk caching to save API calls
"""

import json
import os
from datetime import datetime, timedelta
from typing import Dict, Optional
from diskcache import Cache
from rss_fetcher import RSSFetcher
from ai_summarizer import AISummarizer


class SummaryManager:
    """Manage news summaries with caching"""
    
    def __init__(self, api_key: str, cache_dir: str = './cache'):
        """Initialize with API key and cache directory"""
        self.fetcher = RSSFetcher()
        self.summarizer = AISummarizer(api_key)
        self.cache = Cache(cache_dir)
        self.cache_duration_hours = int(os.getenv('CACHE_DURATION_HOURS', '6'))
        
        print(f"✓ Summary Manager initialized (cache: {cache_dir})")
    
    def get_summary(
        self,
        category: str,
        force_refresh: bool = False,
        max_news: int = 20
    ) -> Dict:
        """
        Get summary for a category (from cache or generate new)
        
        Args:
            category: Category ID
            force_refresh: Force new summary (skip cache)
            max_news: Maximum news items to process
            
        Returns:
            Summary dict with text, highlights, and metadata
        """
        cache_key = f"summary_{category}"
        
        # Check cache first (unless force refresh)
        if not force_refresh:
            cached = self.cache.get(cache_key)
            if cached:
                # Check if cache is still valid
                generated_at = datetime.fromisoformat(cached['generated_at'])
                age_hours = (datetime.now() - generated_at).total_seconds() / 3600
                
                if age_hours < self.cache_duration_hours:
                    print(f"📦 Using cached summary for {category} (age: {age_hours:.1f}h)")
                    return cached
        
        # Generate new summary
        print(f"🔄 Generating new summary for {category}...")
        
        # Fetch news
        news_items = self.fetcher.fetch_category(category, max_news)
        
        # Generate summary
        summary = self.summarizer.summarize_category(category, news_items)
        
        # Cache the result
        self.cache.set(
            cache_key,
            summary,
            expire=self.cache_duration_hours * 3600  # Convert to seconds
        )
        
        return summary
    
    def get_all_summaries(
        self,
        force_refresh: bool = False,
        max_news: int = 20
    ) -> Dict[str, Dict]:
        """Get summaries for all categories"""
        summaries = {}
        
        print("\n" + "="*50)
        print("📰 FETCHING ALL CATEGORY SUMMARIES")
        print("="*50)
        
        for category in RSSFetcher.FEEDS.keys():
            summaries[category] = self.get_summary(category, force_refresh, max_news)
        
        print("\n✓ All summaries ready!")
        return summaries
    
    def clear_cache(self, category: Optional[str] = None):
        """Clear cache for a category or all"""
        if category:
            self.cache.delete(f"summary_{category}")
            print(f"✓ Cache cleared for {category}")
        else:
            self.cache.clear()
            print("✓ All cache cleared")
    
    def get_cache_info(self) -> Dict:
        """Get cache statistics"""
        stats = {
            'cache_size': len(self.cache),
            'cache_dir': self.cache.directory,
            'cached_categories': [],
        }
        
        for category in RSSFetcher.FEEDS.keys():
            cache_key = f"summary_{category}"
            if cache_key in self.cache:
                cached = self.cache.get(cache_key)
                generated_at = datetime.fromisoformat(cached['generated_at'])
                age_hours = (datetime.now() - generated_at).total_seconds() / 3600
                
                stats['cached_categories'].append({
                    'category': category,
                    'age_hours': round(age_hours, 2),
                    'news_count': cached.get('news_count', 0),
                })
        
        return stats


if __name__ == '__main__':
    # Test summary manager
    from dotenv import load_dotenv
    load_dotenv()
    
    api_key = os.getenv('DEEPSEEK_API_KEY')
    
    if not api_key:
        print("⚠️  Set DEEPSEEK_API_KEY in .env file")
        exit(1)
    
    manager = SummaryManager(api_key)
    
    # Test single category
    print("\nTesting single category...")
    summary = manager.get_summary('ekonomi', max_news=5)
    
    print("\n" + "="*50)
    print(f"CATEGORY: {summary['category']}")
    print("="*50)
    print(summary['summary'])
    print(f"\nHighlights: {len(summary['highlights'])} items")
    print(f"News count: {summary['news_count']}")
    
    # Show cache info
    print("\n" + "="*50)
    print("CACHE INFO")
    print("="*50)
    cache_info = manager.get_cache_info()
    print(json.dumps(cache_info, indent=2))

