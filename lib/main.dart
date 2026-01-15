import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/services/env_config.dart';
import 'core/services/supabase_service.dart';
import 'core/utils/logger.dart';
import 'daily_quote/services/notification_service.dart';

/// Application entry point
/// Initializes all required services before running the app
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: QuoteVaultApp(),
    ),
  );
}

/// Initialize all required services
Future<void> _initializeServices() async {
  try {
    appLogger.info('Initializing QuoteVault services...');

    // Initialize Hive for local storage
    await Hive.initFlutter();
    appLogger.info('Hive initialized');

    // Load environment configuration
    await EnvConfig.init();
    appLogger.info('Environment configuration loaded');

    // Initialize Supabase
    if (EnvConfig.isConfigured) {
      await SupabaseService.initialize();
      appLogger.info('Supabase initialized');
    } else {
      appLogger.warning(
        'Supabase configuration missing. Please update .env file.',
      );
    }

    // Initialize notification service
    await NotificationService().initialize();
    appLogger.info('Notification service initialized');

    appLogger.info('All services initialized successfully');
  } catch (e, stackTrace) {
    appLogger.error('Failed to initialize services', e, stackTrace);
    // Allow app to continue even if some services fail
    // The app will show appropriate error messages to the user
  }
}
