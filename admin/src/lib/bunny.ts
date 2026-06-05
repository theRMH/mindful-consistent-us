import { createHash } from 'crypto';

/**
 * Generates a signed token for Bunny.net Stream HLS playback.
 * The token allows temporary access to a secure video stream.
 * Standard format: token = sha256(tokenKey + videoId + expires)
 */
export function generateBunnyToken(videoId: string, expirationSeconds: number = 7200): { token: string; expires: number } {
  const tokenKey = process.env.BUNNY_TOKEN_KEY || 'mock_token_key';
  const expires = Math.floor(Date.now() / 1000) + expirationSeconds;
  
  // Create cryptographic hash
  const input = `${tokenKey}${videoId}${expires}`;
  const token = createHash('sha256').update(input).digest('hex');
  
  return { token, expires };
}
