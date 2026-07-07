const YIND_AUTH_EMAILS = {
  yodsapong: "yodsapong@yind.local",
  ntpbenz: "ntpbenz@yind.local"
};

function getYindAuthEmail(username) {
  return YIND_AUTH_EMAILS[String(username || "").trim().toLowerCase()] || "";
}

function getYindUsernameFromSession(session) {
  const email = String(session?.user?.email || "").toLowerCase();
  return Object.entries(YIND_AUTH_EMAILS)
    .find(([, authEmail]) => authEmail === email)?.[0] || "";
}

async function signInToYind(username, password) {
  const email = getYindAuthEmail(username);
  if (!email) {
    throw new Error("Username หรือ Password ไม่ถูกต้อง");
  }

  const { data, error } = await supabaseClient.auth.signInWithPassword({ email, password });
  if (error || !data.session) {
    throw new Error("Username หรือ Password ไม่ถูกต้อง");
  }

  const signedInUsername = getYindUsernameFromSession(data.session);
  sessionStorage.setItem("yind_login_username", signedInUsername);
  return data.session;
}

async function redirectIfYindAuthenticated(redirectTo) {
  const { data, error } = await supabaseClient.auth.getSession();
  if (!error && data.session) {
    sessionStorage.setItem("yind_login_username", getYindUsernameFromSession(data.session));
    window.location.replace(redirectTo);
  }
}

async function requireYindAuth(redirectPath, allowedUsername = "") {
  const { data, error } = await supabaseClient.auth.getSession();
  const username = getYindUsernameFromSession(data.session);
  if (error || !data.session || !username) {
    window.location.replace(`login-page.html?redirect=${encodeURIComponent(redirectPath)}`);
    return false;
  }

  if (allowedUsername && username !== allowedUsername) {
    window.location.replace("dashboard-page.html");
    return false;
  }

  sessionStorage.setItem("yind_login_username", username);
  return true;
}

async function signOutOfYind() {
  try {
    await supabaseClient.auth.signOut();
  } finally {
    sessionStorage.removeItem("yind_login_username");
    window.location.href = "login-page.html";
  }
}
