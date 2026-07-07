import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/app/di/injection.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';
import 'package:opfan/core/connectivity/connectivity_state.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Wraps the entire widget tree and shows a persistent top banner whenever
/// the device loses internet connectivity.
///
/// Usage in main.dart:
/// ```dart
/// home: OfflineBannerWrapper(child: AppWrapper()),
/// ```
class OfflineBannerWrapper extends StatelessWidget {
  const OfflineBannerWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ConnectivityCubit>(),
      child: Column(
        children: [
          BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    SizeTransition(sizeFactor: animation, child: child),
                child: state is ConnectivityOffline
                    ? const _OfflineBannerTile(key: ValueKey('offline'))
                    : const SizedBox.shrink(key: ValueKey('online')),
              );
            },
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _OfflineBannerTile extends StatelessWidget {
  const _OfflineBannerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const AppIcon(
                PhosphorIconsRegular.wifiSlash,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.offlineBannerMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
