// supabase/functions/delete-old-event-images/index.ts
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (_req) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const folder = "event_images";
  const bucket = "public";

  const res = await fetch(
    `${supabaseUrl}/storage/v1/object/list/${bucket}/${folder}`,
    {
      headers: {
        "Authorization": `Bearer ${supabaseKey}`,
      },
    },
  );

  const files = await res.json();

  const now = new Date();

  for (const file of files) {
    const uploadedAt = new Date(file.created_at || file.metadata?.createdAt);
    const ageInMs = now.getTime() - uploadedAt.getTime();
    const ageInDays = ageInMs / (1000 * 60 * 60 * 24);

    if (ageInDays > 1) {
      const path = `${folder}/${file.name}`;

      await fetch(`${supabaseUrl}/storage/v1/object/${bucket}/${path}`, {
        method: "DELETE",
        headers: {
          "Authorization": `Bearer ${supabaseKey}`,
        },
      });

      console.log(`Deleted: ${path}`);
    }
  }

  return new Response("Old event images cleaned", { status: 200 });
});
