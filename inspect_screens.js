const fs = require('fs');

const data = JSON.parse(fs.readFileSync('figma_design.json', 'utf8'));
const canvas = data.document.children.find(c => c.id === '0:1');
const completedSection = canvas.children.find(c => c.id === '13:721');

if (!completedSection) {
  console.log('Completed section not found');
  process.exit(1);
}

// List of major screen IDs we want to inspect
const screens = completedSection.children.filter(child => {
  // Ignore small frames/instances that are not full screen frames
  return child.type === 'FRAME' && child.absoluteBoundingBox && child.absoluteBoundingBox.width > 200;
});

screens.forEach(screen => {
  console.log(`\n==================================================`);
  console.log(`SCREEN: "${screen.name}" (ID: ${screen.id})`);
  console.log(`Size: ${screen.absoluteBoundingBox.width}x${screen.absoluteBoundingBox.height}`);
  console.log(`--------------------------------------------------`);
  
  // Print direct children
  if (screen.children) {
    printChildren(screen.children, 1);
  }
});

function printChildren(children, depth) {
  const indent = '  '.repeat(depth);
  children.forEach(child => {
    // If it's a group, frame, instance, or text, print it
    if (['FRAME', 'GROUP', 'INSTANCE', 'TEXT', 'VECTOR', 'RECTANGLE'].includes(child.type)) {
      let extraInfo = '';
      if (child.type === 'TEXT') {
        extraInfo = ` - "${child.characters ? child.characters.replace(/\n/g, '\\n').substring(0, 40) : ''}"`;
      }
      console.log(`${indent}- [${child.type}] "${child.name}"${extraInfo} (${child.id})`);
      
      // recurse for nested structures like groups or components if they are not too deep
      if (child.children && depth < 3) {
        printChildren(child.children, depth + 1);
      }
    }
  });
}
