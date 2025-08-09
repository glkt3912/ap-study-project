#!/usr/bin/env node

/**
 * 応用情報技術者試験 学習計画生成スクリプト
 * 
 * 使用方法:
 *   node scripts/generate-study-plan.js --weeks 12 --output src/data/studyPlan.ts
 *   node scripts/generate-study-plan.js --extend 6  # 既存データに6週間追加
 */

const fs = require('fs');
const path = require('path');

// 学習計画テンプレート
const STUDY_PHASES = {
  '基礎固め期': {
    weeks: [1, 2, 3],
    color: '#3B82F6',
    description: '基礎的な概念と技術要素の理解'
  },
  '応用知識習得期': {
    weeks: [4, 5, 6, 7, 8],
    color: '#10B981',
    description: '実践的な知識と管理系分野の習得'
  },
  '総仕上げ期': {
    weeks: [9, 10, 11, 12],
    color: '#8B5CF6',
    description: '午後問題対策と総合演習'
  }
};

// 科目別学習トピック
const STUDY_TOPICS = {
  '基礎理論': {
    topics: ['離散数学', '応用数学', '情報理論', '通信理論'],
    phase: '基礎固め期'
  },
  'アルゴリズム': {
    topics: ['データ構造', 'アルゴリズム設計', '計算量解析', 'プログラミング'],
    phase: '基礎固め期'
  },
  'コンピュータシステム': {
    topics: ['プロセッサ', 'メモリシステム', '入出力システム', 'システム構成'],
    phase: '基礎固め期'
  },
  'ソフトウェア': {
    topics: ['OS', 'ミドルウェア', 'ファイルシステム', '開発ツール'],
    phase: '基礎固め期'
  },
  'データベース': {
    topics: ['データモデル', 'SQL', 'トランザクション', 'データベース設計'],
    phase: '応用知識習得期'
  },
  'ネットワーク': {
    topics: ['通信プロトコル', 'ネットワーク構成', 'インターネット技術', 'セキュリティ'],
    phase: '応用知識習得期'
  },
  '情報セキュリティ': {
    topics: ['暗号化', '認証', 'アクセス制御', 'セキュリティ管理'],
    phase: '応用知識習得期'
  },
  'システム開発': {
    topics: ['開発手法', '要件定義', '設計技法', 'テスト手法'],
    phase: '応用知識習得期'
  },
  'プロジェクトマネジメント': {
    topics: ['プロジェクト計画', 'スケジュール管理', 'コスト管理', 'リスク管理'],
    phase: '応用知識習得期'
  },
  'サービスマネジメント': {
    topics: ['ITIL', 'SLA', 'サービス品質', 'インシデント管理'],
    phase: '応用知識習得期'
  },
  '経営戦略': {
    topics: ['経営戦略手法', 'マーケティング', 'OR・IE', 'ビジネスシステム'],
    phase: '応用知識習得期'
  },
  'システム戦略': {
    topics: ['情報システム戦略', 'システム企画', 'システム活用', 'IT投資'],
    phase: '応用知識習得期'
  },
  '企業と法務': {
    topics: ['企業活動', '知的財産権', 'セキュリティ関連法規', 'コンプライアンス'],
    phase: '応用知識習得期'
  },
  '午後問題対策': {
    topics: ['情報セキュリティ', 'データベース', 'ネットワーク', 'プログラミング', 'システムアーキテクチャ', '経営戦略・情報戦略', 'プロジェクトマネジメント', 'サービスマネジメント'],
    phase: '総仕上げ期'
  }
};

// 学習計画生成
function generateStudyPlan(totalWeeks = 12) {
  const weeks = [];
  
  for (let weekNum = 1; weekNum <= totalWeeks; weekNum++) {
    const phase = getPhaseForWeek(weekNum);
    const week = generateWeek(weekNum, phase);
    weeks.push(week);
  }
  
  return weeks;
}

