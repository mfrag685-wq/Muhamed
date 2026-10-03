// بناء الموقع: node build.mjs  →  ينتج مجلد dist/ جاهزًا للرفع على Cloudflare Pages.
// بدون أي مكتبات خارجية — Node 18 أو أحدث فقط.
import { mkdir, writeFile, readFile, cp, rm } from 'node:fs/promises'
import { createHash } from 'node:crypto'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { site } from './src/data/site.mjs'
import { services, serviceBySlug } from './src/data/services.mjs'
import { cities, cityServiceText } from './src/data/cities.mjs'
import { posts } from './src/data/posts.mjs'

const ROOT = dirname(fileURLToPath(import.meta.url))
const OUT = join(ROOT, 'dist')
const TODAY = new Date().toISOString().slice(0, 10)

const css = minifyCss(await readFile(join(ROOT, 'src/styles.css'), 'utf8'))
const js = (await readFile(join(ROOT, 'src/main.js'), 'utf8')).trim()
const gaJs = site.ga4
  ? `window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag('js',new Date());gtag('config','${site.ga4}');`
  : ''

// ---------- أدوات ----------
function esc(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c])
}
function minifyCss(s) {
  return s.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\s+/g, ' ').replace(/\s*([{}:;,])\s*/g, '$1').replace(/;}/g, '}').trim()
}
function sha256(s) {
  return "'sha256-" + createHash('sha256').update(s).digest('base64') + "'"
}
const abs = (p) => site.url + p
const wa = (text) => `https://wa.me/${site.whatsapp}?text=${encodeURIComponent(text)}`
const tel = `tel:${site.phone}`
const phoneHtml = () => `<span class="phone">${esc(site.phoneDisplay)}</span>`

const I = {
  wa: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M17.5 14.4c-.3-.1-1.8-.9-2-1-.3-.1-.5-.1-.7.1-.2.3-.8 1-.9 1.2-.2.2-.3.2-.6.1-.3-.1-1.3-.5-2.4-1.5-.9-.8-1.5-1.8-1.7-2.1-.2-.3 0-.5.1-.6l.4-.5c.2-.2.2-.3.3-.5.1-.2 0-.4 0-.5l-.9-2.2c-.2-.6-.5-.5-.7-.5h-.6c-.2 0-.5.1-.8.4-.3.3-1 1-1 2.5s1.1 2.9 1.2 3.1c.1.2 2.1 3.2 5.1 4.5.7.3 1.3.5 1.7.6.7.2 1.4.2 1.9.1.6-.1 1.8-.7 2-1.4.2-.7.2-1.3.2-1.4-.1-.1-.3-.2-.6-.4zM12 2C6.5 2 2 6.5 2 12c0 1.7.5 3.4 1.3 5L2 22l5.1-1.3c1.5.8 3.1 1.2 4.8 1.2 5.5 0 10-4.5 10-10S17.5 2 12 2zm0 18.2c-1.5 0-3-.4-4.3-1.2l-.3-.2-3 .8.8-2.9-.2-.3C4.2 15.1 3.8 13.6 3.8 12 3.8 7.5 7.5 3.8 12 3.8s8.2 3.7 8.2 8.2-3.7 8.2-8.2 8.2z"/></svg>',
  call: '<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1C10.6 21 3 13.4 3 4c0-.6.4-1 1-1h3.5c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.3 0 .7-.2 1L6.6 10.8z"/></svg>',
  check: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" aria-hidden="true"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>',
  menu: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" aria-hidden="true"><path d="M4 7h16M4 12h16M4 17h16"/></svg>',
  snow: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M12 2v20M4.9 6l14.2 12M19.1 6L4.9 18M9 4l3 2 3-2M9 20l3-2 3 2"/></svg>',
  truck: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M2 6h12v10H2zM14 9h4l4 4v3h-8"/><circle cx="6" cy="18" r="2"/><circle cx="18" cy="18" r="2"/></svg>',
  flatbed: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M1 15h15V8h4l3 4v3h-2M5 11h8"/><circle cx="5" cy="17" r="2"/><circle cx="18" cy="17" r="2"/></svg>',
  sofa: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 11V8a3 3 0 013-3h10a3 3 0 013 3v3M2 13a2 2 0 014 0v2h12v-2a2 2 0 014 0v5H2zM5 18v2M19 18v2"/></svg>',
  pill: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="8.5" width="18" height="7" rx="3.5" transform="rotate(-45 12 12)"/><path d="M8.5 8.5l7 7"/></svg>',
  food: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M3 14h18a9 9 0 01-18 0zM12 5v2M2 14h20M8 9.5a6 6 0 018 0"/></svg>',
  doc: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M6 2h9l5 5v15H6zM14 2v6h6M9 13h8M9 17h6"/></svg>',
  clock: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>',
  shield: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M12 2l8 3v6c0 5-3.5 9.5-8 11-4.5-1.5-8-6-8-11V5z"/><path d="M8.5 12l2.5 2.5 4.5-5"/></svg>',
  tag: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M3 12V3h9l9 9-9 9z"/><circle cx="7.5" cy="7.5" r="1.5"/></svg>',
  map: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M12 22s7-6.5 7-12a7 7 0 00-14 0c0 5.5 7 12 7 12z"/><circle cx="12" cy="10" r="2.5"/></svg>',
}

function img(name, alt, { eager = false, sizes = '(max-width: 980px) 100vw, 520px' } = {}) {
  const src = (w) => `/assets/img/${name}-${w}.webp`
  return `<img src="${src(800)}" srcset="${src(480)} 480w, ${src(800)} 800w, ${src(1024)} 1024w" sizes="${sizes}" width="1024" height="768" alt="${esc(alt)}"${eager ? ' fetchpriority="high"' : ' loading="lazy" decoding="async"'}>`
}

// ---------- القالب العام ----------
const NAV = [
  ['/', 'الرئيسية'],
  ['/services', 'خدماتنا'],
  ['/services/refrigerated-truck-rental', 'دينا تبريد'],
  ['/corporate', 'للشركات'],
  ['/blog', 'المدونة'],
  ['/about', 'من نحن'],
  ['/contact', 'تواصل معنا'],
]

