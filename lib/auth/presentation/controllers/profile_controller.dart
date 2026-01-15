import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../data/profile_repository.dart';
import '../../domain/user.dart';
import 'auth_controller.dart';

/// State for profile operations
class ProfileState {
  final bool isLoading;
  final bool isUpdating;
  final User? profile;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    User? profile,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  ProfileState clearMessages() {
    return ProfileState(
      isLoading: isLoading,
      isUpdating: isUpdating,
      profile: profile,
    );
  }
}

/// Controller for profile operations
/// Handles profile fetching, updates, and avatar management
class ProfileController extends StateNotifier<ProfileState> {
  final ProfileRepository _profileRepository;
  final String _userId;

  ProfileController(
    this._profileRepository,
    this._userId,
  ) : super(const ProfileState()) {
    // Load profile when controller is created
    loadProfile();
  }

  /// Load user profile from Supabase
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      appLogger.info('Loading profile for user: $_userId');
      final profile = await _profileRepository.getProfile(_userId);

      state = state.copyWith(
        isLoading: false,
        profile: profile,
      );
      appLogger.info('Profile loaded successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to load profile', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: ${_getErrorMessage(e)}',
      );
    }
  }

  /// Update user profile name
  Future<void> updateName(String name) async {
    if (name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Name cannot be empty');
      return;
    }

    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      appLogger.info('Updating profile name');
      final updatedProfile = await _profileRepository.updateProfile(
        userId: _userId,
        name: name.trim(),
      );

      state = state.copyWith(
        isUpdating: false,
        profile: updatedProfile,
        successMessage: 'Name updated successfully',
      );
      appLogger.info('Profile name updated');
    } catch (e, stackTrace) {
      appLogger.error('Failed to update profile name', e, stackTrace);
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to update name: ${_getErrorMessage(e)}',
      );
      rethrow;
    }
  }

  /// Upload and update avatar
  Future<void> updateAvatar(File imageFile) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      appLogger.info('Uploading new avatar');

      // Delete old avatar if exists
      if (state.profile?.hasAvatar == true) {
        await _profileRepository.deleteAvatar(state.profile!.avatarUrl!);
      }

      // Upload new avatar
      final avatarUrl = await _profileRepository.uploadAvatar(
        userId: _userId,
        imageFile: imageFile,
      );

      // Update profile with new avatar URL
      final updatedProfile = await _profileRepository.updateProfile(
        userId: _userId,
        avatarUrl: avatarUrl,
      );

      state = state.copyWith(
        isUpdating: false,
        profile: updatedProfile,
        successMessage: 'Avatar updated successfully',
      );
      appLogger.info('Avatar updated successfully');
    } catch (e, stackTrace) {
      appLogger.error('Failed to update avatar', e, stackTrace);
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to update avatar: ${_getErrorMessage(e)}',
      );
      rethrow;
    }
  }

  /// Remove avatar
  Future<void> removeAvatar() async {
    if (state.profile?.hasAvatar != true) {
      return;
    }

    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      appLogger.info('Removing avatar');

      // Delete avatar from storage
      await _profileRepository.deleteAvatar(state.profile!.avatarUrl!);

      // Update profile to remove avatar URL
      final updatedProfile = await _profileRepository.updateProfile(
        userId: _userId,
        avatarUrl: '',
      );

      state = state.copyWith(
        isUpdating: false,
        profile: updatedProfile,
        successMessage: 'Avatar removed successfully',
      );
      appLogger.info('Avatar removed');
    } catch (e, stackTrace) {
      appLogger.error('Failed to remove avatar', e, stackTrace);
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to remove avatar: ${_getErrorMessage(e)}',
      );
      rethrow;
    }
  }

  /// Refresh profile (for pull-to-refresh)
  Future<void> refresh() async {
    await loadProfile();
  }

  /// Clear messages
  void clearMessages() {
    state = state.clearMessages();
  }

  /// Extract user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }

    if (errorString.startsWith('StorageException: ')) {
      return errorString.substring(18);
    }

    return errorString;
  }
}

/// Provider for profile controller
/// Requires authenticated user ID
final profileControllerProvider =
    StateNotifierProvider.family<ProfileController, ProfileState, String>(
  (ref, userId) {
    final profileRepository = ref.watch(profileRepositoryProvider);
    return ProfileController(profileRepository, userId);
  },
);

/// Convenience provider for current user's profile
final currentUserProfileProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.id ?? '';

  if (userId.isEmpty) {
    throw Exception('User not authenticated');
  }

  return ref.watch(profileControllerProvider(userId).notifier);
});

