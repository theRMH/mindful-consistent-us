const fs = require('fs');

const data = JSON.parse(fs.readFileSync('figma_design.json', 'utf8'));
const canvas = data.document.children.find(c => c.id === '0:1');

if (!canvas) {
  console.log('Canvas 0:1 not found');
  process.exit(1);
}

const completedSection = canvas.children.find(c => c.id === '13:721');
if (!completedSection) {
  console.log('Section 13:721 not found');
  process.exit(1);
}

console.log('Children inside Completed Section:');
completedSection.children.forEach(child => {
  console.log(`- [${child.type}] Name: "${child.name}", ID: "${child.id}", BoundingBox: ${JSON.stringify(child.absoluteBoundingBox)}`);
});