const orgId = abs('/#organization')
function orgSchema() {
  const o = {
    '@type': 'MovingCompany',
    '@id': orgId,
    name: `${site.name} | ${site.nameEn}`,
    alternateName: [site.name, site.nameEn],
    url: site.url + '/',
    logo: abs('/assets/icon-512.png'),
    image: abs('/assets/img/truck-fleet-og.jpg'),
    description: site.description,
    telephone: site.phone,
    priceRange: '$$',
    areaServed: cities.map((c) => ({ '@type': 'City', name: c.name })),
    address: { '@type': 'PostalAddress', addressCountry: site.address.country, addressLocality: site.address.city },
    openingHoursSpecification: {
      '@type': 'OpeningHoursSpecification',
      dayOfWeek: ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      opens: site.hoursSchema.opens,
      closes: site.hoursSchema.closes,
    },
  }
  if (site.legalName) o.legalName = site.legalName
  if (site.email) o.email = site.email
  if (site.vat) o.vatID = site.vat
  if (site.address.street) o.address.streetAddress = site.address.street
  if (site.address.postalCode) o.address.postalCode = site.address.postalCode
  const same = Object.values(site.social).filter(Boolean)
  if (same.length) o.sameAs = same
  return o
}
function crumbsSchema(items) {
  return {
    '@type': 'BreadcrumbList',
    itemListElement: items.map(([url, name], i) => ({ '@type': 'ListItem', position: i + 1, name, item: abs(url) })),
  }
}
function faqSchema(faq) {
  return {
    '@type': 'FAQPage',
    mainEntity: faq.map(([q, a]) => ({ '@type': 'Question', name: q, acceptedAnswer: { '@type': 'Answer', text: a } })),
  }
}
function crumbsHtml(items) {
  return `<nav class="crumbs" aria-label="مسار الصفحة"><ol>${items
    .map(([url, name], i) =>
      i === items.length - 1 ? `<li><span aria-current="page">${esc(name)}</span></li>` : `<li><a href="${url}">${esc(name)}</a></li>`,
    )
    .join('')}</ol></nav>`
}

function header(path) {
  const active = (u) => (u === path || (u !== '/' && path.startsWith(u + '/')) ? ' aria-current="page"' : '')
  return `<a class="skip" href="#main">تخطَّ إلى المحتوى</a>
<header class="site-header"><div class="wrap nav">
<a class="brand" href="/"><img src="/assets/img/logo-72.webp" width="36" height="36" alt="">${esc(site.name)}<small>${esc(site.nameEn)}</small></a>
<ul class="menu" id="menu">${NAV.map(([u, t]) => `<li><a href="${u}"${active(u)}>${t}</a></li>`).join('')}</ul>
<div class="nav-cta"><a class="btn btn-ghost btn-sm" href="${tel}">${I.call}<span>${phoneHtml()}</span></a><a class="btn btn-wa btn-sm" href="${wa('مرحبًا، أرغب في الاستفسار عن خدمات النقل')}" target="_blank" rel="noopener" aria-label="تواصل عبر واتساب">${I.wa}<span>واتساب</span></a></div>
<button class="menu-btn" type="button" aria-controls="menu" aria-expanded="false" aria-label="القائمة">${I.menu}</button>
</div><div class="hazard"></div></header>`
}

function footer() {
  const legal = [
    site.legalName && esc(site.legalName),
    site.cr && `السجل التجاري: ${esc(site.cr)}`,
    site.vat && `الرقم الضريبي: ${esc(site.vat)}`,
  ].filter(Boolean)
  const addr = [site.address.street, site.address.district, site.address.city].filter(Boolean).join('، ')
  const social = Object.entries(site.social).filter(([, v]) => v)
  const socialNames = { snapchat: 'سناب شات', tiktok: 'تيك توك', instagram: 'إنستغرام', x: 'إكس' }
  return `<footer class="site-footer"><div class="wrap">
<div class="foot-grid">
<div><h2>${esc(site.name)} ${esc(site.tagline)}</h2><p>${esc(site.description)}</p></div>
<div><h2>الخدمات</h2><ul>${services.map((s) => `<li><a href="/services/${s.slug}">${esc(s.short)}</a></li>`).join('')}</ul></div>
<div><h2>المدن</h2><ul>${cities.map((c) => `<li><a href="/services/refrigerated-truck-rental/${c.slug}">دينا تبريد ${esc(c.name)}</a></li>`).join('')}</ul></div>
<div><h2>تواصل معنا</h2><ul>
<li><a href="${tel}">${phoneHtml()}</a></li>
<li><a href="${wa('مرحبًا')}" target="_blank" rel="noopener">واتساب</a></li>
${site.email ? `<li><a href="mailto:${esc(site.email)}">${esc(site.email)}</a></li>` : ''}
${addr ? `<li>${esc(addr)}</li>` : ''}
<li>${esc(site.hours)}</li>
${social.map(([k, v]) => `<li><a href="${esc(v)}" target="_blank" rel="noopener">${socialNames[k]}</a></li>`).join('')}
</ul></div>
</div>
<div class="legal"><span>© ${new Date().getFullYear()} ${esc(site.name)} | ${esc(site.nameEn)}${legal.length ? ' — ' + legal.join(' — ') : ''}</span>
<span><a href="/privacy">سياسة الخصوصية</a> · <a href="/terms">الشروط والأحكام</a></span></div>
</div></footer>
<div class="fab"><a class="f-call" href="${tel}" aria-label="اتصل الآن">${I.call}<span>اتصل الآن</span></a><a class="f-wa" href="${wa('مرحبًا، أرغب في طلب خدمة نقل')}" target="_blank" rel="noopener" aria-label="تواصل عبر واتساب">${I.wa}<span>واتساب</span></a></div>`
}