// 週の段階を決定
function getPhaseForWeek(weekNum) {
  for (const [phaseName, phaseData] of Object.entries(STUDY_PHASES)) {
    if (phaseData.weeks.includes(weekNum) || 
        (phaseData.weeks.length === 0 && weekNum > Math.max(...Object.values(STUDY_PHASES).flatMap(p => p.weeks)))) {
      return phaseName;
    }
  }
  
  // デフォルトの段階決定
  if (weekNum <= 3) return '基礎固め期';
  if (weekNum <= 8) return '応用知識習得期';
  return '総仕上げ期';
}

// 週単位の学習計画生成
function generateWeek(weekNumber, phase) {
  const subjects = getSubjectsForWeek(weekNumber, phase);
  const goals = getGoalsForWeek(weekNumber, phase);
  
  return {
    weekNumber,
    title: getWeekTitle(weekNumber, phase),
    phase,
    goals,
    days: generateDays(subjects, weekNumber)
  };
}

// 週のタイトル生成
function getWeekTitle(weekNumber, phase) {
  const titles = {
    1: '基礎固め期',
    2: '基礎理論・アルゴリズム',
    3: '応用知識習得',
    4: 'システム企画・戦略',
    5: 'プロジェクトマネジメント',
    6: '午後問題対策開始',
    7: 'セキュリティ・データベース強化',
    8: 'ネットワーク・開発技術',
    9: '午後問題集中演習',
    10: '模擬試験・弱点補強',
    11: '総合演習・最終調整',
    12: '直前対策・総仕上げ'
  };
  
  return titles[weekNumber] || `第${weekNumber}週`;
}

// 週の目標設定
function getGoalsForWeek(weekNumber, phase) {
  const goalTemplates = {
    '基礎固め期': ['基本概念の理解', '基礎的な計算問題の習得'],
    '応用知識習得期': ['実践的な知識習得', '管理系分野の理解'],
    '総仕上げ期': ['午後問題解法力向上', '総合的な実力向上']
  };
  
  return goalTemplates[phase] || ['学習内容の定着'];
}

// 週の科目決定
function getSubjectsForWeek(weekNumber, phase) {
  // 週番号に基づいた科目配分ロジック
  const subjectMap = {
    1: ['コンピュータの基礎理論', 'アルゴリズムとデータ構造', 'ハードウェア基礎', 'ソフトウェア基礎'],
    2: ['システム構成', 'データベース基礎', 'ネットワーク基礎', '情報セキュリティ基礎'],
    3: ['データベース応用', 'ネットワーク応用', 'プログラミング言語', 'システムアーキテクチャ'],
    4: ['経営戦略・企業戦略', '情報戦略・IT投資', 'システム企画', '企業と法務'],
    5: ['プロジェクトマネジメント基礎', 'プロジェクト実行・監視', 'サービスマネジメント', 'システム監査'],
    6: ['午後問題・情報セキュリティ', '午後問題・データベース', '午後問題・ネットワーク', '午後問題・プログラミング'],
    7: ['午後問題・システムアーキテクチャ', '午後問題・経営戦略', '午後問題・プロジェクトマネジメント', '午後問題・サービスマネジメント'],
    8: ['総合問題演習', 'サンプル問題', '弱点分野集中', 'データベース実践'],
    9: ['模擬試験1', '午後問題過去問', '時間配分練習', 'ネットワーク実践'],
    10: ['模擬試験2', '弱点補強', 'プログラミング実践', 'セキュリティ実践'],
    11: ['模擬試験3', '午前問題総復習', '午後問題総復習', '最終確認'],
    12: ['直前総復習', '重要ポイント確認', 'メンタル調整', '試験当日準備']
  };
  
  return subjectMap[weekNumber] || ['総合演習', '弱点補強', '過去問演習', '最終確認'];
}

