# Elkhalfy - تطبيق IPTV متكامل

![Elkhalfy Logo](assets/images/logo.png)

## نظرة عامة

تطبيق **Elkhalfy** هو تطبيق IPTV متكامل مبني بتقنية Flutter يعمل على:
- ✅ Android (APK)
- ✅ iOS (iPhone & iPad)
- ✅ Windows / Mac / Linux
- ✅ Android TV / Smart TV

---

## متطلبات التشغيل

- Flutter SDK 3.19.0 أو أحدث
- Dart SDK 3.0.0 أو أحدث
- Android Studio / VS Code
- Xcode 15+ (لـ iOS)
- حساب Firebase

---

## تثبيت وتشغيل المشروع

### 1. تثبيت الحزم

```bash
flutter pub get
```

### 2. إعداد Firebase

**للأندرويد:**
- ضع ملف `google-services.json` في المجلد `android/app/`
- الملف موجود مسبقاً بإعدادات Firebase الخاصة بك

**لـ iOS:**
- ضع ملف `GoogleService-Info.plist` في المجلد `ios/Runner/`
- حمّله من Firebase Console

### 3. إنشاء أيقونة التطبيق

```bash
flutter pub run flutter_launcher_icons
```

### 4. تشغيل التطبيق

```bash
flutter run
```

### 5. بناء APK للأندرويد

```bash
flutter build apk --release
```

الملف سيكون في: `build/app/outputs/flutter-apk/app-release.apk`

### 6. بناء لـ iOS

```bash
flutter build ios --release
```

---

## هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية
├── app/
│   ├── app.dart                 # الـ App Widget والثيم
│   └── routes.dart              # التنقل بين الشاشات
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # الألوان
│   │   └── app_strings.dart     # النصوص العربية
│   └── services/
│       ├── firebase_service.dart  # Firebase وإعدادات التطبيق
│       ├── iptv_service.dart      # Xtream / M3U8 / MAC
│       ├── storage_service.dart   # التخزين المحلي
│       └── notification_service.dart  # الإشعارات
├── data/models/                 # نماذج البيانات
├── presentation/                # الشاشات
│   ├── splash/                  # شاشة البداية
│   ├── activation/              # كود التفعيل
│   ├── home/                    # الصفحة الرئيسية
│   ├── live_tv/                 # القنوات المباشرة
│   ├── movies/                  # الأفلام
│   ├── series/                  # المسلسلات
│   ├── news/                    # الأخبار
│   ├── matches/                 # المباريات
│   ├── player/                  # مشغل الفيديو
│   ├── downloads/               # التنزيلات
│   ├── settings/                # الإعدادات
│   └── maintenance/             # وضع الصيانة
└── widgets/                     # عناصر مشتركة
```

---

## إعداد Firebase Realtime Database

### هيكل قاعدة البيانات

```json
{
  "app_config": {
    "maintenance_mode": false,
    "maintenance_message": "التطبيق تحت الصيانة",
    "activation_enabled": false,
    "required_version": "1.0.0",
    "update_url": "",
    "telegram_link": "",
    "telegram_banner_visible": false,
    "privacy_policy": "",
    "support_config": {
      "whatsapp": "+966XXXXXXXXX",
      "telegram": "https://t.me/elkhalfy",
      "email": "support@elkhalfy.com"
    }
  },
  "iptv_sources": {
    "source1": {
      "id": "source1",
      "name": "مصدر 1",
      "type": "xtream",
      "server_url": "http://your-server.com",
      "username": "user",
      "password": "pass",
      "show_channels": true,
      "show_movies": true,
      "show_series": true,
      "visible": true,
      "order": 0
    }
  },
  "activation_codes": {
    "CODE123": {
      "device_limit": 1,
      "expiry": null,
      "devices": []
    }
  },
  "banners": {
    "banner1": {
      "image": "https://example.com/banner.jpg",
      "title": "عنوان البانر",
      "link": "",
      "active": true
    }
  },
  "news_providers": {
    "provider1": {
      "name": "أخبار اليوم",
      "api_url": "https://newsapi.org/v2/top-headlines?country=sa",
      "api_key": "YOUR_API_KEY",
      "data_path": "articles",
      "field_mapping": {
        "title": "title",
        "description": "description",
        "image": "urlToImage",
        "url": "url",
        "date": "publishedAt"
      },
      "active": true
    }
  },
  "matches_providers": {
    "provider1": {
      "name": "API Football",
      "api_url": "https://v3.football.api-sports.io/fixtures?date={date}",
      "api_key": "YOUR_API_KEY",
      "data_path": "response",
      "field_mapping": {
        "home_team": "teams.home.name",
        "away_team": "teams.away.name",
        "home_logo": "teams.home.logo",
        "away_logo": "teams.away.logo",
        "home_score": "goals.home",
        "away_score": "goals.away",
        "time": "fixture.date",
        "league_name": "league.name",
        "league_logo": "league.logo",
        "status": "fixture.status.short"
      },
      "active": true
    }
  },
  "devices": {}
}
```

---

## الميزات الرئيسية

| الميزة | الوصف |
|--------|-------|
| 📺 IPTV | دعم Xtream Codes، M3U8، MAC Address |
| 🎬 أفلام ومسلسلات | تصفح وتشغيل وتحميل |
| ⚽ مباريات | جدول المباريات والنتائج المباشرة |
| 📰 أخبار | من API قابل للتخصيص |
| 🔐 تفعيل | نظام كود تفعيل عبر Firebase |
| 🔔 إشعارات | Firebase Cloud Messaging |
| 🌙 وضع صيانة | من لوحة التحكم Firebase |
| 🌍 تعدد اللغات | عربي وقابل للتوسع |
| 📱 متعدد المنصات | Android, iOS, Desktop, TV |

---

## لوحة التحكم (Firebase Console)

يمكنك إدارة كل شيء من Firebase Realtime Database:
- تفعيل/تعطيل وضع الصيانة
- إدارة أكواد التفعيل
- إضافة مصادر IPTV
- إرسال إشعارات
- إدارة البانرات
- إعداد APIs الأخبار والمباريات

---

## الدعم الفني

للدعم والمساعدة: راجع إعدادات التطبيق أو تواصل عبر البيانات المدخلة في Firebase.

---

**Elkhalfy** © 2024 - جميع الحقوق محفوظة