function layout({ path, title, desc, body, schema = [], og = 'truck-fleet', noindex = false, ogType = 'website' }) {
  const canonical = abs(path === '/' ? '/' : path)
  const ld = { '@context': 'https://schema.org', '@graph': [orgSchema(), ...schema] }
  return `<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<meta name="description" content="${esc(desc)}">
${noindex ? '<meta name="robots" content="noindex, follow">' : '<meta name="robots" content="index, follow, max-image-preview:large">'}
<link rel="canonical" href="${canonical}">
<meta name="theme-color" content="#0b0d10">
<link rel="preload" href="/assets/fonts/plex-arabic-700.woff2" as="font" type="font/woff2" crossorigin>
<link rel="icon" href="/favicon.ico" sizes="any">
<link rel="icon" href="/assets/favicon-32.png" type="image/png" sizes="32x32">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<link rel="manifest" href="/manifest.webmanifest">
<meta property="og:site_name" content="${esc(site.name)} | ${esc(site.nameEn)}">
<meta property="og:locale" content="ar_SA">
<meta property="og:type" content="${ogType}">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(desc)}">
<meta property="og:url" content="${canonical}">
<meta property="og:image" content="${abs(`/assets/img/${og}-og.jpg`)}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
${site.googleVerification ? `<meta name="google-site-verification" content="${esc(site.googleVerification)}">` : ''}
<style>${css}</style>
<script type="application/ld+json">${JSON.stringify(ld).replace(/</g, '\\u003c')}</script>
${site.ga4 ? `<script async src="https://www.googletagmanager.com/gtag/js?id=${esc(site.ga4)}"></script><script>${gaJs}</script>` : ''}
</head>
<body>
${header(path)}
<main id="main">
${body}
</main>
${footer()}
<script>${js}</script>
</body>
</html>
`
}

// ---------- مكونات ----------
function serviceCard(s) {
  return `<article class="card"><div class="card-img">${img(s.img, s.imgAlt, { sizes: '(max-width: 640px) 100vw, (max-width: 980px) 50vw, 360px' })}</div>
<div class="card-body"><h3><a href="/services/${s.slug}">${esc(s.short)}</a></h3><p>${esc(s.card)}</p><span class="more" aria-hidden="true">تفاصيل الخدمة ←</span></div></article>`
}
function faqHtml(faq, heading = 'الأسئلة الشائعة') {
  return `<div class="faq"><h2>${heading}</h2>${faq.map(([q, a]) => `<details><summary>${esc(q)}</summary><p>${esc(a)}</p></details>`).join('')}</div>`
}
function ctaBand(text = 'جاهز تنقل حمولتك؟', sub = 'أرسل التفاصيل الآن ونرد عليك بالسعر والموعد.', waText = 'مرحبًا، أرغب في طلب خدمة نقل') {
  return `<div class="cta-band"><div class="wrap"><div><h2>${esc(text)}</h2><p>${esc(sub)}</p></div>
<div class="hero-ctas" style="margin:0"><a class="btn btn-primary" href="/quote">اطلب عرض سعر</a><a class="btn btn-wa" href="${wa(waText)}" target="_blank" rel="noopener">${I.wa}واتساب</a></div></div></div>`
}
function asidePanel(s, waText) {
  return `<aside class="aside">
<div class="panel"><h2>اطلب ${esc(s.short)}</h2><p>أرسل نوع الحمولة والمسار والموعد، ونرد عليك بالسعر قبل التنفيذ.</p>
<a class="btn btn-wa" href="${wa(waText)}" target="_blank" rel="noopener">${I.wa}اطلب عبر واتساب</a>
<a class="btn btn-primary" href="/quote?service=${s.slug}">نموذج طلب عرض سعر</a>
<a class="btn btn-ghost" href="${tel}">${I.call}${phoneHtml()}</a></div>
<div class="panel-light"><h3>كيف تطلب؟</h3><ol class="steps-list"><li>أرسل تفاصيل الحمولة</li><li>حدد المسار والموعد</li><li>استلم السعر وأكد الحجز</li></ol></div>
<div class="panel-light"><h3>خدمات أخرى</h3><ul>${services.filter((x) => x.slug !== s.slug).map((x) => `<li><a href="/services/${x.slug}">${esc(x.short)}</a></li>`).join('')}</ul></div>
</aside>`
}
// شريط الثقة: لا يعرض إلا ما له قيمة فعلية
function trustBadges() {
  const items = ['سعر واضح قبل التنفيذ', 'داخل المدن وبينها', esc(site.hours)]
  if (site.cr) items.unshift(`منشأة مسجلة — س.ت ${esc(site.cr)}`)
  return `<ul class="badges">${items.map((t) => `<li>${I.check}${t}</li>`).join('')}</ul>`
}

// ---------- الصفحات ----------
const pages = [] // { file, path, html, priority, changefreq, noindex }
function page(path, html, { priority = 0.6, noindex = false, file } = {}) {
  pages.push({ path, html, priority, noindex, file: file || (path === '/' ? 'index.html' : path.slice(1) + '.html') })
}

