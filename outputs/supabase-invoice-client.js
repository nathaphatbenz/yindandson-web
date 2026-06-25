// Supabase client/query helper for YinD invoice pages.
// Add Supabase JS before this file in HTML:
// <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

const SUPABASE_URL = "https://abxmjdosihhvffoflgon.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable__xQ3zF61gKR3liv-ejBH5Q_bAVUcesH";
const isSupabaseConfigured = !SUPABASE_URL.includes("YOUR_PROJECT_ID")
  && !SUPABASE_ANON_KEY.includes("YOUR_SUPABASE_ANON_KEY");
const supabaseClient = isSupabaseConfigured
  ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
  : null;

const INVOICE_TABLE = "invoices";
const USED_DOCUMENT_STATUSES = ["issued", "reserved", "cancelled"];

function requireSupabaseClient() {
  if (!supabaseClient) {
    throw new Error("กรุณาตั้งค่า SUPABASE_URL และ SUPABASE_ANON_KEY ในไฟล์ supabase-invoice-client.js");
  }

  return supabaseClient;
}

function getBangkokIsoDate(date = new Date()) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: "Asia/Bangkok",
    year: "numeric",
    month: "2-digit",
    day: "2-digit"
  }).formatToParts(date);
  const values = Object.fromEntries(parts.map((part) => [part.type, part.value]));
  return `${values.year}-${values.month}-${values.day}`;
}

async function issueReservedReceiptsForBangkokToday() {
  const client = requireSupabaseClient();
  const today = getBangkokIsoDate();
  const { data, error } = await client
    .from(INVOICE_TABLE)
    .update({ document_status: "issued" })
    .eq("document_group", "RE")
    .eq("document_status", "reserved")
    .lte("document_date", today)
    .select("id, invoice_number");

  if (error) {
    throw error;
  }

  return data || [];
}

function mapDbInvoice(record) {
  return {
    id: record.id,
    customer_name: record.customer_name,
    invoice_number: record.invoice_number,
    document_date: record.document_date,
    document_type: record.document_type,
    document_group: record.document_group,
    document_year: record.document_year,
    document_status: record.document_status || "issued",
    document_status_raw: record.document_status ?? null,
    source_invoice_id: record.source_invoice_id,
    customer_address: record.customer_address,
    tax_id: record.tax_id,
    items: record.items || [],
    subtotal: Number(record.subtotal || 0),
    vatAmount: Number(record.vat_amount || 0),
    grandTotal: Number(record.grand_total || 0),
    created_at: record.created_at,
    updated_at: record.updated_at
  };
}

function mapInvoicePayload(record) {
  return {
    customer_name: record.customer_name,
    invoice_number: record.invoice_number,
    document_date: record.document_date,
    document_type: record.document_type,
    document_group: record.document_group,
    document_year: record.document_year,
    document_status: record.document_status || "issued",
    source_invoice_id: record.source_invoice_id || null,
    customer_address: record.customer_address,
    tax_id: record.tax_id,
    items: record.items || [],
    subtotal: Number(record.subtotal || 0),
    vat_amount: Number(record.vatAmount || record.vat_amount || 0),
    grand_total: Number(record.grandTotal || record.grand_total || 0)
  };
}

function removeDocumentNumberMetadata(payload) {
  const cleanPayload = { ...payload };
  delete cleanPayload.document_group;
  delete cleanPayload.document_year;
  delete cleanPayload.document_status;
  return cleanPayload;
}

function isMissingDocumentMetadataError(error) {
  return error && (
    error.code === "PGRST204"
    || /document_group|document_year|document_status/i.test(error.message || "")
  );
}

function inferDocumentGroupFromRecord(record) {
  const numberValue = String(record.invoice_number || "").toUpperCase();
  const typeValue = String(record.document_type || "");
  return numberValue.startsWith("RE-") || numberValue.startsWith("RE.") || typeValue.includes("ใบเสร็จรับเงิน")
    ? "RE"
    : "INV";
}

