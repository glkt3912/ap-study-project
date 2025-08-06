#!/usr/bin/env python3

import json
import os
import sys
from pathlib import Path

def count_questions_in_file(file_path):
    """JSONファイル内の問題数をカウント"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if isinstance(data, list):
            return len(data)
        else:
            return 1 if data else 0
            
    except (json.JSONDecodeError, FileNotFoundError, Exception) as e:
        print(f"エラー {file_path}: {e}", file=sys.stderr)
        return 0

def main():
    """メイン処理"""
    seed_dir = Path("ap-study-backend/src/infrastructure/database/seeds")
    
    if not seed_dir.exists():
        print("シードデータディレクトリが見つかりません")
        sys.exit(1)
    
    total_questions = 0
    years_data = {}
    
    # 年度別ファイルを処理
    for year in range(2020, 2026):
        file_path = seed_dir / f"questions-{year}.json"
        if file_path.exists():
            count = count_questions_in_file(file_path)
            years_data[year] = count
            total_questions += count
        else:
            years_data[year] = 0
    
    # 結果表示
    print("📊 現在の問題数統計:")
    print(f"総問題数: {total_questions}")
    print("")
    print("年度別問題数:")
    for year, count in years_data.items():
        print(f"  {year}年度: {count:3d}問")
    
    # 推定網羅率（1年あたり約80問と仮定）
    estimated_total = len(years_data) * 80
    coverage_percent = (total_questions * 100 // estimated_total) if estimated_total > 0 else 0
    print("")
    print(f"推定網羅率: {coverage_percent}% ({total_questions}/{estimated_total})")
    
    # カテゴリ別統計（簡易版）
    categories = {}
    for year, count in years_data.items():
        if count > 0:
            file_path = seed_dir / f"questions-{year}.json"
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                for question in data:
                    category = question.get('category', '未分類')
                    categories[category] = categories.get(category, 0) + 1
                    
            except Exception:
                pass
    
    if categories:
        print("")
        print("カテゴリ別問題数:")
        for category, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
            print(f"  {category:<20}: {count:3d}問")

if __name__ == "__main__":
    main()