"""
AI News Summarizer using DeepSeek API
Summarizes news articles per category
"""

import os
import requests
from typing import List, Dict, Optional
from datetime import datetime
import json


class AISummarizer:
    """Summarize news using DeepSeek API"""
    
    def __init__(self, api_key: Optional[str] = None):
        """Initialize with DeepSeek API key"""
        self.api_key = api_key or os.getenv('DEEPSEEK_API_KEY')
        
        if not self.api_key:
            raise ValueError("DeepSeek API key not provided!")
        
        self.api_base = os.getenv('DEEPSEEK_API_BASE', 'https://api.deepseek.com')
        self.api_url = f"{self.api_base}/chat/completions"
        
        print("✓ AI Summarizer initialized with DeepSeek API")
    
    def summarize_category(
        self,
        category: str,
        news_items: List[Dict],
        max_length: int = 500
    ) -> Dict:
        """
        Summarize news for a category
        
        Args:
            category: Category name (e.g., 'ekonomi')
            news_items: List of news items
            max_length: Max length of summary in words
            
        Returns:
            Dict with summary, highlights, and metadata
        """
        if not news_items:
            return {
                'category': category,
                'summary': 'Tidak ada berita tersedia untuk kategori ini.',
                'highlights': [],
                'news_count': 0,
                'generated_at': datetime.now().isoformat(),
            }
        
        try:
            # Prepare news text for AI
            news_text = self._prepare_news_text(news_items[:20])  # Max 20 berita
            
            # Create prompt
            prompt = self._create_prompt(category, news_text, max_length)
            
            print(f"🤖 Generating summary for {category}...")
            
            # Call DeepSeek API using requests
            headers = {
                'Authorization': f'Bearer {self.api_key}',
                'Content-Type': 'application/json',
            }
            
            payload = {
                'model': 'deepseek-chat',
                'messages': [
                    {
                        'role': 'system',
                        'content': 'Anda adalah asisten berita profesional yang merangkum berita dalam Bahasa Indonesia dengan gaya objektif dan informatif.'
                    },
                    {
                        'role': 'user',
                        'content': prompt
                    }
                ],
                'max_tokens': 800,
                'temperature': 0.3,
            }
            
            response = requests.post(
                self.api_url,
                headers=headers,
                json=payload,
                timeout=30
            )
            
            response.raise_for_status()
            result = response.json()
            
            # Extract summary from response
            summary_text = result['choices'][0]['message']['content'].strip()
            
            # Extract highlights
            highlights = self._extract_highlights(news_items[:5])
            
            result_data = {
                'category': category,
                'summary': summary_text,
                'highlights': highlights,
                'news_count': len(news_items),
                'generated_at': datetime.now().isoformat(),
                'model': 'deepseek-chat',
            }
            
            print(f"✓ Summary generated for {category} ({len(summary_text)} chars)")
            return result_data
            
        except requests.exceptions.RequestException as e:
            print(f"✗ API Error for {category}: {e}")
            return {
                'category': category,
                'summary': f'Error saat menghubungi AI API: {str(e)}',
                'highlights': self._extract_highlights(news_items[:5]),
                'news_count': len(news_items),
                'generated_at': datetime.now().isoformat(),
                'error': str(e),
            }
        except Exception as e:
            print(f"✗ Error generating summary for {category}: {e}")
            return {
                'category': category,
                'summary': f'Error generating summary: {str(e)}',
                'highlights': self._extract_highlights(news_items[:3]),
                'news_count': len(news_items),
                'generated_at': datetime.now().isoformat(),
                'error': str(e),
            }
    
    def _prepare_news_text(self, news_items: List[Dict]) -> str:
        """Prepare news items as text for AI"""
        texts = []
        
        for i, item in enumerate(news_items, 1):
            text = f"{i}. {item['title']}\n"
            if item.get('description'):
                desc = item['description'][:200]
                text += f"   {desc}...\n"
            text += f"   Sumber: {item['source']}\n"
            texts.append(text)
        
        return "\n".join(texts)
    
    def _create_prompt(self, category: str, news_text: str, max_length: int) -> str:
        """Create prompt for AI summarization"""
        category_names = {
            'hukum_politik': 'Hukum & Politik',
            'ekonomi': 'Ekonomi',
            'pendidikan': 'Pendidikan',
            'kesehatan': 'Kesehatan',
            'teknologi': 'Teknologi',
            'nasional': 'Nasional',
        }
        
        category_name = category_names.get(category, category)
        
        prompt = f"""Berikut adalah kumpulan berita terkini kategori {category_name}:

{news_text}

Tugas Anda:
1. Buat rangkuman komprehensif dari berita-berita di atas dalam Bahasa Indonesia
2. Fokus pada tema utama, tren, dan poin penting
3. Maksimal {max_length} kata
4. Gunakan format paragraf yang mudah dibaca
5. Objektif dan informatif
6. Jangan sebutkan sumber berita secara spesifik, fokus pada isi berita

Rangkuman:"""
        
        return prompt
    
    def _extract_highlights(self, news_items: List[Dict]) -> List[str]:
        """Extract top news headlines as highlights"""
        highlights = []
        
        for item in news_items[:5]:  # Top 5 news
            if item.get('title'):
                highlights.append(item['title'])
        
        return highlights
    
    def summarize_all_categories(
        self,
        all_news: Dict[str, List[Dict]],
        max_length: int = 500
    ) -> Dict[str, Dict]:
        """Summarize news for all categories"""
        summaries = {}
        
        print("\n🤖 Starting AI summarization for all categories...")
        
        for category, news_items in all_news.items():
            summaries[category] = self.summarize_category(
                category,
                news_items,
                max_length
            )
        
        print(f"\n✓ All summaries generated!")
        return summaries


if __name__ == '__main__':
    # Test summarizer
    from dotenv import load_dotenv
    load_dotenv()
    
    print("Testing AI Summarizer...")
    
    # Example news data
    test_news = [
        {
            'title': 'Pemerintah Umumkan Kebijakan Ekonomi Baru',
            'description': 'Menteri keuangan mengumumkan kebijakan baru untuk mendorong pertumbuhan ekonomi',
            'source': 'Antara News',
            'link': 'https://example.com/1'
        },
        {
            'title': 'Bank Indonesia Naikkan Suku Bunga',
            'description': 'BI menaikkan suku bunga acuan untuk menjaga stabilitas',
            'source': 'CNBC Indonesia',
            'link': 'https://example.com/2'
        },
    ]
    
    # Need API key to test
    api_key = os.getenv('DEEPSEEK_API_KEY')
    if api_key:
        summarizer = AISummarizer(api_key)
        result = summarizer.summarize_category('ekonomi', test_news)
        print("\n" + "="*50)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print("⚠️  Set DEEPSEEK_API_KEY environment variable to test")
