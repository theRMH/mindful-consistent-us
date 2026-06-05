import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl) {
  throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL env variable');
}

if (!supabaseServiceKey) {
  console.warn('Warning: SUPABASE_SERVICE_ROLE_KEY env variable is not set.');
}

// Admin client to bypass RLS policies in Next.js APIs (securely run on server side)
export const supabaseAdmin = createClient(
  supabaseUrl,
  supabaseServiceKey || 'dummy_service_role_key_for_build',
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);
