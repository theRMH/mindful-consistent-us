const { Pool } = require('pg');
const { PrismaPg } = require('@prisma/adapter-pg');
const { PrismaClient } = require('@prisma/client');
const dotenv = require('dotenv');

dotenv.config();

const connectionString = process.env.DIRECT_URL || process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error('Missing database connection string in environment');
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

function dicebearUrl(seed) {
  const s = encodeURIComponent((seed || 'user').trim());
  return `https://api.dicebear.com/7.x/thumbs/svg?seed=${s}&radius=50`;
}

async function main() {
  const profiles = await prisma.profile.findMany({
    where: { OR: [{ avatarUrl: null }, { avatarUrl: '' }] },
    select: { id: true, fullName: true, phone: true },
  });

  console.log(`Found ${profiles.length} users without an avatar.`);

  for (const p of profiles) {
    const seed = p.fullName || p.phone || p.id;
    const avatarUrl = dicebearUrl(seed);
    await prisma.profile.update({
      where: { id: p.id },
      data: { avatarUrl },
    });
    console.log(`  Set avatar for ${p.fullName || p.phone || p.id} -> ${avatarUrl}`);
  }

  console.log('Done.');
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