// الرئيسية
{
  const s = site.stats
  const stats = [
    s.years && [s.years, 'سنوات خبرة'],
    s.trips && [s.trips, 'رحلة منفذة'],
    [String(cities.length), 'مدن رئيسية نغطيها'],
    [String(services.length), 'خدمات نقل متخصصة'],
  ].filter(Boolean)
  const faq = [
    ['ما الخدمات التي تقدمها وصلها؟', 'نوفر إيجار دينا تبريد وتجميد، لوري، سطحات، نقل عفش، نقل الأدوية المبرد، نقل الإعاشة والتموين، وعقود نقل شهرية وسنوية للشركات.'],
    ['ما المدن التي تخدمونها؟', 'نخدم الرياض وجدة والدمام ومكة المكرمة والمدينة المنورة، ونرتب الرحلات بين مدن ومناطق المملكة.'],
    ['كيف أحصل على سعر؟', 'أرسل نوع الحمولة والمسار والموعد عبر واتساب أو نموذج طلب السعر، ونرد عليك بالسعر قبل التنفيذ.'],
    ['هل توجد عقود للشركات؟', 'نعم، نوفر عقود نقل وتأجير شهرية وسنوية بجدول تشغيل ثابت وأسعار خاصة.'],
  ]
  const body = `
<section class="hero"><div class="wrap hero-grid">
<div><span class="eyebrow">${esc(site.name)} ${esc(site.tagline)} في السعودية</span>
<h1>نقل مبرد وتأجير دينات ولوريات <em>نوصّلها في موعدها</em></h1>
<p class="lead">دينا تبريد وتجميد، لوري، سطحات، نقل عفش، ونقل الأدوية والإعاشة للشركات، في الرياض وجدة والدمام ومكة والمدينة وبين مدن المملكة.</p>
<div class="hero-ctas"><a class="btn btn-primary" href="/quote">اطلب عرض سعر</a><a class="btn btn-wa" href="${wa('مرحبًا، أرغب في طلب خدمة نقل')}" target="_blank" rel="noopener">${I.wa}واتساب</a><a class="btn btn-ghost" href="${tel}">${I.call}${phoneHtml()}</a></div>
${trustBadges()}</div>
<div class="hero-img">${img('truck-refrigerated', 'دينا تبريد من أسطول وصلها جاهزة للتحميل', { eager: true })}</div>
</div></section>

<section><div class="wrap">
<div class="section-head"><span class="eyebrow">خدماتنا</span><h2>حلول نقل وتأجير لكل نوع حمولة</h2><p>من شحنة أدوية تحتاج 2 إلى 8 درجات، إلى معدات تحتاج سطحة، إلى عفش بيت كامل.</p></div>
<div class="grid g4">${services.map(serviceCard).join('')}</div>
</div></section>

<section class="dark"><div class="wrap">
<div class="section-head"><span class="eyebrow">لماذا وصلها</span><h2>نقل تعتمد عليه منشأتك</h2></div>
<div class="grid g4">
<div class="feature"><div class="ic">${I.tag}</div><h3>سعر واضح قبل التحميل</h3><p>تعرف التكلفة النهائية قبل التنفيذ، بدون مبالغ تظهر بعد الرحلة.</p></div>
<div class="feature"><div class="ic">${I.snow}</div><h3>حرارة مضبوطة</h3><p>نجهّز الصندوق ونضبط الدرجة قبل وصول المركبة لموقع التحميل.</p></div>
<div class="feature"><div class="ic">${I.clock}</div><h3>التزام بالموعد</h3><p>نرتب وقت التحميل والتسليم مسبقًا ونتجنب أوقات الذروة.</p></div>
<div class="feature"><div class="ic">${I.shield}</div><h3>عقود مرنة للشركات</h3><p>رحلة واحدة، أو عقد شهري وسنوي بمركبات إضافية في المواسم.</p></div>
</div>
<div class="stats">${stats.map(([n, t]) => `<div class="stat"><b>${esc(n)}</b><span>${esc(t)}</span></div>`).join('')}</div>
</div></section>

<section><div class="wrap">
<div class="section-head"><span class="eyebrow">كيف تطلب</span><h2>ثلاث خطوات وتتحرك شحنتك</h2></div>
<ol class="steps">
<li><h3>أرسل التفاصيل</h3><p>نوع الحمولة والكمية، والدرجة المطلوبة إن كانت مبردة.</p></li>
<li><h3>حدد المسار والموعد</h3><p>موقع التحميل والوجهة واليوم والساعة.</p></li>
<li><h3>استلم السعر ونبدأ</h3><p>نؤكد معك السعر والموعد، وتصل المركبة جاهزة.</p></li>
</ol>
</div></section>

<section class="alt"><div class="wrap">
<div class="section-head"><span class="eyebrow">نغطي مدن المملكة</span><h2>خدماتنا في مدينتك</h2><p>نخدم المدن الرئيسية، ونرتب الرحلات بين مدن ومناطق المملكة.</p></div>
${cities.map((c) => `<h3>${esc(c.name)}</h3><ul class="chips" style="margin-bottom:18px">${Object.keys(cityServiceText).map((sl) => `<li><a href="/services/${sl}/${c.slug}">${esc(serviceBySlug[sl].short)} ${esc(c.name)}</a></li>`).join('')}</ul>`).join('')}
</div></section>

<section><div class="wrap narrow">${faqHtml(faq)}</div></section>
${ctaBand()}`
  page('/', layout({ path: '/', title: `${site.name} ${site.tagline} | دينا تبريد، لوري، سطحات ونقل عفش في السعودية`, desc: site.description, body, schema: [{ '@type': 'WebSite', '@id': abs('/#website'), url: site.url + '/', name: site.name, inLanguage: 'ar-SA', publisher: { '@id': orgId } }, faqSchema(faq)] }), { priority: 1 })
}

// صفحة جميع الخدمات
{
  const crumbs = [['/', 'الرئيسية'], ['/services', 'خدماتنا']]
  const body = `<section class="hero"><div class="wrap" style="padding-block:44px">${crumbsHtml(crumbs)}<h1>خدمات النقل والتأجير</h1><p class="lead">اختر الخدمة المناسبة لحمولتك، أو أرسل لنا التفاصيل ونرشّح لك المركبة الأنسب.</p></div></section>
<section><div class="wrap"><div class="grid g4">${services.map(serviceCard).join('')}</div></div></section>${ctaBand()}`
  page('/services', layout({ path: '/services', title: `خدمات النقل والتأجير في السعودية | ${site.name}`, desc: 'جميع خدمات وصلها: دينا تبريد وتجميد، لوري، سطحات، نقل عفش، نقل الأدوية والإعاشة، وعقود نقل للشركات.', body, schema: [crumbsSchema(crumbs)] }), { priority: 0.8 })
}

// صفحات الخدمات
for (const s of services) {
  const path = `/services/${s.slug}`
  const crumbs = [['/', 'الرئيسية'], ['/services', 'خدماتنا'], [path, s.short]]
  const waText = `مرحبًا، أرغب في الاستفسار عن ${s.short}`
  const cityList = cityServiceText[s.slug]
  const body = `
<section class="hero"><div class="wrap hero-grid">
<div>${crumbsHtml(crumbs)}<h1>${esc(s.h1)}</h1><p class="lead">${esc(s.lead)}</p>
<div class="hero-ctas"><a class="btn btn-wa" href="${wa(waText)}" target="_blank" rel="noopener">${I.wa}اطلب عبر واتساب</a><a class="btn btn-primary" href="/quote?service=${s.slug}">اطلب عرض سعر</a></div>
<ul class="badges">${s.bullets.map((b) => `<li>${I.check}${esc(b)}</li>`).join('')}</ul></div>
<div class="hero-img">${img(s.img, s.imgAlt, { eager: true })}</div>
</div></section>
<section><div class="wrap content-grid">
<article class="prose">
${s.sections.map((x) => `<h2>${esc(x.h2)}</h2>\n${x.html}`).join('\n')}
${cityList ? `<h2>${esc(s.short)} في مدن المملكة</h2><p>لكل مدينة صفحة بتفاصيل الخدمة فيها:</p><ul class="chips">${cities.map((c) => `<li><a href="${path}/${c.slug}">${esc(s.short)} ${esc(c.name)}</a></li>`).join('')}</ul>` : ''}
<div style="margin-top:2em">${faqHtml(s.faq)}</div>
</article>
${asidePanel(s, waText)}
</div></section>
<section class="alt"><div class="wrap"><div class="section-head"><span class="eyebrow">خدمات مرتبطة</span><h2>قد تحتاج أيضًا</h2></div>
<div class="grid g3">${s.related.map((r) => serviceCard(serviceBySlug[r])).join('')}</div></div></section>
${ctaBand(`جاهز تطلب ${s.short}؟`, 'أرسل تفاصيل حمولتك ونؤكد معك السعر والموعد.', waText)}`
  const schema = [
    { '@type': 'Service', '@id': abs(path + '#service'), name: s.short, serviceType: s.short, description: s.metaDesc, url: abs(path), provider: { '@id': orgId }, areaServed: { '@type': 'Country', name: 'المملكة العربية السعودية' }, image: abs(`/assets/img/${s.img}-og.jpg`) },
    crumbsSchema(crumbs),
    faqSchema(s.faq),
  ]
  page(path, layout({ path, title: s.title, desc: s.metaDesc, body, schema, og: s.img }), { priority: 0.9 })
}

