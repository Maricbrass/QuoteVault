import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../collections/presentation/controllers/collections_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/user.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

/// Profile screen displaying user information and settings
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _imagePicker = ImagePicker();
  bool _isEditingName = false;
  bool _isEditingBio = false;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      final imageFile = File(image.path);

      if (!mounted) return;

      final userId = ref.read(authControllerProvider).user?.id;
      if (userId == null) return;

      await ref
          .read(profileControllerProvider(userId).notifier)
          .updateAvatar(imageFile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update avatar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _removeAvatar() async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;

    try {
      await ref
          .read(profileControllerProvider(userId).notifier)
          .removeAvatar();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar removed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove avatar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Name cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;

    try {
      await ref
          .read(profileControllerProvider(userId).notifier)
          .updateName(newName);

      if (!mounted) return;

      setState(() {
        _isEditingName = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update name: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _updateBio() async {
    final newBio = _bioController.text.trim();

    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;

    try {
      await ref
          .read(profileControllerProvider(userId).notifier)
          .updateBio(newBio);

      if (!mounted) return;

      setState(() {
        _isEditingBio = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bio updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update bio: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadAvatar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove avatar'),
              onTap: () {
                Navigator.pop(context);
                _removeAvatar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(authControllerProvider.notifier).signOut();

      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        // Explore - assuming search or quotes
        context.go(AppRoutes.quotes);
        break;
      case 2:
        // Quotes - assuming quotes feed
        context.go(AppRoutes.quotes);
        break;
      case 3:
        // Profile - already here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.id;

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not authenticated'),
        ),
      );
    }

    final profileState = ref.watch(profileControllerProvider(userId));
    final profile = profileState.profile;

    final collectionsState = ref.watch(collectionsControllerProvider);
    final favoritesState = ref.watch(favoritesControllerProvider);

    final quotesSaved = favoritesState.favoritedQuotes?.length ?? 0;
    final collectionsCount = collectionsState.collections.length;

    if (profileState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(profileControllerProvider(userId).notifier)
                      .loadProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.go(AppRoutes.settings);
          },
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider(userId).notifier)
              .refresh();
          await ref
              .read(collectionsControllerProvider.notifier)
              .loadCollections();
          await ref
              .read(favoritesControllerProvider.notifier)
              .loadFavoritedQuotes();
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Header
            _buildProfileHeader(profile, profileState),
            const SizedBox(height: 32),

            // Profile Stats
            _buildProfileStats(quotesSaved, collectionsCount),
            const SizedBox(height: 32),

            // Bio Section
            _buildBioSection(profile),
            const SizedBox(height: 32),

            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User profile, ProfileState profileState) {
    return Row(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: profile.hasAvatar
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: !profile.hasAvatar
                  ? Text(
                      profile.initials,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 15),
                  color: Colors.white,
                  onPressed: profileState.isUpdating ? null : _showAvatarOptions,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Name and Username
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isEditingName
                  ? TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                    )
                  : Text(
                      profile.name ?? 'No name',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
              Text(
                '@${profile.email.split('@')[0]}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),

        // Edit Profile Button
        ElevatedButton(
          onPressed: () {
            if (_isEditingName) {
              _updateName();
            } else {
              setState(() {
                _nameController.text = profile.name ?? '';
                _isEditingName = true;
              });
            }
          },
          child: Text(_isEditingName ? 'Save' : 'Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildProfileStats(int quotesSaved, int collectionsCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(quotesSaved.toString(), 'Quotes Saved'),
        _buildStatItem(collectionsCount.toString(), 'Collections'),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildBioSection(User profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Bio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _isEditingBio
            ? TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  hintText: 'Enter your bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              )
            : Text(
                profile.bio ?? 'No bio yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              if (_isEditingBio) {
                _updateBio();
              } else {
                setState(() {
                  _bioController.text = profile.bio ?? '';
                  _isEditingBio = true;
                });
              }
            },
            child: Text(_isEditingBio ? 'Save' : 'Edit'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    // Dummy data for recent activity
    final activities = [
      {
        'icon': Icons.bookmark,
        'action': 'Saved a new quote',
        'detail': '"Nature does not hurry, yet everything is accomplished."',
        'time': '2h ago',
      },
      {
        'icon': Icons.folder,
        'action': 'Created collection',
        'detail': '"Morning Reflections" • 5 items',
        'time': '1d ago',
      },
      {
        'icon': Icons.favorite,
        'action': 'Liked a quote',
        'detail': '"The only way out is through." - Robert Frost',
        'time': '3d ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(activity['icon'] as IconData, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  activity['detail'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

