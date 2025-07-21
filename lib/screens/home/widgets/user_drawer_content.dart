import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/widgets/atoms/circle_avatar.dart';
import 'package:opfan/widgets/atoms/gomu_gomu_divider.dart';
import 'package:opfan/widgets/atoms/futuristic_background.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/app_routes.dart' show AppRoutes;

class UserDrawerContent extends StatelessWidget {
  final UserModel user;
  final AuthBloc authBloc;
  const UserDrawerContent({Key? key, required this.user, required this.authBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FuturisticBackground(
      opacity: 0.15,
      customBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(Constants.margin * 2),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatarAtom(
                        imageUrl: user.photoUrl,
                        radius: 40,
                      ),
                    ),
                    const SizedBox(height: Constants.margin),
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.orange.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Constants.margin / 2),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              GomuGomuDivider(
                color: Theme.of(context).colorScheme.onPrimary,
                height: 12,
                thickness: 1.5,
                
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Constants.margin),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFuturisticListTile(
                      context,
                      icon: FontAwesomeIcons.userAstronaut,
                      title: AppLocalizations.of(context)!.myCharacters,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.customCharacterList);
                      },
                    ),
                    _buildFuturisticListTile(
                      context,
                      icon: FontAwesomeIcons.ship,
                      title: AppLocalizations.of(context)!.crew(2),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.listCrews,
                        );
                      },
                    ),
                    _buildFuturisticListTile(
                      context,
                      icon: FontAwesomeIcons.personDrowning,
                      title: AppLocalizations.of(context)!.devilFruit,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.devilFruit,
                        );
                      },
                    ),
                    _buildFuturisticListTile(
                      context,
                      icon: Icons.person,
                      title: AppLocalizations.of(context)!.profile,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                    ),
                  
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: Constants.margin),
                      child: GomuGomuDivider(
                        color: Theme.of(context).colorScheme.onPrimary, 
                        height: 12,
                        thickness: 1.5,
                      ),
                    ),
                    _buildFuturisticListTile(
                      context,
                      icon: Icons.logout,
                      title: AppLocalizations.of(context)!.logout,
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        authBloc.add(const AuthSignOutRequested());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive
        ? Theme.of(context).colorScheme.onError
        : Theme.of(context).colorScheme.surfaceContainer;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.margin,
        vertical: Constants.margin / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 