// صفحات المدن
for (const [slug, byCity] of Object.entries(cityServiceText)) {
  const s = serviceBySlug[slug]
  for (const c of cities) {
    const t = byCity[c.slug]
    const path = `/services/${slug}/${c.slug}`
    const name = `${s.short} ${c.name}`
    const crumbs = [['/', 'الرئيسية'], ['/services', 'خدماتنا'], [`/services/${slug}`, s.short], [path, c.name]]
    const waText = `مرحبًا، أرغب في ${s.short} في ${c.name}`
    const faq = [
      [`هل تتوفر خدمة ${s.short} في جميع أحياء ${c.name}؟`, `نعم، نخدم أحياء ${c.name} ومناطقها الصناعية، مثل ${c.areas.slice(0, 4).join(' و')}، ونرتب الوصول حسب أنظمة دخول المركبات في كل منطقة.`],
      [`هل يمكن النقل من ${c.name} إلى مدينة أخرى؟`, `نعم، ننفذ رحلات من ${c.name} مثل ${c.routes.slice(0, 3).join('، ')}، ويُحدد السعر حسب المسافة ونوع الحمولة.`],
      [`كيف أحصل على سعر ${name}؟`, 'أرسل نوع الحمولة والكمية وموقع التحميل والوجهة والموعد عبر واتساب أو نموذج طلب السعر، ونرد عليك بالسعر قبل التنفيذ.'],
    ]
    const others = cities.filter((x) => x.slug !== c.slug)
    const body = `
<section class="hero"><div class="wrap hero-grid">
<div>${crumbsHtml(crumbs)}<span class="eyebrow">${esc(c.region)}</span><h1>${esc(name)}</h1><p class="lead">${esc(c.intro)}</p>
<div class="hero-ctas"><a class="btn btn-wa" href="${wa(waText)}" target="_blank" rel="noopener">${I.wa}اطلب عبر واتساب</a><a class="btn btn-primary" href="/quote?service=${slug}">اطلب عرض سعر</a></div></div>
<div class="hero-img">${img(s.img, `${s.short} في ${c.name}`, { eager: true })}</div>
</div></section>
<section><div class="wrap content-grid"><article class="prose">
<h2>${esc(s.short)} في ${esc(c.name)}</h2>
<p>${esc(t.p)}</p>
<p><b>نصيحة لعملائنا في ${esc(c.name)}:</b> ${esc(t.tip)}</p>
<h2>المناطق التي نخدمها في ${esc(c.name)}</h2>
<p>نصل إلى جميع أحياء ${esc(c.name)} ومناطقها الصناعية، ومنها:</p>
<ul class="chips">${c.areas.map((a) => `<li><span>${esc(a)}</span></li>`).join('')}</ul>
<h2>رحلات شائعة من ${esc(c.name)}</h2>
<ul class="check-list">${c.routes.map((r) => `<li>${esc(r)}</li>`).join('')}</ul>
<h2>عن خدمة ${esc(s.short)}</h2>
<p>${esc(s.lead)} <a href="/services/${slug}">تفاصيل الخدمة الكاملة</a>.</p>
<ul class="check-list">${s.bullets.map((b) => `<li>${esc(b)}</li>`).join('')}</ul>
<div style="margin-top:2em">${faqHtml(faq)}</div>
<h2>${esc(s.short)} في مدن أخرى</h2>
<ul class="chips">${others.map((x) => `<li><a href="/services/${slug}/${x.slug}">${esc(s.short)} ${esc(x.name)}</a></li>`).join('')}</ul>
</article>
${asidePanel(s, waText)}
</div></section>
${ctaBand(`تحتاج ${name}؟`, 'أرسل التفاصيل الآن ونؤكد معك السعر والموعد.', waText)}`
    const schema = [
      { '@type': 'Service', name, serviceType: s.short, description: `${s.short} في ${c.name}: ${t.p}`, url: abs(path), provider: { '@id': orgId }, areaServed: { '@type': 'City', name: c.name } },
      crumbsSchema(crumbs),
      faqSchema(faq),
    ]
    page(path, layout({ path, title: `${name} | ${s.short} في ${c.name} – ${site.name}`, desc: `${s.short} في ${c.name} و${c.areas.slice(0, 2).join(' و')}، ورحلات ${c.routes[0]}. سعر واضح قبل التنفيذ، اطلب عبر واتساب أو الاتصال.`, body, schema, og: s.img }), { priority: 0.7 })
  }
}

