// وسيط دفترة (Daftra proxy) لنظام_دفترة_الذكي.html
// يتجاوز حجب CORS: الصفحة تطلب /daftra-proxy/<subdomain>/api2/... من نفس الموقع،
// والخادم يمرّر الطلب إلى https://<subdomain>.daftra.com/api2/... مع ترويسة المفتاح.
// قيود الأمان:
//  - الوجهة دائماً *.daftra.com فقط (النطاق الفرعي أحرف وأرقام وشرطة).
//  - المسارات /api2/ و /v2/ فقط. القراءة GET/HEAD، والكتابة POST مسموحة فقط لإنشاء القيود
//    (/api2/journals) — والصفحة لا ترسل إلا بعد تأكيد صريح من المستخدم.
//  - من نفس الموقع فقط (يُرفض أي طلب من موقع آخر).
//  - المفتاح لا يُسجَّل ولا يُخزَّن، ولا تُمرَّر أي ترويسات أخرى (كوكيز وغيرها).
// كل ما عدا /daftra-proxy/ يُخدم كملفات ثابتة كما كان.

const PREFIX = '/daftra-proxy/';
const SUB_RE = /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/;
const HDR_RE = /^[A-Za-z0-9-]{1,40}$/;
// المسارات الوحيدة المسموح فيها بالكتابة (إنشاء فقط)
const POST_PATHS = new Set(['/api2/journals', '/api2/journals.json']);
const MAX_BODY = 200 * 1024;
const BLOCKED_HDR = new Set(['host', 'cookie', 'authorization-proxy', 'origin', 'referer', 'content-length', 'connection']);

function err(status, msg) {
  return new Response(JSON.stringify({ proxy_error: msg }), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' },
  });
}

async function proxy(request, url) {
  const isPost = request.method === 'POST';
  if (request.method !== 'GET' && request.method !== 'HEAD' && !isPost) return err(405, 'method not allowed');

  // نفس الموقع فقط
  const origin = request.headers.get('Origin');
  if (origin && origin !== url.origin) return err(403, 'cross-origin not allowed');
  const site = request.headers.get('Sec-Fetch-Site');
  if (site && site !== 'same-origin' && site !== 'none') return err(403, 'cross-site not allowed');

  const rest = url.pathname.slice(PREFIX.length); // <sub>/api2/...
  const slash = rest.indexOf('/');
  if (slash < 1) return err(400, 'missing subdomain or path');
  const sub = rest.slice(0, slash).toLowerCase();
  const path = rest.slice(slash);
  if (!SUB_RE.test(sub)) return err(400, 'invalid subdomain');
  if (!(path.startsWith('/api2/') || path.startsWith('/v2/'))) return err(400, 'path must start with /api2/ or /v2/');
  if (path.includes('..') || path.includes('//')) return err(400, 'invalid path');
  if (isPost && !POST_PATHS.has(path)) return err(405, 'POST allowed only for /api2/journals');

  const keyHeader = request.headers.get('X-Daftra-Key-Header') || 'APIKEY';
  const key = request.headers.get('X-Daftra-Key') || '';
  if (!HDR_RE.test(keyHeader) || BLOCKED_HDR.has(keyHeader.toLowerCase())) return err(400, 'invalid key header name');
  if (!key) return err(400, 'missing API key');

  const target = 'https://' + sub + '.daftra.com' + path + url.search;
  const headers = new Headers({ Accept: 'application/json' });
  headers.set(keyHeader, key);
  let body;
  if (isPost) {
    const ct = request.headers.get('Content-Type') || '';
    if (!ct.startsWith('application/json')) return err(415, 'JSON body required');
    body = await request.text();
    if (body.length > MAX_BODY) return err(413, 'body too large');
    try { JSON.parse(body); } catch (e) { return err(400, 'invalid JSON'); }
    headers.set('Content-Type', 'application/json');
  }

  let upstream;
  try {
    upstream = await fetch(target, { method: request.method, headers, body, redirect: 'manual' });
  } catch (e) {
    return err(502, 'upstream unreachable');
  }
  // لا نتبع إعادة التوجيه حتى لا يُرسل المفتاح لنطاق آخر
  if (upstream.status >= 300 && upstream.status < 400) return err(502, 'upstream redirect (' + upstream.status + ')');

  const out = new Headers();
  const ct = upstream.headers.get('Content-Type');
  if (ct) out.set('Content-Type', ct);
  out.set('Cache-Control', 'no-store');
  return new Response(upstream.body, { status: upstream.status, headers: out });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.startsWith(PREFIX)) return proxy(request, url);
    return env.ASSETS.fetch(request);
  },
};
