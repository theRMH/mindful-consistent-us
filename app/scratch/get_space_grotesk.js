const https = require('https');

const fileKey = 'BUfDh5I6kChgKRI0wNPY8R';
const apiKey = 'figd_tvOEIgPHWBaZ9ZX8CvWneZnIXI_CQ8v2RNgtGARL';

const options = {
  hostname: 'api.figma.com',
  path: `/v1/files/${fileKey}`,
  headers: {
    'X-Figma-Token': apiKey
  }
};

https.get(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    try {
      const doc = JSON.parse(data);
      const spaceGroteskNodes = [];

      function traverse(node, path = []) {
        if (!node) return;
        
        const currentPath = [...path, node.name];
        if (node.type === 'TEXT') {
          if (node.style && node.style.fontFamily === 'Space Grotesk') {
            spaceGroteskNodes.push({
              path: currentPath.join(' > '),
              text: node.characters,
              fontSize: node.style.fontSize,
              fontWeight: node.style.fontWeight
            });
          }
        }
        
        if (node.children) {
          node.children.forEach(c => traverse(c, currentPath));
        }
      }
      
      traverse(doc.document);
      
      console.log('--- ALL SPACE GROTESK TEXT NODES ---');
      spaceGroteskNodes.forEach((n, idx) => {
        console.log(`[#${idx+1}] Text: "${n.text.replace(/\n/g, ' ')}"`);
        console.log(`    Path: ${n.path}`);
        console.log(`    Size: ${n.fontSize}px | Weight: ${n.fontWeight}`);
      });
      
    } catch (e) {
      console.error('Error parsing response:', e.message);
    }
  });
}).on('error', (err) => {
  console.error('HTTPS Request Error:', err.message);
});