// صفحة الشركات
{
  const path = '/corporate'
  const crumbs = [['/', 'الرئيسية'], [path, 'للشركات']]
  const s = serviceBySlug['corporate-transport-contracts']
  const body = `<section class="hero"><div class="wrap" style="padding-block:44px">${crumbsHtml(crumbs)}<h1>حلول النقل للشركات والمؤسسات</h1><p class="lead">نقل مبرد للأغذية والأدوية، توزيع يومي، ورحلات بين المدن بعقود شهرية وسنوية. شريك نقل واحد بدل البحث عن مركبة كل مرة.</p>
<div class="hero-ctas"><a class="btn btn-primary" href="/quote?service=corporate-transport-contracts">اطلب عرض سعر للعقد</a><a class="btn btn-wa" href="${wa('مرحبًا، أرغب في عرض عقد نقل لمنشأتنا')}" target="_blank" rel="noopener">${I.wa}واتساب</a></div></div></section>
<section><div class="wrap"><div class="section-head"><h2>قطاعات نخدمها</h2></div><div class="grid g3">${['catering-transport', 'pharmaceutical-transport', 'refrigerated-truck-rental', 'lorry-rental', 'flatbed-rental', 'corporate-transport-contracts'].map((x) => serviceCard(serviceBySlug[x])).join('')}</div></div></section>
<section class="alt"><div class="wrap narrow prose">${s.sections.map((x) => `<h2>${esc(x.h2)}</h2>${x.html}`).join('')}${faqHtml(s.faq)}</div></section>${ctaBand('نجهّز لك عرضًا مكتوبًا', 'أرسل نوع النشاط والمواقع وعدد الرحلات المتوقع.', 'مرحبًا، أرغب في عرض عقد نقل لمنشأتنا')}`
  page(path, layout({ path, title: `عقود وحلول نقل للشركات في السعودية | ${site.name}`, desc: 'حلول نقل للشركات: نقل مبرد للأغذية والأدوية، توزيع يومي، ورحلات بين المدن بعقود شهرية وسنوية وأسعار خاصة.', body, schema: [crumbsSchema(crumbs), faqSchema(s.faq)] }), { priority: 0.8 })
}

// طلب عرض سعر
{
  const path = '/quote'
  const crumbs = [['/', 'الرئيسية'], [path, 'طلب عرض سعر']]
  const body = `<section class="hero"><div class="wrap" style="padding-block:40px">${crumbsHtml(crumbs)}<h1>اطلب عرض سعر</h1><p class="lead">املأ التفاصيل وستُفتح رسالة واتساب جاهزة بطلبك. نرد عليك بالسعر قبل التنفيذ.</p></div></section>
<section><div class="wrap content-grid">
<form class="form" id="quote-form" data-wa="${site.whatsapp}" novalidate>
<div class="form-grid">
<div class="field full"><label for="f-service">الخدمة</label><select id="f-service" name="service" required>${services.map((s) => `<option value="${s.slug}"${s.temp ? ` data-temp="${s.tempDefault || 0}"` : ''}>${esc(s.short)}</option>`).join('')}</select></div>
<div class="field"><label for="f-from">من (مدينة / حي)</label><input id="f-from" name="from" required autocomplete="address-level2" placeholder="مثال: الرياض – السلي"></div>
<div class="field"><label for="f-to">إلى (مدينة / حي)</label><input id="f-to" name="to" required placeholder="مثال: جدة – الخمرة"></div>
<div class="field"><label for="f-date">الموعد</label><input id="f-date" name="date" type="date"></div>
<div class="field"><label for="f-cargo">نوع الحمولة</label><input id="f-cargo" name="cargo" required placeholder="مثال: لحوم مجمدة، عفش شقة، معدات"></div>
<div class="field"><label for="f-size">الكمية / الوزن <span class="opt">(تقريبي)</span></label><input id="f-size" name="size" placeholder="مثال: 3 طن، 40 كرتون"></div>
<div class="field" id="temp-field"><label for="f-temp">درجة الحرارة المطلوبة</label><select id="f-temp" name="temp"><option>تبريد (0 إلى 8 درجات)</option><option>تجميد (−18 أو أقل)</option><option>أدوية (2 إلى 8 درجات)</option><option>حرارة مضبوطة (15 إلى 25)</option><option>غير متأكد – أحتاج استشارة</option></select></div>
<div class="field"><label for="f-name">الاسم</label><input id="f-name" name="name" required autocomplete="name"></div>
<div class="field"><label for="f-phone">رقم الجوال</label><input id="f-phone" name="phone" type="tel" required autocomplete="tel" inputmode="tel" pattern="[0-9+ ]{9,15}" placeholder="05XXXXXXXX" dir="ltr"></div>
<div class="field full"><label for="f-notes">ملاحظات <span class="opt">(اختياري)</span></label><textarea id="f-notes" name="notes" placeholder="عدد نقاط التسليم، الحاجة لعمال، الدور والمصعد..."></textarea></div>
</div>
<button class="btn btn-wa" type="submit">${I.wa}أرسل الطلب عبر واتساب</button>
<p class="form-hint">لا نحفظ بياناتك في الموقع؛ تُرسل مباشرة في رسالة واتساب. أو اتصل بنا: <a href="${tel}">${phoneHtml()}</a></p>
</form>
<aside class="aside"><div class="panel"><h2>تفضّل الاتصال؟</h2><p>${esc(site.hours)}</p><a class="btn btn-primary" href="${tel}">${I.call}${phoneHtml()}</a></div>
<div class="panel-light"><h3>ما الذي يسرّع الرد؟</h3><ul class="check-list"><li>نوع الحمولة وكميتها</li><li>الحي في مدينة التحميل والوجهة</li><li>الموعد المطلوب</li><li>صور للعفش أو الحمولة (ترسلها في واتساب)</li></ul></div></aside>
</div></section>`
  page(path, layout({ path, title: `اطلب عرض سعر نقل | ${site.name}`, desc: 'اطلب عرض سعر لدينا تبريد أو لوري أو سطحة أو نقل عفش. املأ التفاصيل وأرسلها عبر واتساب ونرد عليك بالسعر قبل التنفيذ.', body, schema: [crumbsSchema(crumbs)] }), { priority: 0.7 })
}

