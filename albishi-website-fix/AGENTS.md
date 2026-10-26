# تعليمات وكيل الذكاء الاصطناعي: تركيب النسخة المعدّلة من موقع البيشي

> هذا الملف موجّه لوكيل ذكاء اصطناعي يعمل على السيرفر نفسه، مثل Claude Code أو Cursor أو Codex أو Copilot Agent،
> ويستطيع تشغيل الأوامر وقراءة الملفات وكتابتها.
> المطلوب: نقل الموقع الحالي www.albishi.com.sa إلى النسخة الموجودة في هذا المجلد، بأمان وبأقل تدخل بشري.
> **اكتب تقاريرك للتقني باللغة العربية.**

## المعطيات
- السيرفر الحالي: Windows + XAMPP (Apache 2.4.58, PHP 8.2.12). المسار المعتاد `C:\xampp\htdocs` وقد يختلف.
- الموقع صفحة واحدة ثابتة `index.html`، بلا قاعدة بيانات وبلا PHP.
- هذا المجلد (اسمه "مجلد الحزمة" أدناه) فيه: `index.html` و `assets/site.css` و `.htaccess` و `robots.txt` و `sitemap.xml`
  و `scripts/optimize-media.bat|.sh` و `company-info.md`، والدليل البشري `README.md`.
- رقم واتساب الشركة في الصفحة: `966535667701`.

## قواعد إلزامية
1. **لا تحذف ولا تعدّل أي ملف وسائط أصلي** في `images/` أو `videos/` أو `docs/`. السكربتات تكتب فقط في `images/web/` و `videos/web/`.
2. **خذ نسخة احتياطية قبل أي تعديل** في جذر الموقع (الخطوة 2)، وسجّل مسارها.
3. **لا تخترع بيانات للشركة.** أي رقم أو دولة أو شهادة لا تجدها في `company-info.md` تبقى فارغة، والقسم الفارغ لا يظهر في الموقع.
4. **لا ترفع إلى جذر الموقع:** `scripts/` و `README.md` و `AGENTS.md` و `CLAUDE.md` و `company-info.md` و `PROMPT.txt` و `tailwind.*` وملف zip.
5. **توقّف واطلب موافقة التقني** قبل:
   - تعديل `httpd.conf` أو إعادة تشغيل Apache.
   - تغيير وصول phpMyAdmin.
   - أي خطوة غير مذكورة هنا.
6. **إذا فشل التحقق بعد النشر** (الخطوة 7) نفّذ الاسترجاع (الخطوة 9) فوراً ثم أبلغ التقني.
7. **لا تغيّر بنية `index.html`** إلا في كائن `SITE_CONFIG` (الخطوة 5)، أو إذا طلب التقني تعديلاً صريحاً.
   إذا أضفت كلاسات Tailwind جديدة فأعد بناء CSS (انظر آخر الملف).

## الخطوات

### 1. اكتشاف جذر الموقع
ابحث عن المجلد الذي يحتوي `images\DSC06343.JPG` و `videos\star055.mp4` و `index.html`
(ابدأ من `C:\xampp\htdocs`، ثم اقرأ `DocumentRoot` في `C:\xampp\apache\conf\httpd.conf` وأي VirtualHost في `conf\extra\httpd-vhosts.conf`).
- إن لم تجده بثقة: **اسأل التقني** عن المسار. سمِّه `SITE_ROOT`.
- تحقق أن `SITE_ROOT\index.html` الحالي يحتوي `cdn.tailwindcss.com` و `videos/star055.mp4`. هذا يؤكد أنها النسخة القديمة.