function inferDocumentYearFromRecord(record) {
  const numberValue = String(record.invoice_number || "");
  const yearMatch = numberValue.match(/^[A-Za-z.]+-(\d{4})-\d{3,4}$/);
  if (yearMatch) {
    return Number(yearMatch[1]);
  }

  if (record.document_date) {
    return Number(String(record.document_date).slice(0, 4)) + 543;
  }

  return new Date().getFullYear() + 543;
}

async function fetchInvoices({ keyword = "", page = 1, pageSize = 20 } = {}) {
  const client = requireSupabaseClient();
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;
  let query = client
    .from(INVOICE_TABLE)
    .select("id, customer_name, invoice_number, document_date, document_type, document_status, source_invoice_id, created_at", { count: "exact" })
    .order("created_at", { ascending: false })
    .range(from, to);

  if (keyword.trim()) {
    const safeKeyword = keyword.trim().replaceAll("%", "\\%").replaceAll("_", "\\_");
    query = query.or(`customer_name.ilike.%${safeKeyword}%,invoice_number.ilike.%${safeKeyword}%`);
  }

  const { data, error, count } = await query;
  if (error) {
    throw error;
  }

  return {
    data: data.map(mapDbInvoice),
    count: count || 0
  };
}

async function fetchCustomerDirectory() {
  const client = requireSupabaseClient();
  const { data, error } = await client
    .from(INVOICE_TABLE)
    .select("customer_name, customer_address, tax_id, created_at")
    .not("customer_name", "is", null)
    .order("created_at", { ascending: false });

  if (error) {
    throw error;
  }

  const uniqueCustomers = new Map();
  (data || []).forEach((record) => {
    const companyName = String(record.customer_name || "").trim();
    if (companyName && !uniqueCustomers.has(companyName)) {
      uniqueCustomers.set(companyName, {
        customer_name: companyName,
        customer_address: record.customer_address || "",
        tax_id: record.tax_id || ""
      });
    }
  });

  return [...uniqueCustomers.values()].sort((a, b) => a.customer_name.localeCompare(b.customer_name, "th"));
}

async function fetchInvoiceById(id) {
  const client = requireSupabaseClient();
  const { data, error } = await client
    .from(INVOICE_TABLE)
    .select("*")
    .eq("id", id)
    .single();

  if (error) {
    throw error;
  }

  return mapDbInvoice(data);
}

async function fetchInvoiceNumberById(id) {
  if (!id) {
    return "";
  }

  const record = await fetchInvoiceById(id);
  return record.invoice_number || "";
}

