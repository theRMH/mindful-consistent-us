import { NextRequest } from "next/server";
import { handleCompleteSession } from "./handler";

export async function POST(req: NextRequest) {
  return handleCompleteSession(req);
}