// المدونة
{
  const crumbs = [['/', 'الرئيسية'], ['/blog', 'المدونة']]
  const body = `<section class="hero"><div class="wrap" style="padding-block:44px">${crumbsHtml(crumbs)}<h1>مدونة وصلها</h1><p class="lead">أدلة عملية عن النقل المبرد ونقل العفش وتأجير الشاحنات في السعودية.</p></div></section>
<section><div class="wrap"><div class="grid g3">${posts.map((p) => `<article class="card"><div class="card-img">${img(p.img, p.title, { sizes: '(max-width: 640px) 100vw, 360px' })}</div><div class="card-body"><h2 style="font-size:19px"><a href="/blog/${p.slug}" style="text-decoration:none">${esc(p.title)}</a></h2><p>${esc(p.excerpt)}</p><span class="more">اقرأ المقال ←</span></div></article>`).join('')}</div></div></section>`
  page('/blog', layout({ path: '/blog', title: `المدونة | أدلة النقل المبرد ونقل العفش – ${site.name}`, desc: 'أدلة ونصائح عملية عن النقل المبرد والمجمد ونقل العفش وتأجير الشاحنات في السعودية.', body, schema: [crumbsSchema(crumbs)] }), { priority: 0.6 })
  for (const p of posts) {
    const path = `/blog/${p.slug}`
    const pc = [['/', 'الرئيسية'], ['/blog', 'المدونة'], [path, p.title]]
    const s = serviceBySlug[p.service]
    const body = `<section class="hero"><div class="wrap article" style="padding-block:40px">${crumbsHtml(pc)}<h1>${esc(p.title)}</h1><p class="post-meta"><time datetime="${p.date}">${new Date(p.date).toLocaleDateString('ar-SA-u-ca-gregory', { year: 'numeric', month: 'long', day: 'numeric' })}</time></p></div></section>
<section><div class="wrap content-grid"><article class="prose article">${p.html}<p><a href="/services/${s.slug}">تعرّف على خدمة ${esc(s.short)}</a></p></article>${asidePanel(s, `مرحبًا، أرغب في الاستفسار عن ${s.short}`)}</div></section>${ctaBand()}`
    const schema = [
      { '@type': 'BlogPosting', headline: p.title, description: p.metaDesc, datePublished: p.date, dateModified: p.date, inLanguage: 'ar-SA', image: abs(`/assets/img/${p.img}-og.jpg`), mainEntityOfPage: abs(path), author: { '@id': orgId }, publisher: { '@id': orgId } },
      crumbsSchema(pc),
    ]
    page(path, layout({ path, title: `${p.title} | ${site.name}`, desc: p.metaDesc, body, schema, og: p.img, ogType: 'article' }), { priority: 0.5 })
  }
}

// من نحن / تواصل / الخصوصية / الشروط
function simplePage(path, h1, title, desc, inner, priority = 0.4) {
  const crumbs = [['/', 'الرئيسية'], [path, h1]]
  const body = `<section class="hero"><div class="wrap" style="padding-block:40px">${crumbsHtml(crumbs)}<h1>${esc(h1)}</h1></div></section><section><div class="wrap narrow prose">${inner}</div></section>`
  page(path, layout({ path, title, desc, body, schema: [crumbsSchema(crumbs)] }), { priority })
}
simplePage('/about', 'من نحن', `من نحن | ${site.name} ${site.tagline}`, 'تعرّف على وصلها: شركة سعودية للنقل والتأجير، متخصصة في النقل المبرد وتأجير الدينات واللوريات والسطحات ونقل العفش.', `
<p><b>${esc(site.name)} | ${esc(site.nameEn)}</b> منشأة سعودية للنقل والتأجير، نخدم الأفراد والشركات في الرياض وجدة والدمام ومكة المكرمة والمدينة المنورة وبين مدن المملكة.</p>
<p>بدأنا من فكرة بسيطة: العميل يريد أن تصل حمولته في موعدها وبحالتها، وأن يعرف السعر قبل أن يبدأ. على هذا نبني كل رحلة.</p>
<h2>ماذا نقدم</h2><ul class="check-list">${services.map((s) => `<li><a href="/services/${s.slug}">${esc(s.short)}</a>: ${esc(s.card)}</li>`).join('')}</ul>
<h2>قيمنا</h2><ul class="check-list"><li><b>الوضوح:</b> سعر متفق عليه قبل التنفيذ.</li><li><b>الالتزام:</b> الموعد جزء من الخدمة لا تفصيل جانبي.</li><li><b>العناية:</b> نتعامل مع حمولتك كأنها حمولتنا.</li></ul>
${site.cr ? `<h2>البيانات النظامية</h2><p>${[site.legalName, `السجل التجاري: ${site.cr}`, site.vat && `الرقم الضريبي: ${site.vat}`].filter(Boolean).map(esc).join('<br>')}</p>` : ''}`)

simplePage('/contact', 'تواصل معنا', `تواصل معنا | ${site.name}`, `تواصل مع وصلها عبر الاتصال ${site.phoneDisplay} أو واتساب لطلب خدمة نقل أو عرض سعر.`, `
<div class="grid g3" style="margin-bottom:24px">
<div class="feature"><div class="ic">${I.call}</div><h3>اتصال</h3><p><a href="${tel}">${phoneHtml()}</a></p></div>
<div class="feature"><div class="ic">${I.wa}</div><h3>واتساب</h3><p><a href="${wa('مرحبًا')}" target="_blank" rel="noopener">ابدأ المحادثة</a></p></div>
<div class="feature"><div class="ic">${I.clock}</div><h3>أوقات العمل</h3><p>${esc(site.hours)}</p></div>
</div>
${site.email ? `<p>البريد الإلكتروني: <a href="mailto:${esc(site.email)}">${esc(site.email)}</a></p>` : ''}
${[site.address.street, site.address.district, site.address.city].filter(Boolean).length ? `<p>العنوان: ${esc([site.address.street, site.address.district, site.address.city].filter(Boolean).join('، '))}</p>` : ''}
<p>لطلب سعر مفصل استخدم <a href="/quote">نموذج طلب عرض السعر</a>.</p>`, 0.5)

simplePage('/privacy', 'سياسة الخصوصية', `سياسة الخصوصية | ${site.name}`, 'سياسة الخصوصية لموقع وصلها: البيانات التي نجمعها وكيف نستخدمها ونحميها.', `
<p class="note">آخر تحديث: ${TODAY}</p>
<p>نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية وفق نظام حماية البيانات الشخصية في المملكة العربية السعودية.</p>
<h2>البيانات التي نجمعها</h2><ul><li><b>بيانات تقدمها أنت:</b> الاسم ورقم الجوال وتفاصيل الحمولة عند تواصلك معنا عبر الاتصال أو واتساب. نموذج طلب السعر في الموقع لا يحفظ أي بيانات، بل ينشئ رسالة واتساب ترسلها أنت.</li><li><b>بيانات تصفح مجمّعة:</b> قد نستخدم أدوات إحصاء لمعرفة عدد الزيارات والصفحات الأكثر زيارة، دون التعرف على هويتك الشخصية.</li></ul>
<h2>كيف نستخدمها</h2><ul><li>للرد على طلبك وتقديم عرض السعر وتنفيذ الخدمة.</li><li>لتحسين الموقع والخدمة.</li></ul>
<h2>مشاركة البيانات</h2><p>لا نبيع بياناتك ولا نشاركها مع أي طرف، إلا بالقدر اللازم لتنفيذ الخدمة أو عند طلب جهة رسمية مختصة.</p>
<h2>حقوقك</h2><p>يحق لك طلب الاطلاع على بياناتك أو تصحيحها أو حذفها بالتواصل معنا على ${phoneHtml()}${site.email ? ` أو ${esc(site.email)}` : ''}.</p>`, 0.2)

