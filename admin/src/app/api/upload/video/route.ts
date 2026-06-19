import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';

const BUCKET = 'videos';

export async function POST(req: NextRequest) {
  try {
    const formData = await req.formData();
    const file = formData.get('file') as File | null;
    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 });
    }

    const ext = file.name.split('.').pop() ?? 'mp4';
    const safeName = `${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`;

    const buffer = Buffer.from(await file.arrayBuffer());

    const { error: uploadError } = await supabaseAdmin.storage
      .from(BUCKET)
      .upload(safeName, buffer, {
        contentType: file.type || 'video/mp4',
        upsert: false,
      });

    if (uploadError) throw uploadError;

    const { data: { publicUrl } } = supabaseAdmin.storage
      .from(BUCKET)
      .getPublicUrl(safeName);

    return NextResponse.json({ url: publicUrl }, { status: 200 });
  } catch (err: unknown) {
    console.error('Video upload error:', err);
    const message = err instanceof Error ? err.message : 'Upload failed';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
