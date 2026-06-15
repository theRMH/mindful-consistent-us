import { NextRequest, NextResponse } from 'next/server';
import { supabaseAdmin } from '@/lib/supabase';
import prisma from '@/lib/prisma';

export async function POST(req: NextRequest) {
  try {
    const { email, fullName } = await req.json();
    if (!email?.trim()) {
      return NextResponse.json({ error: 'Email is required' }, { status: 400 });
    }

    const { data, error } = await supabaseAdmin.auth.admin.inviteUserByEmail(email.trim(), {
      data: fullName?.trim() ? { full_name: fullName.trim() } : undefined,
    });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    if (data.user) {
      await prisma.profile.upsert({
        where: { id: data.user.id },
        update: { email: email.trim(), fullName: fullName?.trim() || null },
        create: { id: data.user.id, email: email.trim(), fullName: fullName?.trim() || null },
      });
    }

    return NextResponse.json({ success: true, userId: data.user?.id }, { status: 201 });
  } catch (error) {
    console.error('Error creating user:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
