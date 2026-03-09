# 🐙 دليل رفع Aqario على GitHub
## خطوة بخطوة للمبتدئين

---

## الطريقة 1: من المتصفح (الأسهل)

### الخطوة 1: إنشاء حساب GitHub
```
1. روح: https://github.com/signup
2. أدخل:
   - Username: aqario-ma (مثلاً)
   - Email: contact@aqario.ma
   - Password: xxxxxxxxx
3. فعّل الحساب من الإيميل
```

### الخطوة 2: إنشاء Repository
```
1. اضغط "+" في أعلى اليمين
2. اختر "New repository"
3. الإعدادات:
   ┌─────────────────────────────┐
   │ Repository name: aqario     │
   │ Description: منصة عقارات   │
   │ ● Public                    │
   │ ✅ Add a README file        │
   └─────────────────────────────┘
4. اضغط "Create repository"
```

### الخطوة 3: رفع الملفات
```
1. في الـ repo → اضغط "Add file"
2. اختر "Upload files"
3. اسحب وأفلت الملفات:
   ┌─────────────────────────┐
   │ 📄 index.html           │
   │ 📄 privacy.html         │
   │ 📄 manifest.json        │
   │ 📄 sw.js                │
   │ 📄 README.md            │
   │ 📄 .gitignore           │
   │ 📁 assets/ (المجلد كله) │
   │ 📁 pages/  (المجلد كله) │
   │ 📁 docs/   (المجلد كله) │
   └─────────────────────────┘
4. Commit message:
   "🏠 first commit — Aqario v1.0"
5. اضغط "Commit changes"
```

---

## الطريقة 2: GitHub Desktop (أسهل للمجلدات)

```
1. حمّل: https://desktop.github.com
2. Sign in بحساب GitHub
3. File → New repository
   - Name: aqario
   - Local path: مجلد aqario-final
4. اضغط "Publish repository"
```

---

## الخطوة 4: تفعيل GitHub Pages (موقع مجاني)

```
1. في الـ repo → Settings
2. Pages (في القائمة اليسرى)
3. Source: "Deploy from a branch"
4. Branch: main → / (root)
5. Save

✅ موقعك سيكون متاح على:
https://USERNAME.github.io/aqario
```

---

## الخطوة 5: ربط GitHub بـ Hostinger

```
1. Hostinger → إضافة موقع
2. اختر "Node.js تطبيق ويب"
3. اضغط "Connect GitHub"
4. وافق على الصلاحيات
5. اختر الـ repo: aqario
6. Branch: main
7. اضغط "Deploy"

✅ الموقع سيظهر على دومينك تلقائياً
```

---

## ⚠️ ملاحظات مهمة

```
❌ لا ترفع ملفات .env (فيها كلمات سر)
❌ لا ترفع node_modules/ (حجم ضخم)
✅ .gitignore موجود يحمي هاد الملفات تلقائياً
```

---

*Aqario — 🇲🇦 صُنع في المغرب*