### 2. نسخة احتياطية
انسخ الملفات النصية فقط (الوسائط الأصلية لن تُمس):
```
SITE_ROOT\index.html, SITE_ROOT\.htaccess (إن وجد), SITE_ROOT\robots.txt, SITE_ROOT\sitemap.xml, SITE_ROOT\assets\ (إن وجد)
```
انسخها إلى مجلد خارج جذر الموقع، مثل `C:\albishi-backup\YYYYMMDD-HHMM\`. اكتب المسار في تقريرك.

### 3. تجهيز ffmpeg
- تحقق: `ffmpeg -version`، ويجب أن تظهر في السطر `--enable-libwebp` و `--enable-libx264`.
- إن لم يكن مثبتاً على ويندوز: `winget install --id Gyan.FFmpeg -e`، ثم افتح جلسة طرفية جديدة ليتحدث PATH.
  إن فشل winget فاطلب من التقني تثبيت نسخة "full" من https://www.gyan.dev/ffmpeg/builds/
- اختياري: Ghostscript لضغط الكتالوج PDF (`winget install --id ArtifexSoftware.GhostScript -e`).

### 4. ضغط الصور والفيديوهات
شغّل السكربت **من داخل SITE_ROOT** لأن مساراته نسبية. السكربت نفسه يبقى في مجلد الحزمة:
```
cd /d SITE_ROOT
"<مسار مجلد الحزمة>\scripts\optimize-media.bat"
```
(على Linux: `cd SITE_ROOT && bash <الحزمة>/scripts/optimize-media.sh`)

ضغط فيديو 1.8GB قد يأخذ من 10 إلى 40 دقيقة، فلا تقطعه. بعد الانتهاء تحقق من المخرجات:

| الملف | الشرط |
|---|---|
| `images\web\thumb\DSC*.webp` | ملف لكل صورة `images\DSC*.JPG`، والواحد أقل من 200KB |
| `images\web\large\DSC*.webp` | نفس العدد، والواحد أقل من 800KB |
| `images\web\logo-256.png` و `favicon-32.png` و `apple-touch-icon.png` و `og-cover.jpg` | موجودة |
| `images\web\hero-poster.jpg` و `equipment-poster.jpg` | موجودة |
| `videos\web\hero.mp4` | موجود وأقل من 15MB |
| `videos\web\equipment.mp4` | موجود وأقل من 60MB |

- إذا تجاوز فيديو الحد: أعد ضغطه بنفس أمر السكربت، مع رفع `-crf` بمقدار 3 (28 تصبح 31، و24 تصبح 27).
- إذا ظهر Ghostscript وأنتج `docs\Albishi-Equipment-Booklet.small.pdf`: **لا تستبدل الأصلي**. أبلغ التقني بالحجمين ليقرر.

### 5. تطبيق بيانات الشركة
افتح `company-info.md` في مجلد الحزمة:
- لكل حقل معبّأ، حدّث القيمة المقابلة في كائن `SITE_CONFIG` داخل `index.html` (في مجلد الحزمة، قبل النسخ):
  `social` و `stats` و `origins` و `certifications` و `seasons` و `whatsapp`. الصيغة موضحة في التعليقات فوق كل حقل.
- الحقول الفارغة تبقى كما هي.
- لكل عنصر في `stats` و `origins` و `certifications` و `seasons` اكتب `ar` و `en` على الأقل.
  اللغات الأخرى تستخدم الإنجليزية تلقائياً.
- إن وُجدت صورة واجهة حقيقية (انظر `company-info.md`) فحوّلها إلى `SITE_ROOT\images\web\hero-produce.webp`:
  ```
  ffmpeg -i "<الصورة>" -vf "scale=1920:-2" -c:v libwebp -quality 78 "SITE_ROOT\images\web\hero-produce.webp"
  ```
- تحقق أن JavaScript في الصفحة ما زال صالحاً: الأقواس والفواصل وعلامات الاقتباس سليمة داخل `SITE_CONFIG`.

### 6. النشر
انسخ من مجلد الحزمة إلى SITE_ROOT (استبدال):
```
index.html  ->  SITE_ROOT\index.html
assets\site.css  ->  SITE_ROOT\assets\site.css
robots.txt, sitemap.xml  ->  SITE_ROOT\
```
**`.htaccess` يُنسخ على حدة وبحذر:**
1. تحقق من الوحدات: `C:\xampp\apache\bin\httpd.exe -M`، ويلزم `rewrite_module` و `headers_module` و `deflate_module` و `expires_module`.
2. تحقق أن `AllowOverride` للمجلد ليست `None` في httpd.conf.
   - إن كانت `None` أو كانت وحدة ناقصة: **لا تعدّل httpd.conf بنفسك**. أبلغ التقني بالتعديل المطلوب بالضبط، وانسخ .htaccess بعد موافقته.
3. إن وُجد `.htaccess` قديم: ادمج القواعد القديمة غير المتعارضة بدل الاستبدال الأعمى، واذكر ذلك في التقرير.
4. بعد النسخ نفّذ فوراً: `curl -sI https://www.albishi.com.sa/`
   - إن رجع **500**: احذف `.htaccess` الجديد وأعد القديم وأبلغ.
   - إن ظهر **تحويل متكرر** (redirect loop)، وهذا يحدث إذا كان TLS يُنهى قبل Apache، مثل Cloudflare أو موازن أحمال:
     احذف كتلة "تحويل http إلى https" من .htaccess وأبلغ التقني.

