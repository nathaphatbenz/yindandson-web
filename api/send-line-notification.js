function readBody(request) {
  if (typeof request.body === "string") {
    return JSON.parse(request.body);
  }

  return request.body || {};
}

function buildLineMessage(document) {
  const documentType = String(document.document_type || "");
  const isReceipt = documentType.includes("ใบเสร็จรับเงิน") || String(document.document_number || "").startsWith("RE-");
  const amount = Number(document.grand_total || 0).toLocaleString("th-TH", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
  const status = String(document.document_status || "issued");

  if (isReceipt) {
    return [
      "🧾 สร้างใบเสร็จรับเงิน / ใบกำกับภาษีใหม่",
      `เลขเอกสาร: ${document.document_number || "-"}`,
      `อ้างอิงใบวางบิล: ${document.reference_document_number || "-"}`,
      `ลูกค้า: ${document.customer_name || "-"}`,
      `วันที่ออกเอกสาร: ${document.document_date || "-"}`,
      `ยอดสุทธิ: ${amount} บาท`,
      `สถานะ: ${status}`
    ].join("\n");
  }

  return [
    "📄 สร้างใบวางบิลใหม่",
    `เลขเอกสาร: ${document.document_number || "-"}`,
    `ลูกค้า: ${document.customer_name || "-"}`,
    `วันที่ออกเอกสาร: ${document.document_date || "-"}`,
    `ยอดสุทธิ: ${amount} บาท`,
    `สถานะ: ${status}`
  ].join("\n");
}

async function verifySupabaseSession(accessToken) {
  const { SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY } = process.env;
  if (!SUPABASE_URL || !SUPABASE_PUBLISHABLE_KEY) {
    throw new Error("Supabase server environment variables are not configured.");
  }

  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      apikey: SUPABASE_PUBLISHABLE_KEY,
      Authorization: `Bearer ${accessToken}`
    }
  });

  return response.ok;
}

module.exports = async function handler(request, response) {
  if (request.method !== "POST") {
    response.setHeader("Allow", "POST");
    return response.status(405).json({ error: "Method not allowed" });
  }

  const accessToken = String(request.headers.authorization || "").replace(/^Bearer\s+/i, "");
  if (!accessToken || !await verifySupabaseSession(accessToken)) {
    return response.status(401).json({ error: "Unauthorized" });
  }

  const { LINE_CHANNEL_ACCESS_TOKEN, LINE_TARGET_ID } = process.env;
  if (!LINE_CHANNEL_ACCESS_TOKEN || !LINE_TARGET_ID) {
    return response.status(500).json({ error: "LINE server environment variables are not configured" });
  }

  try {
    const document = readBody(request);
    const lineResponse = await fetch("https://api.line.me/v2/bot/message/push", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${LINE_CHANNEL_ACCESS_TOKEN}`
      },
      body: JSON.stringify({
        to: LINE_TARGET_ID,
        messages: [{ type: "text", text: buildLineMessage(document) }]
      })
    });

    if (!lineResponse.ok) {
      const detail = await lineResponse.text();
      console.error("LINE notification failed:", detail);
      return response.status(502).json({ error: "LINE notification failed" });
    }

    return response.status(200).json({ ok: true });
  } catch (error) {
    console.error("LINE notification error:", error);
    return response.status(500).json({ error: "Unable to send LINE notification" });
  }
};
