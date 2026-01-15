# QuoteVault 📖

> A beautiful, offline-first Flutter app for discovering, collecting, and sharing inspiring quotes.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## ✨ Features

### Core Features
- 📚 **Browse Quotes** - Discover quotes by category, author, or search
- ☀️ **Daily Quote** - Fresh inspiration every day with local notifications
- 💖 **Favorites & Likes** - Save and appreciate quotes
- 📂 **Collections** - Organize quotes into custom collections
- 🎨 **Share Beautiful Cards** - Generate styled quote images (3 templates)
- 🌙 **Full Personalization** - 6 colors, 3 themes, adjustable typography

### Advanced Features
- 🔌 **Offline-First** - Works perfectly without internet (cached quotes)
- ⚡ **Instant Sync** - Background sync when online
- 🔔 **Smart Notifications** - Configurable daily quote reminders
- 🎭 **Accessibility** - Text scaling, high contrast, screen reader support
- 📱 **Native Feel** - Material 3 design with smooth animations

---

## 🏗️ Architecture

### Clean Architecture (Feature-First)
```
lib/
├── core/                    # Shared utilities
│   ├── constants/          # App-wide constants
│   ├── errors/             # Error handling
│   ├── router/             # Navigation (GoRouter)
│   ├── services/           # Core services (Supabase, Connectivity)
│   ├── theme/              # Theming system
│   └── widgets/            # Reusable widgets
│
├── auth/                    # Authentication
│   ├── data/               # Auth API calls
│   ├── domain/             # User models
│   └── presentation/       # Login/Signup screens
│
├── quotes/                  # Quote browsing
│   ├── data/               # Quote repository
│   ├── domain/             # Quote entity
│   └── presentation/       # Feed, search, category screens
│
├── favorites/               # Favorites & Likes
│   ├── data/               # Favorites/likes repositories
│   ├── domain/             # Favorite/Like models
│   └── presentation/       # Favorites screen
│
├── collections/             # Collections management
│   ├── data/               # Collections repository
│   ├── domain/             # Collection entity
│   └── presentation/       # Collections screens
│
├── daily_quote/             # Quote of the Day
│   ├── data/               # Daily quote repository
│   ├── domain/             # Daily quote model
│   ├── services/           # Notification service
│   └── presentation/       # Daily quote widget
│
├── sharing/                 # Quote sharing
│   ├── domain/             # Card style models
│   ├── services/           # Share & export services
│   └── presentation/       # Share bottom sheet, preview
│
└── settings/                # User preferences
    ├── data/               # Settings persistence
    ├── domain/             # Settings model
    └── presentation/       # Settings screen
```

### State Management
- **Riverpod** - Type-safe, testable state management
- **Providers** - For dependency injection
- **StateNotifier** - For complex state logic
- **FutureProvider** - For async data loading

### Backend
- **Supabase** - Backend-as-a-Service
  - PostgreSQL database
  - Row Level Security
  - Real-time subscriptions (future)
  - Storage for avatars

---

## 🔌 Offline-First Strategy

### Philosophy
**"Read from cache, sync in background"**

### How It Works
1. **Initial Load**: Data fetched from Supabase
2. **Caching**: Quotes, favorites, collections cached locally (Hive/SharedPreferences)
3. **Offline Mode**: App works fully from cache
4. **Background Sync**: When online, data syncs silently
5. **Conflict Resolution**: Last-write-wins for favorites, merge for collections

### What Works Offline
✅ Browse cached quotes  
✅ View favorites  
✅ View collections  
✅ View daily quote  
✅ Adjust settings  
✅ Generate quote cards  

### What Requires Internet
❌ Load new quotes  
❌ Like/favorite sync (queued)  
❌ Create collections (queued)  
❌ Upload avatar  
❌ Auth operations  

### Connectivity Detection
- **Live Status**: Orange banner shows when offline
- **Auto-Retry**: Failed operations retry when online
- **Smart Queueing**: Write operations queued for sync

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x or higher
- Dart 3.x or higher
- Supabase account (for backend)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/quotevault.git
cd quotevault
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Set up environment variables**
Create `.env` file in project root:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. **Run database setup**
Execute SQL scripts in `supabase/` folder in your Supabase SQL editor:
- `setup.sql` - Initial schema
- `favorites_likes_collections_setup.sql` - Favorites & collections

5. **Run the app**
```bash
flutter run
```

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ | API 21+ (Android 5.0+) |
| iOS | ✅ | iOS 12+ |
| Web | ⏳ | Limited (no local notifications) |
| macOS | ⏳ | Future support |
| Windows | ⏳ | Future support |
| Linux | ⏳ | Future support |

---

## 🎨 Personalization

Users can customize:
- **Theme Mode**: System, Light, Dark
- **Accent Color**: 6 colors (Blue, Purple, Green, Orange, Pink, Teal)
- **Font Family**: Serif, Sans Serif, Monospace
- **Text Size**: 80% to 140%
- **Line Spacing**: 1.2x to 2.0x
- **Author Display**: Show/hide
- **Category Tags**: Show/hide
- **Haptic Feedback**: Enable/disable

All settings persist and apply instantly!

---

## 🔔 Notifications

### Daily Quote Notification
- Configurable time (user picks)
- Enable/disable toggle
- Test notification feature
- Background scheduling (works when app closed)
- Timezone-aware

