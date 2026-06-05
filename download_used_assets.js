const fs = require('fs');
const https = require('https');
const path = require('path');

// 1. Load Figma design and extract all image references
const designData = JSON.parse(fs.readFileSync('figma_design.json', 'utf8'));
const imagesData = JSON.parse(fs.readFileSync('figma_images.json', 'utf8')).meta.images;

const usedRefs = new Set();

function traverse(node) {
  if (node.fills) {
    node.fills.forEach(fill => {
      if (fill.type === 'IMAGE' && fill.imageRef) {
        usedRefs.add(fill.imageRef);
      }
    });
  }
  if (node.children) {
    node.children.forEach(traverse);
  }
}

traverse(designData.document);
console.log(`Found ${usedRefs.size} unique image references used in the design.`);

// 2. Ensure assets directory exists
const assetsDir = path.join(__dirname, 'assets');
if (!fs.existsSync(assetsDir)) {
  fs.mkdirSync(assetsDir);
}

// 3. Download helper
function downloadImage(ref, url, attempt = 1) {
  return new Promise((resolve) => {
    const fileExtension = '.png'; // default to png
    const filePath = path.join(assetsDir, `${ref}${fileExtension}`);
    
    if (fs.existsSync(filePath)) {
      console.log(`Already downloaded: ${ref}`);
      return resolve();
    }

    const file = fs.createWriteStream(filePath);
    const req = https.get(url, (res) => {
      if (res.statusCode !== 200) {
        console.error(`Error downloading ${ref}: HTTP ${res.statusCode}`);
        file.close();
        fs.unlinkSync(filePath);
        return resolve();
      }
      res.pipe(file);
      file.on('finish', () => {
        file.close();
        console.log(`Downloaded: ${ref}`);
        resolve();
      });
    });

    req.on('error', (err) => {
      console.error(`Error requesting ${ref}: ${err.message}`);
      file.close();
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
      resolve();
    });
  });
}

// 4. Download all in batches
async function main() {
  const tasks = [];
  for (const ref of usedRefs) {
    const url = imagesData[ref];
    if (url) {
      tasks.push({ ref, url });
    } else {
      console.warn(`No URL found for imageRef: ${ref}`);
    }
  }

  console.log(`Starting download of ${tasks.length} images...`);
  // Download with a concurrency limit of 5 to avoid overloading
  const concurrency = 5;
  for (let i = 0; i < tasks.length; i += concurrency) {
    const batch = tasks.slice(i, i + concurrency);
    await Promise.all(batch.map(t => downloadImage(t.ref, t.url)));
    console.log(`Finished batch ${Math.floor(i / concurrency) + 1}/${Math.ceil(tasks.length / concurrency)}`);
  }
  console.log('All downloads completed!');
}

main().catch(console.error);
