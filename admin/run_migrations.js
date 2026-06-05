const { Pool } = require('pg');
const { PrismaPg } = require('@prisma/adapter-pg');
const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const connectionString = process.env.DIRECT_URL || process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error('Missing database connection string in environment');
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
  const migrations = [
    '002_rls_policies.sql',
    '003_triggers.sql',
    '004_views.sql'
  ];

  for (const file of migrations) {
    console.log(`Running migration: ${file}`);
    const filePath = path.join(__dirname, '..', 'database', 'migrations', file);
    if (!fs.existsSync(filePath)) {
      throw new Error(`Migration file not found at ${filePath}`);
    }
    const sql = fs.readFileSync(filePath, 'utf8');
    
    // Execute SQL directly using Prisma Client's $executeRawUnsafe
    await prisma.$executeRawUnsafe(sql);
    console.log(`Migration ${file} executed successfully!\n`);
  }
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
