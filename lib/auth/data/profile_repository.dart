import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/errors/app_exception.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/logger.dart';
import '../domain/user.dart';

/// Repository for user profile operations
/// Handles profile CRUD and avatar management
class ProfileRepository {
  final SupabaseService _supabaseService;

  ProfileRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  /// Get current user's profile from Supabase
  Future<User> getProfile(String userId) async {
    try {
      appLogger.info('Fetching profile for user: $userId');

      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      appLogger.info('Profile fetched successfully');
      return User.fromJson(response);
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error fetching profile', e, stackTrace);
      throw StorageException(
        message: 'Failed to load profile: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error fetching profile', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Create a new profile (called after signup)
  Future<User> createProfile({
    required String userId,
    required String email,
    String? name,
  }) async {
    try {
      appLogger.info('Creating profile for user: $userId');

      final profileData = {
        'id': userId,
        'email': email,
        'name': name ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      appLogger.info('Profile created successfully');
      return User.fromJson(response);
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error creating profile', e, stackTrace);
      throw StorageException(
        message: 'Failed to create profile: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error creating profile', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Update user profile (name, bio and/or avatar)
  Future<User> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      appLogger.info('Updating profile for user: $userId');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) {
        appLogger.warning('No updates provided for profile');
        return await getProfile(userId);
      }

      final response = await _supabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      appLogger.info('Profile updated successfully');
      return User.fromJson(response);
    } on supabase.PostgrestException catch (e, stackTrace) {
      appLogger.error('Postgrest error updating profile', e, stackTrace);
      throw StorageException(
        message: 'Failed to update profile: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error updating profile', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Upload avatar image to Supabase Storage
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      appLogger.info('Uploading avatar for user: $userId');

      // Generate unique filename
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload to Supabase Storage
      final response = await _supabaseService.client.storage
          .from('avatars')
          .upload(fileName, imageFile);

      // Get public URL
      final publicUrl = _supabaseService.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      appLogger.info('Avatar uploaded successfully: $publicUrl');
      return publicUrl;
    } on supabase.StorageException catch (e, stackTrace) {
      appLogger.error('Storage error uploading avatar', e, stackTrace);
      throw StorageException(
        message: 'Failed to upload avatar: ${e.message}',
        code: e.statusCode,
        originalError: e,
      );
    } catch (e, stackTrace) {
      appLogger.error('Unexpected error uploading avatar', e, stackTrace);
      throw StorageException.fromError(e);
    }
  }

  /// Delete old avatar from storage
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(avatarUrl);
      final path = uri.pathSegments.skip(3).join('/'); // Skip /storage/v1/object/public/avatars/

      appLogger.info('Deleting old avatar: $path');

      await _supabaseService.client.storage
          .from('avatars')
          .remove([path]);

      appLogger.info('Old avatar deleted successfully');
    } on supabase.StorageException catch (e, stackTrace) {
      // Don't throw error if deletion fails - it's not critical
      appLogger.warning('Failed to delete old avatar', e, stackTrace);
    } catch (e, stackTrace) {
      appLogger.warning('Unexpected error deleting avatar', e, stackTrace);
    }
  }

  /// Check if profile exists for user
  Future<bool> profileExists(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      appLogger.warning('Error checking if profile exists', e);
      return false;
    }
  }
}