### 7. التحقق بعد النشر (كلها يجب أن تنجح)
```
curl -s -o NUL -w "%{http_code}" https://www.albishi.com.sa/                         -> 200
curl -sI https://www.albishi.com.sa/assets/site.css                                    -> 200 و text/css
curl -sI https://www.albishi.com.sa/images/web/thumb/DSC06343.webp                     -> 200 و image/webp
curl -sI https://www.albishi.com.sa/videos/web/hero.mp4                                -> 200
curl -sI https://www.albishi.com.sa/videos/web/equipment.mp4                           -> 200
curl -s  https://www.albishi.com.sa/robots.txt                                         -> يحتوي Sitemap
curl -sI http://www.albishi.com.sa/                                                    -> 301 إلى https (إن طُبّقت .htaccess)
curl -s  https://www.albishi.com.sa/ | findstr "cdn.tailwindcss.com"                   -> لا نتيجة
curl -s  https://www.albishi.com.sa/ | findstr "assets/site.css"                       -> نتيجة واحدة
```
(على Linux: `/dev/null` بدل `NUL` و `grep` بدل `findstr`.)

إن توفر متصفح آلي (Playwright أو Puppeteer)، افتح الصفحة بعرض 390 و1366 وتحقق من:
- لا أخطاء JavaScript في الـ console.
- `document.documentElement.scrollWidth <= innerWidth` (لا تمرير أفقي).
- زر `#mobileMenuBtn` يفتح `#mobileMenu` على عرض 390.
- `switchLanguage('en')` يجعل `document.dir === 'ltr'`.

### 8. تقوية السيرفر (بعد موافقة التقني فقط)
اعرض هذه التعديلات على التقني ونفّذها بعد موافقته، ثم `httpd -t` ثم إعادة تشغيل Apache:
- في `httpd.conf`: `ServerTokens Prod` و `ServerSignature Off`.
- phpMyAdmin (`conf\extra\httpd-xampp.conf`): قصره على الجهاز المحلي (`Require local`)، **لا تحذفه**.
- `expose_php = Off` في `php.ini`.

### 9. الاسترجاع (عند أي فشل)
انسخ ملفات النسخة الاحتياطية من الخطوة 2 إلى SITE_ROOT، واحذف `.htaccess` الجديد إن لم يكن هناك قديم،
ثم تحقق أن الصفحة ترجع 200. مجلدات `images\web` و `videos\web` لا تضر ويمكن تركها.

### 10. التقرير النهائي للتقني (بالعربية)
- مسار SITE_ROOT ومسار النسخة الاحتياطية.
- جدول أحجام الملفات قبل وبعد (صور المعرض، الفيديوهان، الشعار).
- نتيجة كل فحص في الخطوة 7.
- ما طُبّق من `company-info.md`، وما بقي فارغاً.
- ما ينتظر قراراً بشرياً: تعديلات httpd.conf، phpMyAdmin، استبدال الكتالوج PDF، الصورة الحقيقية للواجهة، تسجيل Google Search Console.

## إعادة بناء CSS (فقط إذا أضيفت كلاسات Tailwind جديدة)
```
npx tailwindcss@3.4.17 -c tailwind.config.js -i tailwind.input.css -o assets/site.css --minify
```
