import { createHmac, randomBytes } from 'crypto';

const SESSION_DURATION_MS = 8 * 60 * 60 * 1000;

export function createSessionToken(): string {
  const secret = process.env.ADMIN_SESSION_SECRET;
  if (!secret) throw new Error('ADMIN_SESSION_SECRET not configured');
  const nonce = randomBytes(32).toString('hex');
  const expiry = Date.now() + SESSION_DURATION_MS;
  const payload = `${nonce}.${expiry}`;
  const sig = createHmac('sha256', secret).update(payload).digest('hex');
  return `${payload}.${sig}`;
}
