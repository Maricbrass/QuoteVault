# QuoteVault - Developer Quick Reference

## 🚀 Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Run app (debug mode)
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload (press in terminal)
r

# Hot restart (press in terminal)
R

# Clean build
flutter clean && flutter pub get

# Format code
dart format lib/

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 📁 Project Structure Quick Reference

```
lib/
├── core/              # Shared infrastructure
├── auth/              # Authentication
├── quotes/            # Quotes (prepared)
├── home/              # Home screen
├── app.dart           # Root widget
└── main.dart          # Entry point
```

## 🔑 Important Files

| File | Purpose |
|------|---------|
| `.env` | Environment variables (NOT committed) |
| `pubspec.yaml` | Dependencies and assets |
| `app_router.dart` | Navigation configuration |
| `app_theme.dart` | Theme customization |
| `supabase_service.dart` | Supabase client |

## 🏗️ Adding a New Feature

### 1. Create Feature Folder Structure

```bash
lib/
└── feature_name/
    ├── data/
    │   └── feature_repository.dart
    ├── domain/
    │   └── feature_model.dart
    └── presentation/
        ├── controllers/
        │   └── feature_controller.dart
        ├── screens/
        │   └── feature_screen.dart
        └── feature_providers.dart
```

### 2. Create Domain Model

```dart
// lib/feature_name/domain/feature_model.dart
class FeatureModel {
  final String id;
  final String name;
  
  const FeatureModel({required this.id, required this.name});
  
  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

### 3. Create Repository

```dart
// lib/feature_name/data/feature_repository.dart
import '../../core/services/supabase_service.dart';
import '../domain/feature_model.dart';

class FeatureRepository {
  final SupabaseService _supabaseService;
  
  FeatureRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;
  
  Future<List<FeatureModel>> getAll() async {
    try {
      final response = await _supabaseService.client
          .from('table_name')
          .select();
      
      return (response as List)
          .map((json) => FeatureModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}
```

### 4. Create Controller

```dart
// lib/feature_name/presentation/controllers/feature_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/feature_repository.dart';
import '../../domain/feature_model.dart';

class FeatureState {
  final List<FeatureModel> items;
  final bool isLoading;
  final String? error;
  
  const FeatureState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });
  
  FeatureState copyWith({
    List<FeatureModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return FeatureState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FeatureController extends StateNotifier<FeatureState> {
  final FeatureRepository _repository;
  
  FeatureController(this._repository) : super(const FeatureState());
  
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final items = await _repository.getAll();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

### 5. Create Providers

```dart
// lib/feature_name/presentation/feature_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feature_repository.dart';
import 'controllers/feature_controller.dart';

final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  return FeatureRepository();
});

final featureControllerProvider = 
    StateNotifierProvider<FeatureController, FeatureState>((ref) {
  final repository = ref.watch(featureRepositoryProvider);
  return FeatureController(repository);
});
```

### 6. Create Screen

```dart
// lib/feature_name/presentation/screens/feature_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../feature_providers.dart';

class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Feature')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ListTile(title: Text(item.name));
              },
            ),
    );
  }
}
```

### 7. Add Route

```dart
// lib/core/router/app_router.dart
GoRoute(
  path: '/feature',
  name: 'feature',
  builder: (context, state) => const FeatureScreen(),
),
```

## 🎨 Theme Customization

```dart
// lib/core/theme/app_theme.dart
static const Color primaryColor = Color(0xFF6750A4); // Change this
```

## 🔐 Accessing Auth State

```dart
// In any ConsumerWidget or ConsumerStatefulWidget
final user = ref.watch(currentUserProvider);
final isAuthenticated = ref.watch(isAuthenticatedProvider);

if (user != null) {
  print('User email: ${user.email}');
}
```

## 🗺️ Navigation

```dart
// Navigate to route
context.go('/route-path');

// Navigate with parameters
context.go('/quotes/${quoteId}');

// Go back
context.pop();

// Replace current route
context.replace('/new-route');
```

## 📝 Logging

```dart
import 'core/utils/logger.dart';

appLogger.debug('Debug message');
appLogger.info('Info message');
appLogger.warning('Warning message');
appLogger.error('Error message', error, stackTrace);
```

## 🚨 Error Handling

```dart
try {
  await repository.someOperation();
} on AuthException catch (e) {
  appLogger.error('Auth error', e);
  // Handle auth-specific error
} on NetworkException catch (e) {
  appLogger.error('Network error', e);
  // Handle network error
} catch (e, stackTrace) {
  appLogger.error('Unexpected error', e, stackTrace);
  // Handle generic error
}
```

## 🧪 Testing Patterns

### Repository Test
```dart
test('should return list of items', () async {
  final repository = FeatureRepository();
  final items = await repository.getAll();
  expect(items, isA<List<FeatureModel>>());
});
```

### Controller Test
```dart
test('should load items successfully', () async {
  final controller = FeatureController(mockRepository);
  await controller.loadItems();
  expect(controller.state.items, isNotEmpty);
  expect(controller.state.isLoading, false);
});
```

### Widget Test
```dart
testWidgets('should display items', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: FeatureScreen()),
    ),
  );
  
  expect(find.byType(ListView), findsOneWidget);
});
```

## 📦 Common Dependencies

```yaml
# State Management
flutter_riverpod: ^2.6.1

# Navigation
go_router: ^14.6.2

# Backend
supabase_flutter: ^2.9.1

# Environment
flutter_dotenv: ^5.2.1

# Storage
hive: ^2.2.3
shared_preferences: ^2.3.3

# Utils
logger: ^2.5.0
intl: ^0.19.0
```

## 🔧 Common Tasks

### Add a new dependency
```bash
flutter pub add package_name
flutter pub get
```

### Generate code (if using build_runner)
```bash
flutter pub run build_runner build
# or watch mode
flutter pub run build_runner watch
```

### Update dependencies
```bash
flutter pub upgrade
```

### Check outdated packages
```bash
flutter pub outdated
```

## 🐛 Debugging Tips

### Enable verbose logging
Set in `app_logger.dart`:
```dart
level: Level.debug
```

### View Supabase logs
1. Go to Supabase dashboard
2. Navigate to Logs
3. Filter by type (Auth, Database, etc.)

### Clear app data
```bash
# Android
adb shell pm clear com.example.quotevault

# iOS (simulator)
xcrun simctl uninstall booted com.example.quotevault
```

### Reset Hive storage
```dart
await Hive.deleteBoxFromDisk('box_name');
```

## 📱 Platform-Specific Notes

### Android
- Min SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)

### iOS
- Min iOS: 12.0
- Requires Xcode 14+

### Web
- Enable CORS in Supabase dashboard
- Check browser console for errors

## 🔗 Useful Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

## 💡 Pro Tips

1. **Use const constructors** wherever possible for performance
2. **Always dispose controllers** in StatefulWidgets
3. **Handle loading and error states** in UI
4. **Log important events** for debugging
5. **Write tests** as you develop features
6. **Follow the existing architecture** pattern
7. **Document complex logic** with comments
8. **Use meaningful variable names**
9. **Keep functions small** and focused
10. **Review code** before committing

---

**Happy coding! 🎉**

