import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

const SECRET = 'rmh-debug-2026';
const TEST_ID = 'DebugFirebaseUID_TestOnly';

export async function POST(req: NextRequest) {
  const { secret } = await req.json();
  if (secret !== SECRET) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const results: Record<string, unknown> = {};

  // Step 1: findUnique
  try {
    results.findUnique = await prisma.profile.findUnique({ where: { id: TEST_ID }, select: { id: true } });
    results.findUniqueOk = true;
  } catch (e) {
    results.findUniqueError = (e as Error).message;
  }

  // Step 2: profile upsert
  try {
    await prisma.profile.upsert({
      where: { id: TEST_ID },
      update: { phone: '+910000000099', updatedAt: new Date() },
      create: { id: TEST_ID, email: null, phone: '+910000000099', fullName: 'Debug Test', avatarUrl: '' },
    });
    results.profileUpsertOk = true;
  } catch (e) {
    results.profileUpsertError = (e as Error).message;
  }

  // Step 3: userStats upsert
  try {
    await prisma.userStats.upsert({
      where: { userId: TEST_ID },
      update: {},
      create: { userId: TEST_ID },
    });
    results.statsUpsertOk = true;
  } catch (e) {
    results.statsUpsertError = (e as Error).message;
  }

  // Cleanup
  try {
    await prisma.profile.delete({ where: { id: TEST_ID } });
    results.cleanupOk = true;
  } catch (e) {
    results.cleanupError = (e as Error).message;
  }

  return NextResponse.json(results);
}
