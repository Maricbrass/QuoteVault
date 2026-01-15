# QuoteVault

A production-ready Flutter application for quote discovery, collection, and personalization with cloud sync, AI-driven recommendations, and collaboration features.

## 🏗️ Architecture

This project follows **Clean Architecture** with a **Feature-First** folder structure:

```
lib/
├── core/                    # Shared application infrastructure
│   ├── constants/          # App-wide constants
│   ├── errors/             # Centralized error handling
│   ├── router/             # Navigation configuration
│   ├── services/           # Core services (Supabase, Config)
│   ├── theme/              # Theme configuration
│   └── utils/              # Utility functions
│
├── auth/                   # Authentication feature
│   ├── data/              # Repositories
│   ├── domain/            # Domain models
│   └── presentation/      # UI, Controllers, Providers
│
├── quotes/                 # Quotes feature (prepared)
│   └── domain/            # Quote model
│
├── home/                   # Home screen
│   └── presentation/
│
├── app.dart               # Root app widget
└── main.dart              # Entry point
```

## 🚀 Tech Stack

- **Framework**: Flutter 3.9+
- **State Management**: Riverpod (flutter_riverpod)
- **Navigation**: GoRouter
- **Backend**: Supabase (Auth + Database)
- **Environment**: flutter_dotenv
- **Local Storage**: Hive, SharedPreferences
- **Logging**: Custom logger with conditional output

## 📋 Prerequisites

- Flutter SDK 3.9.0 or higher
- Dart SDK 3.9.0 or higher
- A Supabase account and project

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd quotevault
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key from project settings
3. Update the `.env` file in the root directory:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 4. Run the App

```bash
flutter run
```

## 🔐 Environment Variables

The app uses `flutter_dotenv` for environment configuration. **Never commit your `.env` file!**

Required variables:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key

A `.env.example` file is provided as a template.

## 📱 Features Status

### ✅ Implemented (Stage 0 - Bootstrap)
- Clean architecture setup
- Supabase integration
- Authentication (Sign in/Sign out)
- Environment configuration
- Navigation with route guards
- Centralized error handling
- Theme configuration (Light/Dark)
- Logging system

### 🚧 Coming Soon
- Quote browsing and discovery
- Favorites and collections
- AI-driven recommendations
- Widgets and notifications
- User settings
- Profile management

## 🏛️ Architecture Layers

### 1. Presentation Layer
- **Screens**: UI components
- **Controllers**: Business logic using StateNotifier
- **Providers**: Riverpod providers for dependency injection

### 2. Domain Layer
- **Models**: Pure Dart classes representing business entities
- Independent of any framework or external library

### 3. Data Layer
- **Repositories**: Abstract data sources
- **Services**: External service integrations (Supabase)

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🎨 Code Style

This project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and uses `flutter_lints` for code analysis.

Run linting:
```bash
flutter analyze
```

Format code:
```bash
dart format lib/
```

## 🔒 Security

- Environment variables are never committed
- Supabase Row Level Security (RLS) should be configured
- All sensitive data is stored securely
- Auth tokens are managed by Supabase SDK

## 📦 Project Structure Details

### Core Services

**SupabaseService**: Singleton service managing Supabase client
- Handles authentication
- Provides database access
- Manages real-time subscriptions

**EnvConfig**: Environment variable management
- Type-safe access to configuration
- Graceful handling of missing values

**AppLogger**: Centralized logging
- Automatic verbosity control based on build mode
- Consistent log formatting

### Error Handling

All errors extend `AppException`:
- `AuthException`: Authentication errors
- `NetworkException`: Network-related errors
- `StorageException`: Local storage errors
- `UnknownException`: Unexpected errors

## 🚦 Navigation Flow

```
SplashScreen (/)
    ├─ Authenticated → HomeScreen (/home)
    └─ Not Authenticated → LoginScreen (/login)
```

Route guards automatically redirect users based on authentication state.

## 🤝 Contributing

1. Follow the existing code structure
2. Write tests for new features
3. Update documentation
4. Follow the commit message conventions

## 📄 License

This project is private and proprietary.

## 📧 Support

For issues or questions, please contact the development team.

---

**Built with ❤️ using Flutter**
