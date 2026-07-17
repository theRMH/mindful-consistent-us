import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';

declare global {
  var prismaGlobal: undefined | PrismaClient;
}

function createPrismaClient(): PrismaClient {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) throw new Error('DATABASE_URL environment variable is missing');
  const pool = new Pool({ connectionString });
  const adapter = new PrismaPg(pool);
  return new PrismaClient({ adapter });
}

// Lazy singleton — only throws when a route actually calls prisma, not at module load
const prisma = new Proxy({} as PrismaClient, {
  get(_target, prop) {
    const client = globalThis.prismaGlobal ?? (globalThis.prismaGlobal = createPrismaClient());
    return (client as unknown as Record<string | symbol, unknown>)[prop];
  },
});

export default prisma;
