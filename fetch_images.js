const https = require('https');
const fs = require('fs');
const path = require('path');

const token = 'figd_tvOEIgPHWBaZ9ZX8CvWneZnIXI_CQ8v2RNgtGARL';
const fileKey = 'hQ16GxeRwYFvOFK7eFJDCc';

const options = {
  hostname: 'api.figma.com',
  path: `/v1/files/${fileKey}/images`,
  method: 'GET',
  headers: {
    'X-Figma-Token': token
  }
};

console.log('Sending request to Figma Images API...');
const req = https.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}`);
    if (res.statusCode === 200) {
      fs.writeFileSync(path.join(__dirname, 'figma_images.json'), data);
      const parsed = JSON.parse(data);
      const count = parsed.meta && parsed.meta.images ? Object.keys(parsed.meta.images).length : 0;
      console.log(`Success! Saved ${count} image mapping URLs to figma_images.json`);
    } else {
      console.error('Failed to fetch images:', data);
    }
  });
});

req.on('error', (e) => {
  console.error(`Problem with request: ${e.message}`);
});

req.end();