### Implementation
- **Package**: `flutter_local_notifications`
- **Scheduling**: Daily repeat at user time
- **Payload**: Deep link to daily quote
- **Permissions**: Requested gracefully (iOS)

---

## 🎯 Performance

### Optimizations
- ✅ ListView.builder for efficient scrolling
- ✅ Cached network images
- ✅ Minimal provider rebuilds
- ✅ Lazy loading of feeds
- ✅ Pagination (20 quotes per page)
- ✅ Image compression for share cards
- ✅ Debounced search (400ms)

### Startup Time
- **Target**: < 1.5 seconds
- **Strategy**: 
  - Lazy provider initialization
  - Preload settings only
  - Background data sync

### Memory Management
- Dispose controllers properly
- Cancel stale network requests
- Clear image caches strategically

---

## 🧪 Testing

### Manual Testing Checklist
- [ ] App runs offline (airplane mode)
- [ ] No crashes on cold start
- [ ] Theme switching stable
- [ ] Notifications fire correctly
- [ ] Daily quote updates at midnight
- [ ] Sharing works on real device
- [ ] Settings persist after restart
- [ ] Favorites sync when online
- [ ] Text scaling doesn't break layout
- [ ] Haptic feedback works (if enabled)

### Test Commands
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze

# Check formatting
flutter format --set-exit-if-changed .
```

---

## 🔒 Security

### Best Practices
- ✅ No secrets in repository
- ✅ Environment variables for keys
- ✅ Supabase Row Level Security
- ✅ Secure auth session storage
- ✅ HTTPS only for API calls
- ✅ Privacy-safe logging (no PII)

### Data Privacy
- User data stays with user
- No tracking or analytics SDK (ready for integration)
- No data sold to third parties
- Supabase compliant with GDPR

---

## 📊 Analytics (Ready for Integration)

### Event Structure
Events are structured but SDK NOT integrated. Ready for Firebase Analytics, Mixpanel, etc.

**Tracked Events** (ready to log):
- `quote_viewed`
- `quote_liked`
- `quote_favorited`
- `collection_created`
- `quote_shared`
- `search_performed`
- `theme_changed`
- `daily_quote_viewed`

**Implementation**: `lib/core/analytics/analytics_events.dart`

---

## 🐛 Known Limitations

1. **Offline Writes**: Favorites/likes added offline don't persist until online
2. **Image Caching**: Quote card images regenerated each time (not cached)
3. **Search Offline**: Only works on cached quotes
4. **Real-time Updates**: Not implemented (future feature)
5. **Platform Differences**: Notifications work differently on iOS vs Android

---

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.x** - UI framework
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Material 3** - Design system

### Backend
- **Supabase** - Backend-as-a-Service
  - PostgreSQL database
  - Authentication
  - Storage
  - Row Level Security

### Local Storage
- **Hive** - Lightweight key-value database
- **SharedPreferences** - Settings persistence

### Key Packages
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `supabase_flutter` - Backend client
- `flutter_local_notifications` - Notifications
- `share_plus` - System sharing
- `connectivity_plus` - Network detection
- `image_gallery_saver` - Save images
- `permission_handler` - Permissions

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` before committing
- Run `flutter analyze` to catch issues

---

## 📝 AI Workflow Summary

**This app was built using AI-assisted development with Claude (Anthropic).**

### Development Process
1. **Staged Implementation** - 7 stages from foundation to polish
2. **Specification-Driven** - Each stage had detailed JSON specs
3. **Iterative Refinement** - Multiple rounds of feedback and improvements
4. **Best Practices** - Clean architecture, offline-first, performance-optimized

### Stages Completed
1. ✅ **Stage 0**: Bootstrap & Foundation
2. ✅ **Stage 1**: Authentication & User Profile
3. ✅ **Stage 2**: Quote Browsing & Discovery
4. ✅ **Stage 3**: Favorites, Likes & Collections
5. ✅ **Stage 4**: Daily Quote & Notifications
6. ✅ **Stage 5**: Quote Sharing & Image Export
7. ✅ **Stage 6**: Personalization & Settings
8. ✅ **Stage 7**: Production Hardening (This stage!)

### Key Learnings
- AI excels at boilerplate and structure
- Human guidance crucial for UX decisions
- Iterative approach beats big-bang development
- Documentation throughout saves time

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) - Amazing framework
- [Supabase](https://supabase.com/) - Excellent BaaS
- [Riverpod](https://riverpod.dev/) - Clean state management
- Quote data from various public domain sources

---

## 📞 Contact

**Project Maintainer**: Your Name  
**Email**: your.email@example.com  
**GitHub**: [@yourusername](https://github.com/yourusername)

---

## 🗺️ Roadmap

### v2.0 (Future)
- [ ] Real-time collaboration on collections
- [ ] AI-powered quote recommendations
- [ ] Quote widgets for home screen
- [ ] Multi-language support
- [ ] Social features (follow users, share collections)
- [ ] Audio quotes (text-to-speech)
- [ ] Dark mode scheduling
- [ ] Export collections as PDF

### v1.1 (Next)
- [ ] Better offline queue management
- [ ] Quote card templates customization
- [ ] Search filters (by length, date, etc.)
- [ ] Reading streaks and statistics
- [ ] Backup & restore

---

**Made with ❤️ and Flutter**

**Star ⭐ this repo if you found it helpful!**

