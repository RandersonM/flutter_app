import 'package:flutter/material.dart';
import 'package:opfan/core/auth/models/user_model.dart';
import 'package:opfan/widgets/atoms/circle_avatar.dart';
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
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Constants.margin * 2),
            child: Column(
              children: [
                CircleAvatarAtom(
                  imageUrl: user.photoUrl,
                  radius: 40,
                ),
                const SizedBox(height: Constants.margin),
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Constants.margin / 2),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.create),
            title: Text(AppLocalizations.of(context)!.createCustomCharacter),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.createCustomCharacter,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text(AppLocalizations.of(context)!.myCharacters),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.customCharacterList);
            }
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(AppLocalizations.of(context)!.profile),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.settings),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.customCharacterList);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () {
              Navigator.pop(context);
              authBloc.add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
    );
  }
} 