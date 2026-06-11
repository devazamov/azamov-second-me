# AZAMOV Second Me 🚀

> "Kelajakdagi o'zing bilan bugun gaplash."

**AZAMOV Second Me** is an AI-powered self-improvement app where users communicate with their future selves. The AI acts as the user's future version, helping them achieve goals, build habits, and stay motivated.

## 🌟 Features

### Core Features
- **🤖 Future Self AI Chat** — Talk to an AI version of yourself from 5 years in the future
- **🎯 Daily Missions** — Personalized tasks for self-improvement
- **📊 Progress Tracking** — XP, levels, streaks, and achievements
- **💎 Premium System** — Enhanced features for premium subscribers

### Authentication
- ✅ Email & Password registration/login
- ✅ Google Sign-In
- ✅ Password reset via email

### Onboarding
- ✅ Name, age, gender collection
- ✅ Goals, dreams, and interests selection
- ✅ Personalized AI responses based on profile

### Design
- ✅ Apple iOS 27 Liquid Glass design
- ✅ Frosted glass cards with blur effects
- ✅ Smooth animations and transitions
- ✅ White, minimal, premium theme
- ✅ Responsive layout

## 📱 Screenshots

| Splash | Login | Onboarding | Home | Chat | Missions | Progress | Profile |
|--------|-------|------------|------|------|----------|----------|---------|
| 🎨 | 🔐 | 📝 | 🏠 | 💬 | 🎯 | 📊 | 👤 |

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Latest Stable) |
| **State Management** | Riverpod |
| **Navigation** | GoRouter |
| **Backend** | Firebase (Auth, Firestore, Storage, FCM, Analytics, Crashlytics) |
| **AI** | OpenAI API (GPT-4o) |
| **Architecture** | Feature-first Clean Architecture |

## 📁 Project Structure

```
azamov_second_me/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── firebase_options.dart        # Firebase configuration
│   ├── constants/
│   │   └── app_constants.dart       # App-wide constants
│   ├── theme/
│   │   └── app_theme.dart           # Liquid Glass theme
│   ├── models/
│   │   ├── user_model.dart          # User data model
│   │   ├── chat_model.dart          # Chat message & session models
│   │   ├── mission_model.dart       # Mission & completed mission models
│   │   ├── progress_model.dart      # Progress & achievement models
│   │   └── subscription_model.dart  # Premium subscription model
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth service
│   │   ├── firestore_service.dart   # Firestore CRUD operations
│   │   ├── ai_service.dart          # OpenAI API integration
│   │   └── notification_service.dart # FCM notifications
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication state
│   │   ├── user_provider.dart       # User data state
│   │   ├── chat_provider.dart       # AI chat state
│   │   ├── mission_provider.dart    # Missions state
│   │   └── progress_provider.dart   # Progress state
│   ├── screens/
│   │   ├── splash/                  # Animated splash screen
│   │   ├── auth/                    # Login, Register, Forgot Password
│   │   ├── onboarding/              # Multi-step onboarding
│   │   ├── home/                    # Main home dashboard
│   │   ├── chat/                    # Future Self AI chat
│   │   ├── missions/                # Daily missions
│   │   ├── progress/                # XP, charts, achievements
│   │   └── profile/                 # User profile & settings
│   ├── routes/
│   │   └── app_router.dart          # GoRouter configuration
│   ├── widgets/
│   │   ├── main_shell.dart          # Bottom navigation shell
│   │   └── glass_card.dart          # Liquid Glass card widgets
│   └── utils/
│       ├── helpers.dart             # Utility functions
│       └── extensions.dart          # Dart extensions
├── admin/                           # Admin web dashboard
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── assets/
│   ├── images/
│   └── icons/
└── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.2.0)
- Firebase project
- OpenAI API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/azamov-second-me.git
   cd azamov-second-me
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore, Storage, and Cloud Messaging
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Replace the placeholder values in `lib/firebase_options.dart`

4. **Configure OpenAI**
   - Get your API key from [OpenAI](https://platform.openai.com)
   - Replace `YOUR_OPENAI_API_KEY_HERE` in `lib/services/ai_service.dart`

5. **Run the app**
   ```bash
   flutter run
   ```

### Admin Dashboard

1. Open `admin/index.html` in a web browser
2. Update Firebase config in `admin/app.js`
3. Login with your Firebase admin credentials

## 🔥 Firebase Setup

### Required Services
- ✅ Firebase Authentication
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Firebase Cloud Messaging
- ✅ Firebase Analytics
- ✅ Firebase Crashlytics

### Firestore Collections
| Collection | Description |
|-----------|-------------|
| `users` | User profiles and settings |
| `chat_history` | AI chat sessions and messages |
| `missions` | Available missions |
| `completed_missions` | User's completed missions |
| `progress` | Daily progress records |
| `achievements` | User achievements |
| `notifications` | Notification broadcasts |
| `subscriptions` | Premium subscriptions |

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat history
    match /chat_history/{chatId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
    
    // Missions - public read, admin write
    match /missions/{missionId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
    
    // Completed missions - users can create their own
    match /completed_missions/{id} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

## 💰 Premium Pricing

| Plan | Price | Features |
|------|-------|----------|
| **Free** | 0 UZS | 5 AI chats/day, Basic missions |
| **Premium** | 49,000 UZS/month | Unlimited AI chat, Personalized growth plans, Advanced analytics, Exclusive achievements |

## 🌍 Multi-language Support

The app supports 5 languages:
- 🇺🇿 O'zbek (Primary)
- 🇬🇧 English
- 🇷🇺 Русский
- 🇹🇷 Türkçe
- 🇩🇪 Deutsch

## 📊 Level System

| Level | XP Required | Title |
|-------|-------------|-------|
| 1-5 | 100-500 | Yangi boshlovchi |
| 6-10 | 600-1000 | Boshlang'ich |
| 11-20 | 1100-2000 | O'rganuvchi |
| 21-30 | 2100-3000 | Rivojlangan |
| 31-40 | 3100-4000 | Tajribali |
| 41-50 | 4100-5000 | Kasbiy |
| 50+ | 5000+ | Ustoz |

## 🏆 Achievements

| Achievement | Requirement | Rarity |
|------------|-------------|--------|
| 💬 Birinchi suhbat | Complete 1 chat | Common |
| 🔥 Haftalik streak | 7-day streak | Rare |
| 🏆 Oylik streak | 30-day streak | Epic |
| ⭐ Boshlang'ich | Reach level 5 | Common |
| 🌟 Rivojlangan | Reach level 10 | Rare |
| 💎 XP yig'uvchi | Earn 1000 XP | Rare |
| 👑 XP ustasi | Earn 10,000 XP | Legendary |

## 🔧 Development

### Code Style
- Follow Dart/Flutter style guide
- Use feature-first architecture
- Keep files under 300 lines when possible
- Document all public APIs

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Building
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📄 License

Copyright © 2024 AZAMOV. All rights reserved.

## 👨‍💻 Author

**AZAMOV** — Building the future of self-improvement.

---

*"Kelajakdagi o'zing bilan bugun gaplash."* 🚀
