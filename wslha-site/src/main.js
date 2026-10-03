(function () {
  var d = document
  // قائمة الجوال
  var btn = d.querySelector('.menu-btn'), menu = d.getElementById('menu')
  if (btn && menu) btn.addEventListener('click', function () {
    var open = menu.classList.toggle('open')
    btn.setAttribute('aria-expanded', open ? 'true' : 'false')
  })

  // تتبّع ضغطات الاتصال وواتساب كتحويلات (يعمل تلقائيًا إذا فُعّل GA4)
  function track(name, params) {
    if (typeof window.gtag === 'function') window.gtag('event', name, params || {})
  }
  d.addEventListener('click', function (e) {
    var a = e.target.closest && e.target.closest('a[href]')
    if (!a) return
    var h = a.getAttribute('href')
    if (h.indexOf('tel:') === 0) track('click_call', { link_url: h, page_path: location.pathname })
    else if (h.indexOf('wa.me') > -1) track('click_whatsapp', { page_path: location.pathname })
  })

  // نموذج طلب عرض السعر → رسالة واتساب جاهزة
  var form = d.getElementById('quote-form')
  if (!form) return
  var svc = form.elements.service, tempField = d.getElementById('temp-field')
  function syncTemp() {
    var opt = svc.options[svc.selectedIndex], t = opt && opt.getAttribute('data-temp')
    tempField.hidden = t === null
    // اختيار درجة الحرارة الافتراضية المناسبة للخدمة (مثل 2–8 للأدوية)
    if (t !== null) form.elements.temp.selectedIndex = +t || 0
  }
  try {
    var q = new URLSearchParams(location.search).get('service')
    if (q) for (var i = 0; i < svc.options.length; i++) if (svc.options[i].value === q) svc.selectedIndex = i
  } catch (_) {}
  svc.addEventListener('change', syncTemp)
  syncTemp()

  form.addEventListener('submit', function (e) {
    e.preventDefault()
    if (!form.reportValidity()) return
    var f = form.elements, lines = ['مرحبًا، أرغب في عرض سعر:']
    function add(label, el) {
      var v = el && (el.tagName === 'SELECT' ? el.options[el.selectedIndex].text : el.value.trim())
      if (v) lines.push('• ' + label + ': ' + v)
    }
    add('الخدمة', f.service)
    add('من', f.from)
    add('إلى', f.to)
    add('الموعد', f.date)
    add('نوع الحمولة', f.cargo)
    add('الكمية / الوزن', f.size)
    if (!tempField.hidden) add('درجة الحرارة', f.temp)
    add('الاسم', f.name)
    add('الجوال', f.phone)
    add('ملاحظات', f.notes)
    track('generate_lead', { service: f.service.value })
    var url = 'https://wa.me/' + form.getAttribute('data-wa') + '?text=' + encodeURIComponent(lines.join('\n'))
    // ملاحظة: window.open مع 'noopener' يُرجع null دائمًا، لذا نفصل opener يدويًا
    var w = window.open(url, '_blank')
    if (w) w.opener = null
    else location.href = url
  })
})()
