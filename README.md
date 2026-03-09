# 🏠 Aqario — منصة العقارات المغربية

> منصة عقارية موثوقة للمغرب — بيع، كراء، وكالات معتمدة، خريطة تفاعلية

[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![PWA Ready](https://img.shields.io/badge/PWA-Ready-green.svg)](manifest.json)
[![Arabic RTL](https://img.shields.io/badge/Arabic-RTL-blue.svg)]()

---

## 📸 الصفحات

| الصفحة | الملف | الوصف |
|--------|-------|-------|
| 🏠 الرئيسية (عربي) | `pages/homepage-ar.html` | الصفحة الرئيسية بالعربية |
| 🇫🇷 الرئيسية (فرنسي) | `pages/homepage-fr.html` | الصفحة الرئيسية بالفرنسية |
| 🏡 تفاصيل العقار | `pages/property-detail.html` | صفحة عقار كاملة |
| 📝 نشر إعلان | `pages/publish.html` | نشر في 60 ثانية |
| 👤 لوحة التحكم | `pages/dashboard.html` | داشبورد المستخدم |
| 🏢 الوكالات | `pages/agencies.html` | دليل الوكالات |
| ⚖️ المقارنة | `pages/vs-competition.html` | Aqario vs Mubawab/Avito |
| 📱 تصميم موبايل | `pages/mobile-design.html` | موكاب الموبايل |
| 🔐 الخصوصية | `privacy.html` | سياسة الخصوصية |

---

## 🚀 المميزات

- ✅ **توثيق 3 مراحل** — هاتف + هوية + وثيقة الملكية
- 🤖 **AI لمنع التكرار** — خوارزمية pHash + NLP + PostGIS
- 🗺 **خريطة تفاعلية أولاً** — Map-First experience
- ⚡ **نشر في 60 ثانية** — 3 خطوات فقط
- 💡 **السعر العادل مجاناً** — تقدير AI لكل عقار
- 📱 **PWA جاهز** — يعمل كتطبيق على الموبايل
- 🌍 **عربية RTL كاملة** + دعم الفرنسية
- 🇲🇦 **47 مدينة مغربية** + MAD درهم

---

## 🗂 هيكل المشروع

```
aqario/
├── index.html              ← الصفحة الرئيسية (landing)
├── privacy.html            ← سياسة الخصوصية
├── manifest.json           ← PWA manifest
├── sw.js                   ← Service Worker (offline)
│
├── assets/
│   ├── css/style.css       ← كل الستايل
│   ├── js/script.js        ← JavaScript + animations
│   └── images/             ← الصور والأيقونات
│       ├── icon-192.png    ← PWA icon (أضفها)
│       ├── icon-512.png    ← PWA icon كبير (أضفها)
│       └── favicon.png     ← favicon (أضفها)
│
├── pages/                  ← كل صفحات التطبيق
│   ├── homepage-ar.html
│   ├── homepage-fr.html
│   ├── property-detail.html
│   ├── publish.html
│   ├── dashboard.html
│   ├── agencies.html
│   ├── vs-competition.html
│   └── mobile-design.html
│
└── docs/                   ← التوثيق التقني
    ├── database-schema.sql     ← قاعدة البيانات (15 جدول)
    ├── duplicate-detection.ts  ← خوارزمية منع التكرار
    └── duplicate-functions.sql ← PostgreSQL functions
```

---

## 🛠 التثبيت والتشغيل

### تشغيل محلي

```bash
# لا يحتاج تثبيت — افتح مباشرة
open index.html
# أو استخدم Live Server في VS Code
```

### رفع على Hostinger

1. ارفع كل الملفات عبر File Manager
2. أو اربط GitHub repo مباشرة من لوحة Hostinger

### النشر على GitHub Pages (مجاني)

```
Settings → Pages → Source: main branch → / (root)
الموقع سيكون: https://username.github.io/aqario
```

---

## 📱 تحويل لتطبيق Android

### الطريقة السريعة — PWABuilder

```
1. روح: pwabuilder.com
2. أدخل رابط موقعك
3. اختر Android
4. حمّل الـ APK/AAB
5. ارفع على Google Play Console
```

### المتطلبات للـ Play Store

- [ ] Google Play Developer Account ($25)
- [ ] Icon 512×512px في assets/images/icon-512.png
- [ ] 4+ screenshots من الموبايل
- [ ] Privacy Policy URL (privacy.html)
- [ ] Feature Graphic 1024×500px

---

## 🗄 قاعدة البيانات (Supabase)

```bash
psql -h db.supabase.co -U postgres -d postgres < docs/database-schema.sql
```

**الجداول الرئيسية:** users, properties, agencies, images, messages, favorites, duplicate_reports

---

## 📊 الإحصائيات

- **8 صفحات** كاملة التصميم
- **25 معيار** مقارنة مع المنافسين
- **15 جدول** في قاعدة البيانات
- **4 طبقات** في خوارزمية منع التكرار

---

## 📄 الترخيص

MIT License

## 📞 التواصل

- 📧 contact@aqario.ma
- 🌐 aqario.ma
- 🇲🇦 صُنع في المغرب بـ ❤️
