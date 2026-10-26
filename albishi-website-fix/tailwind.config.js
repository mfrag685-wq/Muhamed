// لإعادة بناء assets/site.css بعد أي تعديل على الكلاسات في index.html:
//   npx tailwindcss@3.4.17 -i tailwind.input.css -o assets/site.css --minify
module.exports = {
  content: ['./index.html'],
  theme: { extend: {} },
  plugins: []
};