simplePage('/terms', 'الشروط والأحكام', `الشروط والأحكام | ${site.name}`, 'الشروط والأحكام العامة لخدمات وصلها للنقل والتأجير.', `
<p class="note">آخر تحديث: ${TODAY}. هذه شروط عامة؛ وتُعتمد التفاصيل المتفق عليها في عرض السعر أو العقد لكل طلب.</p>
<h2>عرض السعر والحجز</h2><ul><li>يُحدد السعر بناءً على المعلومات التي يقدمها العميل (نوع الحمولة، الكمية، المسار، الموعد).</li><li>يُعد الحجز مؤكدًا بعد موافقة الطرفين على السعر والموعد.</li><li>أي تغيير جوهري في الحمولة أو المسار قد يؤدي لتعديل السعر بعد الاتفاق مع العميل.</li></ul>
<h2>مسؤولية العميل</h2><ul><li>تقديم معلومات صحيحة عن نوع الحمولة ومتطلباتها، ومنها درجة الحرارة المطلوبة.</li><li>تجهيز الحمولة في الموعد، وتجهيز البضائع المبردة مسبقًا قبل التحميل.</li><li>عدم تحميل مواد ممنوعة أو خطرة دون إبلاغ مسبق وموافقة.</li></ul>
<h2>الإلغاء</h2><p>يُرجى إبلاغنا بالإلغاء أو تغيير الموعد في أقرب وقت ممكن. وتوضَّح أي رسوم إلغاء في عرض السعر أو العقد.</p>
<h2>المسؤولية</h2><p>نلتزم بنقل الحمولة بعناية وفق المتفق عليه. وتُحدد حدود المسؤولية عن التلف أو التأخير في عرض السعر أو العقد.</p>`, 0.2)

// صفحة 404
page('/404', layout({ path: '/404', title: `الصفحة غير موجودة | ${site.name}`, desc: 'الصفحة غير موجودة.', noindex: true, body: `<section><div class="wrap narrow" style="text-align:center;padding-block:40px"><h1>الصفحة غير موجودة</h1><p>ربما تغيّر الرابط. جرّب إحدى الصفحات التالية:</p><ul class="chips" style="justify-content:center"><li><a href="/">الرئيسية</a></li><li><a href="/services">خدماتنا</a></li><li><a href="/quote">طلب عرض سعر</a></li></ul></div></section>` }), { noindex: true, file: '404.html' })

// ---------- الكتابة ----------
await rm(OUT, { recursive: true, force: true })
for (const p of pages) {
  const f = join(OUT, p.file)
  await mkdir(dirname(f), { recursive: true })
  await writeFile(f, p.html)
}
await cp(join(ROOT, 'src/assets'), join(OUT, 'assets'), { recursive: true })
await cp(join(ROOT, 'src/assets/favicon.ico'), join(OUT, 'favicon.ico'))
await cp(join(ROOT, 'src/assets/apple-touch-icon.png'), join(OUT, 'apple-touch-icon.png'))

// sitemap
const indexable = pages.filter((p) => !p.noindex)
await writeFile(
  join(OUT, 'sitemap.xml'),
  `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${indexable
    .map((p) => `  <url><loc>${abs(p.path === '/' ? '/' : p.path)}</loc><lastmod>${TODAY}</lastmod><priority>${p.priority.toFixed(1)}</priority></url>`)
    .join('\n')}\n</urlset>\n`,
)
await writeFile(join(OUT, 'robots.txt'), `User-agent: *\nAllow: /\n\nSitemap: ${abs('/sitemap.xml')}\n`)
await writeFile(
  join(OUT, 'manifest.webmanifest'),
  JSON.stringify({ name: `${site.name} | ${site.nameEn}`, short_name: site.name, lang: 'ar', dir: 'rtl', start_url: '/', display: 'standalone', background_color: '#0b0d10', theme_color: '#0b0d10', icons: [{ src: '/assets/icon-192.png', sizes: '192x192', type: 'image/png' }, { src: '/assets/icon-512.png', sizes: '512x512', type: 'image/png' }] }, null, 2),
)

// ترويسات الأمان والتخزين المؤقت (Cloudflare Pages / Netlify)
const scriptHashes = [sha256(js), gaJs && sha256(gaJs)].filter(Boolean).join(' ')
const ga = site.ga4 ? ' https://www.googletagmanager.com' : ''
const gaConnect = site.ga4 ? ' https://*.google-analytics.com https://*.analytics.google.com https://www.googletagmanager.com' : ''
const csp = [
  "default-src 'self'",
  `script-src 'self' ${scriptHashes}${ga} https://static.cloudflareinsights.com`,
  "style-src 'self' 'unsafe-inline'",
  `img-src 'self' data:${site.ga4 ? ' https://*.google-analytics.com https://www.googletagmanager.com' : ''}`,
  "font-src 'self'",
  `connect-src 'self' https://cloudflareinsights.com${gaConnect}`,
  "frame-ancestors 'none'",
  "base-uri 'self'",
  "form-action 'self' https://wa.me",
  'upgrade-insecure-requests',
].join('; ')
await writeFile(
  join(OUT, '_headers'),
  `/*
  Content-Security-Policy: ${csp}
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=(), usb=()
  Strict-Transport-Security: max-age=31536000; includeSubDomains

/assets/fonts/*
  Cache-Control: public, max-age=31536000, immutable

/assets/img/*
  Cache-Control: public, max-age=2592000

/assets/*
  Cache-Control: public, max-age=604800
`,
)
// تحويلات دائمة (301) من روابط الموقع القديم
await writeFile(
  join(OUT, '_redirects'),
  `/index.html / 301
/admin / 301
/admin/* / 301
/market/* / 301
/services/ /services 301
`,
)

const total = pages.length
console.log(`✓ تم بناء ${total} صفحة في dist/ (${indexable.length} صفحة في sitemap)`)
