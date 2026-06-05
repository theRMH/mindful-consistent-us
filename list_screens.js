const fs = require('fs');

const data = JSON.parse(fs.readFileSync('figma_design.json', 'utf8'));
const canvas = data.document.children.find(c => c.id === '0:1');

if (!canvas) {
  console.log('Canvas 0:1 not found');
  process.exit(1);
}

console.log('Top-level screens/frames on Page 1:');
canvas.children.forEach(child => {
  console.log(`- [${child.type}] Name: "${child.name}", ID: "${child.id}", BoundingBox: ${JSON.stringify(child.absoluteBoundingBox)}`);
});
