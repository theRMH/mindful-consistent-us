const https = require('https');
const fs = require('fs');
const path = require('path');

const token = 'figd_tvOEIgPHWBaZ9ZX8CvWneZnIXI_CQ8v2RNgtGARL';
const fileKey = 'BUfDh5I6kChgKRI0wNPY8R';
// Node ID in the URL is 0-1, which corresponds to 0:1 in the Figma API
const nodeId = '0:1';

const options = {
  hostname: 'api.figma.com',
  path: `/v1/files/${fileKey}`,
  method: 'GET',
  headers: {
    'X-Figma-Token': token
  }
};

console.log('Sending request to Figma API...');
const req = https.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}`);
    if (res.statusCode === 200) {
      fs.writeFileSync(path.join(__dirname, 'figma_design.json'), data);
      console.log('Success! Saved design details to figma_design.json');
    } else {
      console.error('Failed to fetch design:', data);
    }
  });
});

req.on('error', (e) => {
  console.error(`Problem with request: ${e.message}`);
});

req.end();