// 日別学習内容生成
function generateDays(subjects, weekNumber) {
  const days = ['月', '火', '水', '木', '金'];
  const studyDays = [];
  
  days.forEach((day, index) => {
    const subject = subjects[index] || '総合演習';
    const topics = generateTopicsForSubject(subject, weekNumber);
    const estimatedTime = getEstimatedTime(subject, weekNumber);
    
    studyDays.push({
      day,
      subject,
      topics,
      estimatedTime,
      completed: false,
      actualTime: 0,
      understanding: 0
    });
  });
  
  return studyDays;
}

// 科目別トピック生成
function generateTopicsForSubject(subject, weekNumber) {
  // 簡易的なトピック生成ロジック
  const topicMaps = {
    'コンピュータの基礎理論': ['2進数', '論理演算', 'ブール代数'],
    'アルゴリズムとデータ構造': ['ソート', '探索', '計算量'],
    'ハードウェア基礎': ['CPU', 'メモリ', '入出力装置'],
    '午前問題演習': [`${(weekNumber-1)*20+1}-${weekNumber*20}問`, '基礎分野'],
    '午後問題演習': ['過去問分析', '時間配分', '解答テクニック']
  };
  
  return topicMaps[subject] || [subject, '実践演習', '理解度確認'];
}

// 推定学習時間算出
function getEstimatedTime(subject, weekNumber) {
  if (subject.includes('午前問題')) return 120;
  if (subject.includes('午後問題')) return 180;
  if (subject.includes('演習') || subject.includes('模擬試験')) return 180;
  return 180; // デフォルト3時間
}

// TypeScriptファイル生成
function generateTypeScriptFile(weeks, outputPath) {
  const template = `export interface StudyDay {
  day: string;
  subject: string;
  topics: string[];
  estimatedTime: number;
  completed: boolean;
  actualTime: number;
  understanding: number;
  memo?: string;
}

export interface StudyWeek {
  weekNumber: number;
  title: string;
  goals: string[];
  days: StudyDay[];
  phase: string;
}

export const studyPlanData: StudyWeek[] = ${JSON.stringify(weeks, null, 2)};

export const testCategories = [
  '基礎理論',
  'アルゴリズム',
  'コンピュータシステム',
  '技術要素',
  '開発技術',
  'プロジェクトマネジメント',
  'サービスマネジメント',
  'システム戦略',
  '経営戦略',
  '企業と法務',
];

export const afternoonQuestionTypes = [
  '経営戦略・情報戦略',
  'プログラミング',
  'データベース',
  'ネットワーク',
  '情報セキュリティ',
  'システム開発',
  'プロジェクトマネジメント',
  'サービスマネジメント',
];
`;

  fs.writeFileSync(outputPath, template, 'utf-8');
  console.log(`✅ 学習計画ファイルを生成しました: ${outputPath}`);
  console.log(`📊 総週数: ${weeks.length}週間`);
  console.log(`⏱️  総学習時間: ${weeks.reduce((total, week) => 
    total + week.days.reduce((weekTotal, day) => weekTotal + day.estimatedTime, 0), 0) / 60}時間`);
}

// CLI実行
function main() {
  const args = process.argv.slice(2);
  const weeksArg = args.find(arg => arg.startsWith('--weeks='));
  const outputArg = args.find(arg => arg.startsWith('--output='));
  const extendArg = args.find(arg => arg.startsWith('--extend='));
  
  const totalWeeks = weeksArg ? parseInt(weeksArg.split('=')[1]) : 12;
  const outputPath = outputArg ? outputArg.split('=')[1] : path.join(__dirname, '../ap-study-app/src/data/studyPlan.ts');
  
  if (extendArg) {
    // 既存データ拡張モード（未実装）
    console.log('拡張モードは次回実装予定です');
    return;
  }
  
  console.log(`🚀 ${totalWeeks}週間の学習計画を生成しています...`);
  const weeks = generateStudyPlan(totalWeeks);
  generateTypeScriptFile(weeks, outputPath);
}

// 直接実行された場合
if (require.main === module) {
  main();
}

module.exports = {
  generateStudyPlan,
  generateTypeScriptFile,
  STUDY_PHASES,
  STUDY_TOPICS
};