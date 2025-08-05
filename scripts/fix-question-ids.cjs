const fs = require('fs');
const path = require('path');

// コマンドライン引数から年度を取得（デフォルト: 全年度）
const targetYear = process.argv[2];
const seedsDir = '../ap-study-backend/src/infrastructure/database/seeds';

// 対象年度の決定
const years = targetYear ? [targetYear] : ['2022', '2023', '2024', '2025'];

function fixQuestionIds(year) {
  const filePath = path.join(seedsDir, `questions-${year}.json`);
  
  if (!fs.existsSync(filePath)) {
    console.log(`⚠️ ${year}年度のファイルが見つかりません: ${filePath}`);
    return;
  }

  console.log(`\n🔧 ${year}年度データの修正を開始...`);
  
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  
  // 季節とセクション別のカウンター
  const counters = {
    spring: { morning: 1, afternoon: 1 },
    autumn: { morning: 1, afternoon: 1 }
  };

  const fixedData = data.map((question, index) => {
    const { year: qYear, season, section } = question;
    
    // カウンターを取得・更新
    const counter = counters[season][section];
    const sectionCode = section === 'morning' ? 'am' : 'pm';
    const newId = `ap${qYear}${season}_${sectionCode}_${String(counter).padStart(2, '0')}`;
    
    counters[season][section]++;
    
    return {
      ...question,
      id: newId,
      number: counter
    };
  });

  console.log(`修正前: ${data.length}問`);
  console.log(`修正後: ${fixedData.length}問`);
  
  // 統計表示
  Object.entries(counters).forEach(([season, sections]) => {
    Object.entries(sections).forEach(([section, count]) => {
      if (count > 1) {
        console.log(`  - ${season} ${section}: ${count - 1}問`);
      }
    });
  });

  // バックアップを作成
  const backupPath = `${filePath}.backup`;
  fs.writeFileSync(backupPath, fs.readFileSync(filePath, 'utf8'));
  console.log(`📦 バックアップ作成: ${backupPath}`);

  // 修正されたデータを書き込み
  fs.writeFileSync(filePath, JSON.stringify(fixedData, null, 2));
  console.log(`✅ questions-${year}.json の重複IDを修正しました`);
}

// メイン処理
console.log('🚀 問題ID重複修正スクリプト開始');
console.log(`対象年度: ${targetYear || '全年度 (2022-2025)'}`);

years.forEach(year => {
  try {
    fixQuestionIds(year);
  } catch (error) {
    console.error(`❌ ${year}年度の処理中にエラー:`, error.message);
  }
});

console.log('\n🎉 修正処理完了');
console.log('\n📖 使用方法:');
console.log('  全年度修正: node scripts/fix-question-ids.cjs');
console.log('  特定年度修正: node scripts/fix-question-ids.cjs 2025');