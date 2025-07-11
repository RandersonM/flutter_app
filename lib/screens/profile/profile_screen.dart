// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/widgets/molecules/clickable_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            title: 'Account Settings',
            items: [
              _buildProfileItem(
                context,
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
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
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
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
            title: 'App Settings',
            items: [
              _buildProfileItem(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Change app language',
                onTap: () {
                  // Navigate to language settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.languageTapped)),
                  );
                },
              ),
              _buildProfileItem(
                context,
                icon: Icons.dark_mode,
                title: 'Theme',
                subtitle: 'Change app theme',
                onTap: () {
                  // Navigate to theme settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.themeTapped)),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: Constants.margin),
          
          _buildSection(
            context,
            title: 'Support',
            items: [
              _buildProfileItem(
                context,
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
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
                title: 'About',
                subtitle: 'App version and information',
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