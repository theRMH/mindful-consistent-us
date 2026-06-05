const fs = require('fs');

const data = JSON.parse(fs.readFileSync('figma_design.json', 'utf8'));
const canvas = data.document.children.find(c => c.id === '0:1');

if (!canvas) {
  console.log('Canvas 0:1 not found');
  process.exit(1);
}

const designSystemFrame = canvas.children.find(c => c.id === '3:83');
if (!designSystemFrame) {
  console.log('Design system frame 3:83 not found');
  process.exit(1);
}

const colors = new Set();
const fontStyles = new Set();

function traverse(node) {
  // Extract colors from solid fills
  if (node.fills) {
    node.fills.forEach(fill => {
      if (fill.type === 'SOLID' && fill.color) {
        const r = Math.round(fill.color.r * 255);
        const g = Math.round(fill.color.g * 255);
        const b = Math.round(fill.color.b * 255);
        const a = fill.color.a !== undefined ? fill.color.a : 1;
        colors.add(`rgba(${r}, ${g}, ${b}, ${a})`);
      }
    });
  }

  // Extract typography
  if (node.type === 'TEXT' && node.style) {
    const style = node.style;
    fontStyles.add(JSON.stringify({
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      lineHeightPx: style.lineHeightPx,
      letterSpacing: style.letterSpacing
    }));
  }

  if (node.children) {
    node.children.forEach(traverse);
  }
}

traverse(designSystemFrame);

console.log('--- Colors found in Wellness-UI-Design system ---');
Array.from(colors).forEach(c => console.log(c));

console.log('\n--- Text styles found in Wellness-UI-Design system ---');
Array.from(fontStyles).map(s => JSON.parse(s)).forEach(style => {
  console.log(`Font: ${style.fontFamily}, Size: ${style.fontSize}px, Weight: ${style.fontWeight}, LineHeight: ${Math.round(style.lineHeightPx || 0)}px`);
});
