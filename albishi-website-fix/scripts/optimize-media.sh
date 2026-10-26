#!/usr/bin/env bash
# ضغط صور وفيديوهات موقع البيشي.
# يُشغَّل من مجلد الموقع (الذي فيه images/ و videos/):
#     bash scripts/optimize-media.sh
# المتطلبات: ffmpeg (مع libwebp و libx264). اختياري: ghostscript (gs) لضغط الكتالوج PDF.
# لا يحذف ولا يعدّل أي ملف أصلي، يكتب فقط في images/web و videos/web و docs/.
set -euo pipefail

command -v ffmpeg >/dev/null || { echo "ffmpeg غير مثبت"; exit 1; }
FF="ffmpeg -hide_banner -loglevel error -y"

mkdir -p images/web/thumb images/web/large videos/web

echo "== صور المعرض =="
shopt -s nullglob nocaseglob
for f in images/DSC*.jpg; do
  name=$(basename "${f%.*}")
  # مصغرة لشبكة المعرض (حوالي 60KB)
  $FF -i "$f" -vf "scale=800:-2" -c:v libwebp -quality 72 "images/web/thumb/$name.webp"
  # نسخة العرض المكبّر (حوالي 300KB)
  $FF -i "$f" -vf "scale='min(1920,iw)':-2" -c:v libwebp -quality 78 "images/web/large/$name.webp"
  echo "  $name"
done
shopt -u nocaseglob

echo "== الشعار والأيقونات =="
LOGO=images/BSHLOGO.png
[ -f "$LOGO" ] || LOGO=images/BSHLOGO.PNG
$FF -i "$LOGO" -vf "scale=256:256:force_original_aspect_ratio=decrease" "images/web/logo-256.png"
$FF -i "$LOGO" -vf "scale=32:32:force_original_aspect_ratio=decrease" "images/web/favicon-32.png"
$FF -i "$LOGO" -vf "scale=180:180:force_original_aspect_ratio=decrease,pad=180:180:(ow-iw)/2:(oh-ih)/2:color=white" "images/web/apple-touch-icon.png"

echo "== صورة المشاركة (Open Graph) =="
COVER=$(ls images/DSC06343.* 2>/dev/null | head -1 || true)
if [ -n "$COVER" ]; then
  $FF -i "$COVER" -vf "scale=1200:630:force_original_aspect_ratio=increase,crop=1200:630" -q:v 4 "images/web/og-cover.jpg"
fi

echo "== فيديو الواجهة (463MB إلى حوالي 5MB) =="
if [ -f videos/star055.mp4 ]; then
  $FF -ss 2 -i videos/star055.mp4 -frames:v 1 -vf "scale=1600:-2" -q:v 4 "images/web/hero-poster.jpg"
  # أول 20 ثانية، 1280px، مع صوت خفيف لأن في الصفحة زر تشغيل الصوت
  $FF -i videos/star055.mp4 -t 20 -vf "scale=1280:-2,fps=25" -c:v libx264 -preset slow -crf 28 \
      -profile:v high -pix_fmt yuv420p -c:a aac -b:a 96k -movflags +faststart "videos/web/hero.mp4"
fi

echo "== فيديو المعدات (1.8GB إلى حوالي 20MB) =="
if [ -f videos/equipment_video.mp4 ]; then
  $FF -ss 5 -i videos/equipment_video.mp4 -frames:v 1 -vf "scale=1280:-2" -q:v 4 "images/web/equipment-poster.jpg"
  $FF -i videos/equipment_video.mp4 -vf "scale='min(1920,iw)':-2,fps=30" -c:v libx264 -preset slow -crf 24 \
      -profile:v high -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart "videos/web/equipment.mp4"
fi

echo "== الكتالوج PDF (48MB) =="
PDF=docs/Albishi-Equipment-Booklet.pdf
if [ -f "$PDF" ] && command -v gs >/dev/null; then
  gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dCompatibilityLevel=1.5 \
     -sOutputFile="docs/Albishi-Equipment-Booklet.small.pdf" "$PDF"
  echo "  تم: docs/Albishi-Equipment-Booklet.small.pdf (راجعه ثم استبدل به الأصلي)"
else
  echo "  تخطّي: ghostscript غير مثبت أو الملف غير موجود"
fi

echo
echo "الأحجام الناتجة:"
du -sh images/web videos/web 2>/dev/null || true
