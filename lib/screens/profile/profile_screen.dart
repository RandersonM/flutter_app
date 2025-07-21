// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/core/services/theme_service.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/widgets/molecules/clickable_avatar.dart';
import 'package:opfan/core/services/locale_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
    ThemeService().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    super.dispose();
  }

  void _loadCurrentTheme() {
    setState(() {
      _isDarkMode = ThemeService.isDarkMode;
    });
  }

  void _onThemeChanged() {
    _loadCurrentTheme();
  }

  Future<void> _toggleTheme() async {
    await ThemeService.toggleTheme();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ThemeService.isDarkMode
              ? AppLocalizations.of(context)!.darkThemeActivated
              : AppLocalizations.of(context)!.lightThemeActivated),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildProfileContent(context, state.user);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                ClickableAvatar(
                  imageUrl: user.photoUrl,
                  radius: 60,
                  onTap: () {
                    // Could open image viewer or edit profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.profilePhotoTapped),
                      ),
                    );
                  },
                ),
                const SizedBox(height: Constants.margin),
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: Constants.margin * 2),
          
          // Profile Sections
          _buildSection(
            context,
            title: AppLocalizations.of(context)!.accountSettings,
            items: [
              _buildProfileItem(
                context,
                icon: Icons.person,
                title: AppLocalizations.of(context)!.editProfile,
                subtitle: AppLocalizations.of(context)!.editProfileSubtitle,
                onTap: () {
                  // Navigate to edit profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.editProfileTapped)),
                  );
                },
              ),
              _buildProfileItem(
                context,
                icon: Icons.notifications,
                title: AppLocalizations.of(context)!.notifications,
                subtitle: AppLocalizations.of(context)!.notificationsSubtitle,
                onTap: () {
                  // Navigate to notifications settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.notificationsTapped)),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: Constants.margin),
          
          _buildSection(
            context,
            title: AppLocalizations.of(context)!.appSettings,
            items: [
              _buildProfileItem(
                context,
                icon: Icons.language,
                title: AppLocalizations.of(context)!.language,
                subtitle: AppLocalizations.of(context)!.languageSubtitle,
                onTap: () async {
                  final selected = await showDialog<Locale>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(AppLocalizations.of(context)!.language),
                      children: [
                        SimpleDialogOption(
                          child: const Text('English'),
                          onPressed: () =>
                              Navigator.pop(context, const Locale('en')),
                        ),
                        SimpleDialogOption(
                          child: const Text('Português'),
                          onPressed: () =>
                              Navigator.pop(context, const Locale('pt')),
                        ),
                      ],
                    ),
                  );
                  if (selected != null) {
                    await LocaleService.setLocale(selected);
                  }
                },
              ),
              _buildThemeItem(context),
            ],
          ),
          
          const SizedBox(height: Constants.margin),
          
          _buildSection(
            context,
            title: AppLocalizations.of(context)!.support,
            items: [
              _buildProfileItem(
                context,
                icon: Icons.help,
                title: AppLocalizations.of(context)!.helpSupport,
                subtitle: AppLocalizations.of(context)!.helpSupportSubtitle,
                onTap: () {
                  // Navigate to help
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.helpSupportTapped)),
                  );
                },
              ),
              _buildProfileItem(
                context,
                icon: Icons.info,
                title: AppLocalizations.of(context)!.about,
                subtitle: AppLocalizations.of(context)!.aboutSubtitle,
                onTap: () {
                  // Navigate to about
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.aboutTapped)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeItem(BuildContext context) {
    return ListTile(
      leading: Icon(
        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        AppLocalizations.of(context)!.theme,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _isDarkMode
            ? AppLocalizations.of(context)!.darkTheme
            : AppLocalizations.of(context)!.lightTheme,
      ),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: (value) => _toggleTheme(),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: _toggleTheme,
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: Constants.margin),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 