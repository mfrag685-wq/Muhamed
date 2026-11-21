// وسيط دفترة (Daftra proxy) لنظام_دفترة_الذكي.html
// يتجاوز حجب CORS: الصفحة تطلب /daftra-proxy/<subdomain>/api2/... من نفس الموقع،
// والخادم يمرّر الطلب إلى https://<subdomain>.daftra.com/api2/... مع ترويسة المفتاح.
// قيود الأمان:
//  - الوجهة دائماً *.daftra.com فقط (النطاق الفرعي أحرف وأرقام وشرطة).
//  - المسارات /api2/ و /v2/ فقط، وطلبات قراءة GET/HEAD فقط.
//  - من نفس الموقع فقط (يُرفض أي طلب من موقع آخر).
//  - المفتاح لا يُسجَّل ولا يُخزَّن، ولا تُمرَّر أي ترويسات أخرى (كوكيز وغيرها).
// كل ما عدا /daftra-proxy/ يُخدم كملفات ثابتة كما كان.

const PREFIX = '/daftra-proxy/';
const SUB_RE = /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/;
const HDR_RE = /^[A-Za-z0-9-]{1,40}$/;
const BLOCKED_HDR = new Set(['host', 'cookie', 'authorization-proxy', 'origin', 'referer', 'content-length', 'connection']);

function err(status, msg) {
  return new Response(JSON.stringify({ proxy_error: msg }), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' },
  });
}

async function proxy(request, url) {
  if (request.method !== 'GET' && request.method !== 'HEAD') return err(405, 'GET/HEAD only');

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

  const keyHeader = request.headers.get('X-Daftra-Key-Header') || 'APIKEY';
  const key = request.headers.get('X-Daftra-Key') || '';
  if (!HDR_RE.test(keyHeader) || BLOCKED_HDR.has(keyHeader.toLowerCase())) return err(400, 'invalid key header name');
  if (!key) return err(400, 'missing API key');

  const target = 'https://' + sub + '.daftra.com' + path + url.search;
  const headers = new Headers({ Accept: 'application/json' });
  headers.set(keyHeader, key);

  let upstream;
  try {
    upstream = await fetch(target, { method: request.method, headers, redirect: 'manual' });
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
