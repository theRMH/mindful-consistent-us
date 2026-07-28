const fs = require('fs');

const data = JSON.parse(fs.readFileSync('figma_design.json', 'utf8'));
const canvas = data.document.children.find(c => c.id === '0:1');
const completedSection = canvas.children.find(c => c.id === '13:721');

if (!completedSection) {
  console.log('Completed section not found');
  process.exit(1);
}

const screens = completedSection.children.filter(child => {
  return child.type === 'FRAME' && child.absoluteBoundingBox && child.absoluteBoundingBox.width > 200;
});

screens.forEach(screen => {
  console.log(`\n==================================================`);
  console.log(`SCREEN: "${screen.name}" (ID: ${screen.id})`);
  console.log(`--------------------------------------------------`);
  
  const texts = [];
  function extractText(node) {
    if (node.type === 'TEXT' && node.characters) {
      texts.push({
        id: node.id,
        name: node.name,
        text: node.characters
      });
    }
    if (node.children) {
      node.children.forEach(extractText);
    }
  }
  
  extractText(screen);
  
  texts.forEach(t => {
    console.log(`  - [${t.name}]: "${t.text.replace(/\n/g, '\\n')}"`);
  });
});