async function sendLineDocumentNotification(document) {
  const client = requireSupabaseClient();
  const { data, error } = await client.auth.getSession();
  const accessToken = data.session?.access_token;
  if (error || !accessToken) {
    throw new Error("No authenticated session for LINE notification.");
  }

  const response = await fetch("/api/send-line-notification", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`
    },
    body: JSON.stringify(document)
  });

  if (!response.ok) {
    throw new Error("LINE notification request failed.");
  }
}

async function fetchMonthlyWorkData({ month, year }) {
  const client = requireSupabaseClient();
  const filters = (query) => query.eq("work_month", month).eq("work_year", year);
  const [vehicleResult, employeeResult, sharedVehicleResult] = await Promise.all([
    filters(client.from("monthly_vehicle_work_logs").select("*").order("work_date", { ascending: true })),
    filters(client.from("monthly_employee_withdrawals").select("*").order("withdrawal_date", { ascending: true })),
    filters(client.from("monthly_shared_vehicle_withdrawals").select("*").order("withdrawal_date", { ascending: true }))
  ]);

  const error = vehicleResult.error || employeeResult.error || sharedVehicleResult.error;
  if (error) {
    throw error;
  }

  return {
    vehicleLogs: vehicleResult.data || [],
    employeeWithdrawals: employeeResult.data || [],
    sharedVehicleWithdrawals: sharedVehicleResult.data || []
  };
}

async function saveMonthlyWorkData({ month, year, vehicleLogs, employeeWithdrawals, sharedVehicleWithdrawals }) {
  const client = requireSupabaseClient();
  const clearMonth = (tableName) => client
    .from(tableName)
    .delete()
    .eq("work_month", month)
    .eq("work_year", year);

  const clearResults = await Promise.all([
    clearMonth("monthly_vehicle_work_logs"),
    clearMonth("monthly_employee_withdrawals"),
    clearMonth("monthly_shared_vehicle_withdrawals")
  ]);
  const clearError = clearResults.map((result) => result.error).find(Boolean);
  if (clearError) {
    throw clearError;
  }

  const inserts = [];
  if (vehicleLogs.length) inserts.push(client.from("monthly_vehicle_work_logs").insert(vehicleLogs));
  if (employeeWithdrawals.length) inserts.push(client.from("monthly_employee_withdrawals").insert(employeeWithdrawals));
  if (sharedVehicleWithdrawals.length) inserts.push(client.from("monthly_shared_vehicle_withdrawals").insert(sharedVehicleWithdrawals));

  const insertResults = await Promise.all(inserts);
  const insertError = insertResults.map((result) => result.error).find(Boolean);
  if (insertError) {
    throw insertError;
  }
}

async function hasLinkedReceiptDocument(sourceInvoiceId) {
  if (!sourceInvoiceId) {
    return false;
  }

  const client = requireSupabaseClient();
  const { data, error } = await client
    .from(INVOICE_TABLE)
    .select("invoice_number, document_type, document_group")
    .eq("source_invoice_id", sourceInvoiceId);

  if (error) {
    throw error;
  }

  return (data || []).some((record) =>
    (record.document_group || inferDocumentGroupFromRecord(record)) === "RE"
  );
}

async function fetchUsedDocumentNumbers(documentGroup, year) {
  const client = requireSupabaseClient();
  const metadataQuery = client
    .from(INVOICE_TABLE)
    .select("invoice_number, document_date, document_type, document_group, document_year, document_status");

  const metadataResult = await metadataQuery;
  if (!metadataResult.error) {
    return (metadataResult.data || [])
      .filter((record) => USED_DOCUMENT_STATUSES.includes(String(record.document_status || "issued").toLowerCase()))
      .filter((record) => (record.document_group || inferDocumentGroupFromRecord(record)) === documentGroup)
      .filter((record) => Number(record.document_year || inferDocumentYearFromRecord(record)) === year)
      .map((record) => record.invoice_number)
      .filter(Boolean);
  }

  if (!isMissingDocumentMetadataError(metadataResult.error)) {
    throw metadataResult.error;
  }

  const legacyResult = await client
    .from(INVOICE_TABLE)
    .select("invoice_number, document_date, document_type");

  if (legacyResult.error) {
    throw legacyResult.error;
  }

  return (legacyResult.data || [])
    .filter((record) => inferDocumentGroupFromRecord(record) === documentGroup)
    .filter((record) => inferDocumentYearFromRecord(record) === year)
    .map((record) => record.invoice_number)
      .filter(Boolean);
}

async function fetchIssuedDocumentNumbers(documentGroup, year) {
  const client = requireSupabaseClient();
  const metadataResult = await client
    .from(INVOICE_TABLE)
    .select("invoice_number, document_date, document_type, document_group, document_year, document_status");

  if (!metadataResult.error) {
    return (metadataResult.data || [])
      .filter((record) => String(record.document_status || "issued").toLowerCase() === "issued")
      .filter((record) => (record.document_group || inferDocumentGroupFromRecord(record)) === documentGroup)
      .filter((record) => Number(record.document_year || inferDocumentYearFromRecord(record)) === year)
      .map((record) => record.invoice_number)
      .filter(Boolean);
  }

  if (!isMissingDocumentMetadataError(metadataResult.error)) {
    throw metadataResult.error;
  }

  const legacyResult = await client
    .from(INVOICE_TABLE)
    .select("invoice_number, document_date, document_type");

  if (legacyResult.error) {
    throw legacyResult.error;
  }

  return (legacyResult.data || [])
    .filter((record) => inferDocumentGroupFromRecord(record) === documentGroup)
    .filter((record) => inferDocumentYearFromRecord(record) === year)
    .map((record) => record.invoice_number)
    .filter(Boolean);
}

async function fetchLatestReceiptNumbersByStatus(year) {
  const client = requireSupabaseClient();
  const getLatestNumber = async (status) => {
    const { data, error } = await client
      .from(INVOICE_TABLE)
      .select("invoice_number, document_date")
      .eq("document_group", "RE")
      .eq("document_year", year)
      .eq("document_status", status)
      .order("invoice_number", { ascending: false })
      .limit(1);

    if (error) {
      throw error;
    }

    return data?.[0] || null;
  };

  const [issued, reserved] = await Promise.all([getLatestNumber("issued"), getLatestNumber("reserved")]);
  return {
    issued: issued?.invoice_number || "",
    reserved: reserved?.invoice_number || "",
    reservedDocumentDate: reserved?.document_date || ""
  };
}

async function isDocumentNumberAvailable(documentNumber, excludeId = "") {
  const client = requireSupabaseClient();
  let query = client
    .from(INVOICE_TABLE)
    .select("id")
    .eq("invoice_number", documentNumber)
    .limit(1);

  if (excludeId) {
    query = query.neq("id", excludeId);
  }

  const { data, error } = await query;
  if (error) {
    throw error;
  }

  return !data || data.length === 0;
}

async function createInvoice(record) {
  const client = requireSupabaseClient();
  const payload = mapInvoicePayload(record);
  let { data, error } = await client
    .from(INVOICE_TABLE)
    .insert(payload)
    .select()
    .single();

  if (isMissingDocumentMetadataError(error)) {
    const fallbackResult = await client
      .from(INVOICE_TABLE)
      .insert(removeDocumentNumberMetadata(payload))
      .select()
      .single();
    data = fallbackResult.data;
    error = fallbackResult.error;
  }

  if (error) {
    throw error;
  }

  return mapDbInvoice(data);
}

async function updateInvoice(id, record) {
  const client = requireSupabaseClient();
  const payload = mapInvoicePayload(record);
  let { data, error } = await client
    .from(INVOICE_TABLE)
    .update(payload)
    .eq("id", id)
    .select()
    .single();

  if (isMissingDocumentMetadataError(error)) {
    const fallbackResult = await client
      .from(INVOICE_TABLE)
      .update(removeDocumentNumberMetadata(payload))
      .eq("id", id)
      .select()
      .single();
    data = fallbackResult.data;
    error = fallbackResult.error;
  }

  if (error) {
    throw error;
  }

  return mapDbInvoice(data);
}

async function deleteInvoice(id) {
  const client = requireSupabaseClient();
  const { error } = await client
    .from(INVOICE_TABLE)
    .delete()
    .eq("id", id);

  if (error) {
    throw error;
  }

  return true;
}

function getReportMonthRange(thaiYear, month) {
  const gregorianYear = Number(thaiYear) - 543;
  const start = new Date(Date.UTC(gregorianYear, Number(month) - 1, 1));
  const end = new Date(Date.UTC(gregorianYear, Number(month), 1));
  return {
    start: start.toISOString().slice(0, 10),
    end: end.toISOString().slice(0, 10)
  };
}

function isMissingTableError(error) {
  return error && (error.code === "PGRST205" || error.code === "42P01" || /relation .* does not exist|table .* not found/i.test(error.message || ""));
}

function mapReceiptReportRecord(record, sourceNumberField = "invoice_number") {
  const reference = record.reference_document || record.reference || null;
  return {
    id: record.id,
    document_date: record.document_date,
    receipt_number: record.document_number || record.invoice_number || "",
    invoice_number: reference?.document_number || reference?.invoice_number || record.reference_invoice_number || "-",
    customer_name: record.customer_name || "-",
    document_status: String(record.document_status || "issued").toLowerCase()
  };
}

async function attachReportReferences(client, tableName, records, referenceIdField, documentNumberField) {
  const referenceIds = [...new Set(records.map((record) => record[referenceIdField]).filter(Boolean))];
  if (referenceIds.length === 0) {
    return records;
  }

  const { data, error } = await client
    .from(tableName)
    .select(`id, ${documentNumberField}`)
    .in("id", referenceIds);

  if (error) {
    throw error;
  }

  const referencesById = new Map((data || []).map((record) => [record.id, record]));
  return records.map((record) => ({
    ...record,
    reference_document: referencesById.get(record[referenceIdField]) || null
  }));
}

async function fetchReceiptReport({ year, month }) {
  const client = requireSupabaseClient();
  const range = getReportMonthRange(year, month);
  const documentsResult = await client
    .from("documents")
    .select("id, document_date, document_number, customer_name, document_status, reference_document_id")
    .eq("document_group", "RE")
    .gte("document_date", range.start)
    .lt("document_date", range.end)
    .order("document_date", { ascending: true })
    .order("document_number", { ascending: true });

  if (!documentsResult.error) {
    const recordsWithReferences = await attachReportReferences(
      client,
      "documents",
      documentsResult.data || [],
      "reference_document_id",
      "document_number"
    );
    return recordsWithReferences.map((record) => mapReceiptReportRecord(record, "document_number"));
  }

  if (!isMissingTableError(documentsResult.error) && !isMissingDocumentMetadataError(documentsResult.error)) {
    throw documentsResult.error;
  }

  const invoicesResult = await client
    .from(INVOICE_TABLE)
    .select("id, document_date, invoice_number, customer_name, document_status, source_invoice_id")
    .eq("document_group", "RE")
    .gte("document_date", range.start)
    .lt("document_date", range.end)
    .order("document_date", { ascending: true })
    .order("invoice_number", { ascending: true });

  if (invoicesResult.error) {
    throw invoicesResult.error;
  }

  const recordsWithReferences = await attachReportReferences(
    client,
    INVOICE_TABLE,
    invoicesResult.data || [],
    "source_invoice_id",
    "invoice_number"
  );
  return recordsWithReferences.map((record) => mapReceiptReportRecord(record));
}

function mapPendingInvoiceRecord(record, numberField) {
  return {
    id: record.id,
    document_date: record.document_date,
    invoice_number: record[numberField] || "",
    customer_name: record.customer_name || "-",
    document_status: String(record.document_status || "").toLowerCase(),
    grand_total: Number(record.grand_total || 0)
  };
}

async function fetchPendingInvoicesForMonth({ year, month }) {
  const client = requireSupabaseClient();
  const range = getReportMonthRange(year, month);
  const [documentInvResult, documentReceiptResult] = await Promise.all([
    client.from("documents")
      .select("id, document_date, document_number, customer_name, document_status, grand_total")
      .eq("document_group", "INV")
      .gte("document_date", range.start)
      .lt("document_date", range.end)
      .order("document_date", { ascending: true }),
    client.from("documents")
      .select("reference_document_id")
      .eq("document_group", "RE")
      .not("reference_document_id", "is", null)
  ]);

  if (!documentInvResult.error && !documentReceiptResult.error) {
    const referencedInvoiceIds = new Set((documentReceiptResult.data || [])
      .map((record) => record.reference_document_id)
      .filter(Boolean));
    return (documentInvResult.data || [])
      .filter((record) => !referencedInvoiceIds.has(record.id))
      .map((record) => mapPendingInvoiceRecord(record, "document_number"));
  }

  const documentError = documentInvResult.error || documentReceiptResult.error;
  if (!isMissingTableError(documentError) && !isMissingDocumentMetadataError(documentError)) {
    throw documentError;
  }

  const [invoiceResult, receiptResult] = await Promise.all([
    client.from(INVOICE_TABLE)
      .select("id, document_date, invoice_number, customer_name, document_status, grand_total")
      .eq("document_group", "INV")
      .gte("document_date", range.start)
      .lt("document_date", range.end)
      .order("document_date", { ascending: true }),
    client.from(INVOICE_TABLE)
      .select("source_invoice_id")
      .eq("document_group", "RE")
      .not("source_invoice_id", "is", null)
  ]);

  if (invoiceResult.error || receiptResult.error) {
    throw invoiceResult.error || receiptResult.error;
  }

  const referencedInvoiceIds = new Set((receiptResult.data || [])
    .map((record) => record.source_invoice_id)
    .filter(Boolean));
  return (invoiceResult.data || [])
    .filter((record) => !referencedInvoiceIds.has(record.id))
    .map((record) => mapPendingInvoiceRecord(record, "invoice_number"));
}
