"""
News Summary Scheduler
Automatically updates news summaries at scheduled intervals
"""

import schedule
import time
from datetime import datetime
from dotenv import load_dotenv
import os
from summary_manager import SummaryManager

# Load environment
load_dotenv()


def update_all_summaries(manager: SummaryManager):
    """Update summaries for all categories"""
    print("\n" + "="*60)
    print(f"⏰ SCHEDULED UPDATE: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*60)
    
    try:
        summaries = manager.get_all_summaries(force_refresh=True, max_news=20)
        
        print("\n✓ Update completed successfully!")
        print(f"  Categories updated: {len(summaries)}")
        
        for category, summary in summaries.items():
            print(f"  - {category}: {summary.get('news_count', 0)} news items")
        
    except Exception as e:
        print(f"\n✗ Error during update: {e}")


def main():
    """Main scheduler loop"""
    api_key = os.getenv('DEEPSEEK_API_KEY')
    
    if not api_key:
        print("❌ ERROR: DEEPSEEK_API_KEY not set!")
        print("   Please set it in .env file")
        exit(1)
    
    print("\n" + "="*60)
    print("🤖 CENTRAL NEWS - AI SUMMARY SCHEDULER")
    print("="*60)
    
    # Initialize manager
    manager = SummaryManager(api_key)
    
    # Configuration
    update_interval_hours = int(os.getenv('UPDATE_INTERVAL_HOURS', '6'))
    
    print(f"⏱️  Update interval: Every {update_interval_hours} hours")
    print(f"💾 Cache duration: {os.getenv('CACHE_DURATION_HOURS', '6')} hours")
    print("="*60)
    
    # Schedule updates
    schedule.every(update_interval_hours).hours.do(
        lambda: update_all_summaries(manager)
    )
    
    # Run first update immediately
    print("\n📰 Running initial update...")
    update_all_summaries(manager)
    
    print("\n✓ Scheduler started. Press Ctrl+C to stop.")
    print(f"  Next update in {update_interval_hours} hours\n")
    
    # Main loop
    try:
        while True:
            schedule.run_pending()
            time.sleep(60)  # Check every minute
    except KeyboardInterrupt:
        print("\n\n👋 Scheduler stopped by user")


if __name__ == '__main__':
    main()

