# 📱 دليل إطلاق Aqario على Android
## من الكود إلى Google Play Store

---

## الخطوة 1: تأكد من جاهزية الموقع

قبل أي شي، الموقع لازم يكون منشور على نطاق حقيقي:

```
✅ https://aqario.ma  ← يشتغل
✅ HTTPS (SSL) مفعّل  ← ضروري للـ PWA
✅ manifest.json موجود
✅ sw.js (Service Worker) موجود
✅ icon-512.png موجود في assets/images/
```

---

## الخطوة 2: أضف الأيقونات (مطلوبة)

اصنع هاد الأيقونات وحطها في مجلد `assets/images/`:

| الملف | الحجم | الاستخدام |
|-------|-------|-----------|
| favicon.png | 32×32 | تاب المتصفح |
| icon-192.png | 192×192 | PWA صغير |
| icon-512.png | 512×512 | Play Store + PWA كبير |
| feature-graphic.png | 1024×500 | صفحة Play Store |
| screenshot-1.png | 390×844 | سكرين شوت موبايل |
| screenshot-2.png | 390×844 | سكرين شوت ثاني |

### أداة مجانية لصنع الأيقونات:
- https://realfavicongenerator.net
- https://www.canva.com (ارسم icon بسيط بألوان Aqario)

**ألوان Aqario:**
- Primary: #7C3AED (بنفسجي)
- Accent: #06B6D4 (تيل)
- Background: #07050F (أسود)

---

## الخطوة 3: تحويل الموقع لـ APK — PWABuilder

### 3.1 روح للموقع
```
https://pwabuilder.com
```

### 3.2 أدخل رابط موقعك
```
https://aqario.ma
```
اضغط **Start**

### 3.3 تحقق من النتيجة
- PWABuilder سيعطيك Score (لازم > 70)
- إذا Score منخفض: تحقق من manifest.json و sw.js

### 3.4 اختر Android
- اضغط **Package for stores**
- اختر **Android**
- اختر **Google Play** (مش Samsung)

### 3.5 الإعدادات
```
App name:         Aqario عقارات المغرب
Package name:     ma.aqario.app
App version:      1.0.0
Version code:     1
Host:             https://aqario.ma
Start URL:        /
Signing key:      Generate new (حفظ الملف مهم!)
```

### 3.6 Build & Download
- اضغط **Generate**
- حمّل الـ ZIP
- داخله: `app-release.aab` ← هاد الملف اللي ترفعه

---

## الخطوة 4: Google Play Console

### 4.1 إنشاء حساب Developer
```
1. روح: https://play.google.com/console
2. Sign in بـ Google Account
3. ادفع $25 (مرة واحدة فقط)
4. أكمل معلومات الحساب:
   - الاسم الكامل
   - العنوان (المغرب)
   - رقم الهاتف
```

### 4.2 إنشاء التطبيق
```
Dashboard → Create app
├── App name:     Aqario - عقارات المغرب
├── Language:     Arabic
├── App or game:  App
├── Free / Paid:  Free
└── Accept policies → Create app
```

### 4.3 إعداد الـ Store Listing

**Main store listing:**
```
App name:
  Aqario - عقارات المغرب

Short description (80 حرف):
  ابحث عن شقة، فيلا أو أرض في المغرب — إعلانات موثقة وخريطة تفاعلية

Full description (4000 حرف):
---
🏠 Aqario — منصة العقارات الأولى في المغرب

ابحث بسهولة عن عقارك المثالي في أكثر من 47 مدينة مغربية.

✅ إعلانات موثقة فقط
كل إعلان يمر بـ 3 مراحل توثيق: هاتف، هوية، ووثيقة الملكية.

🗺 خريطة تفاعلية
ابحث بالموقع الجغرافي الدقيق وشوف العقارات على الخريطة.

⚡ نشر في 60 ثانية
انشر إعلانك في 3 خطوات بسيطة وظهر فوراً على الخريطة.

💡 السعر العادل مجاناً
خوارزمية AI تقدر لك السعر العادل لأي عقار.

🤖 لا مزيد من التكرار
نظام ذكي يمنع تكرار الإعلانات تلقائياً.

🏢 340+ وكالة معتمدة
دليل شامل للوكالات العقارية الموثقة في المغرب.

سواء كنت تبحث للشراء أو الكراء، أو تريد نشر إعلانك — Aqario هو الحل الأمثل.
---
```

**Contact details:**
```
Email:    contact@aqario.ma
Website:  https://aqario.ma
Phone:    +212XXXXXXXXX
```

**Privacy Policy URL:**
```
https://aqario.ma/privacy.html
```

### 4.4 رفع الصور

```
App icon:        assets/images/icon-512.png (512×512)
Feature graphic: assets/images/feature-graphic.png (1024×500)
Screenshots:     أضف 4 screenshots على الأقل
```

**كيف تصور screenshots:**
1. افتح الموقع من Chrome على الموبايل
2. اضغط F12 → Toggle device (حجم iPhone 12 أو Pixel 5)
3. صور 4 صفحات مختلفة

### 4.5 Content Rating
```
App content → Content rating
→ Start questionnaire
→ Category: Reference, news and weather
→ أجب بـ "No" على كل شي
→ Submit
```

### 4.6 Target Audience
```
Target audience → Age group: 18+
App for children: No
```

### 4.7 رفع الـ APK/AAB
```
Production → Releases → Create new release
→ Upload: app-release.aab
→ Release name: 1.0.0
→ Release notes (Arabic):
   "الإصدار الأول من Aqario — منصة العقارات المغربية"
→ Save → Review release → Start rollout
```

---

## الخطوة 5: المراجعة والنشر

```
⏳ وقت المراجعة: 2–7 أيام
📧 ستتلقى email عند القبول أو الرفض
```

### أسباب الرفض الشائعة وحلولها:

| السبب | الحل |
|-------|------|
| Privacy Policy ناقصة | تأكد من رابط privacy.html يشتغل |
| Icon جودة منخفضة | استعمل PNG 512×512 واضح |
| Screenshots غير كافية | أضف 4+ screenshots |
| Crash عند الفتح | اختبر الـ APK قبل الرفع |
| محتوى placeholder | احذف أي بيانات "lorem ipsum" |

---

## الخطوة 6: بعد النشر ✅

### شارك الرابط:
```
https://play.google.com/store/apps/details?id=ma.aqario.app
```

### راقب الإحصائيات:
- Google Play Console → Statistics
- عدد التنزيلات، التقييمات، Crashes

### تحديثات مستقبلية:
```
1. غيّر version code في PWABuilder (2، 3، ...)
2. أعد توليد الـ AAB
3. ارفع release جديد في Play Console
```

---

## ⚡ ملخص سريع

```
اليوم 1:
  ✅ ارفع الموقع على Hostinger
  ✅ أضف الأيقونات

اليوم 2:
  ✅ pwabuilder.com → توليد APK
  ✅ ادفع $25 لـ Google Play

اليوم 3:
  ✅ أكمل Store Listing
  ✅ ارفع AAB → Submit للمراجعة

اليوم 4–10:
  ⏳ انتظر الموافقة

بعدها:
  🎉 تطبيقك في Play Store!
```

---

*صُنع بـ ❤️ للسوق المغربي — Aqario 2026*
