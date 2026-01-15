import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/settings_enums.dart' as enums;

/// Modern comprehensive settings screen with live preview
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF101022)
          : const Color(0xFFF6F6F8),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: isDarkMode
                ? const Color(0xFF101022).withOpacity(0.8)
                : const Color(0xFFF6F6F8).withOpacity(0.8),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: colorScheme.primary,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Live Preview Section
                  _buildLivePreview(context, settings, isDarkMode),

                  const SizedBox(height: 24),

                  // Display Settings
                  _buildSectionHeader('DISPLAY SETTINGS', isDarkMode),
                  const SizedBox(height: 12),
                  _buildDisplaySettings(context, ref, settings, isDarkMode),

                  const SizedBox(height: 24),

                  // Accent Color
                  _buildSectionHeader('ACCENT COLOR', isDarkMode, center: true),
                  const SizedBox(height: 16),
                  _buildAccentColorPicker(context, ref, settings, isDarkMode),

                  const SizedBox(height: 24),

                  // Preferences
                  _buildSectionHeader('PREFERENCES', isDarkMode),
                  const SizedBox(height: 12),
                  _buildPreferences(context, ref, isDarkMode),

                  const SizedBox(height: 24),

                  // Logout Section
                  _buildLogoutSection(context, ref, isDarkMode),

                  const SizedBox(height: 16),

                  // App Version
                  Center(
                    child: Text(
                      'QuoteVault v2.4.0 • Premium Member',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode, {bool center = false}) {
    return Padding(
      padding: center ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildLivePreview(BuildContext context, settings, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'LIVE PREVIEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.format_quote,
            color: Theme.of(context).colorScheme.primary,
            size: 36,
          ),
          const SizedBox(height: 16),
          Text(
            '"The only way to do great work is to love what you do."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (20 * settings.fontSizeScale).toDouble(),
              fontWeight: FontWeight.w500,
              height: settings.lineSpacing,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (settings.showAuthor) ...[
            const SizedBox(height: 16),
            Text(
              '— Steve Jobs',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(BuildContext context, WidgetRef ref, settings, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          // Dark Mode Toggle
          _buildListTile(
            context: context,
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: _buildSwitch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                ref.read(settingsControllerProvider.notifier)
                    .updateThemeMode(value ? enums.ThemeMode.dark : enums.ThemeMode.light);
              },
              isDarkMode: isDarkMode,
            ),
            isDarkMode: isDarkMode,
            showBorder: true,
          ),

          // Font Size Slider
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildIconCircle(Icons.text_fields, context, isDarkMode),
                    const SizedBox(width: 16),
                    const Text(
                      'Font Size',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
                          ),
                        ),
                        child: Slider(
                          value: settings.fontSizeScale,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          onChanged: (value) {
                            ref.read(settingsControllerProvider.notifier)
                                .updateFontSizeScale(value);
                          },
                        ),
                      ),
                    ),
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentColorPicker(BuildContext context, WidgetRef ref, settings, bool isDarkMode) {
    final colors = [
      {'name': 'INDIGO', 'color': const Color(0xFF1111D4), 'value': enums.AccentColor.blue},
      {'name': 'TEAL', 'color': const Color(0xFF2DD4BF), 'value': enums.AccentColor.teal},
      {'name': 'AMBER', 'color': const Color(0xFFF59E0B), 'value': enums.AccentColor.orange},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: colors.map((colorData) {
          final color = colorData['color'] as Color;
          final name = colorData['name'] as String;
          final accentValue = colorData['value'] as enums.AccentColor;
          final isSelected = settings.accentColor == accentValue;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                ref.read(settingsControllerProvider.notifier)
                    .updateAccentColor(accentValue);
              },
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: isSelected
                          ? Border.all(
                              color: color,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? const Color(0xFF101022)
                                    : Colors.white,
                                width: 3,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isSelected ? color : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreferences(BuildContext context, WidgetRef ref, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          _buildListTile(
            context: context,
            icon: Icons.notifications,
            title: 'Daily Reminders',
            trailing: _buildSwitch(
              value: true,
              onChanged: (value) {},
              isDarkMode: isDarkMode,
            ),
            isDarkMode: isDarkMode,
            showBorder: true,
          ),
          _buildListTile(
            context: context,
            icon: Icons.translate,
            title: 'App Language',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'English',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[500],
                  size: 20,
                ),
              ],
            ),
            isDarkMode: isDarkMode,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await ref.read(authControllerProvider.notifier).signOut();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red[500],
                ),
                const SizedBox(width: 12),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget trailing,
    required bool isDarkMode,
    bool showBorder = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100]!,
                ),
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildIconCircle(icon, context, isDarkMode),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, BuildContext context, bool isDarkMode) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF1111D4),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: isDarkMode
          ? Colors.grey[700]
          : Colors.grey[300],
    );
  }
}

