import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/connectivity/connectivity_cubit.dart';
import 'package:opfan/core/connectivity/connectivity_state.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Wraps a screen's `body` content with an overlay that blocks interaction
/// when the device is offline.
///
/// The `ConnectivityCubit` must already be provided above this widget (e.g.,
/// via [BlocProvider.value] in the parent screen's [MultiBlocProvider]).
///
/// The overlay sits on top of the existing content using a [Stack], so the
/// [Scaffold] AppBar and BottomNavigationBar remain visible and functional.
///
/// Usage:
/// ```dart
/// body: OfflineBlockerOverlay(
///   child: /* actual screen body content */,
/// ),
/// ```
class OfflineBlockerOverlay extends StatelessWidget {
  const OfflineBlockerOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state is ConnectivityOffline) const _OfflineOverlayContent(),
          ],
        );
      },
    );
  }
}

class _OfflineOverlayContent extends StatelessWidget {
  const _OfflineOverlayContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.96),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsRegular.wifiSlash,
                size: 72,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.offlineScreenTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.offlineScreenSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience mixin for screens that need to provide [ConnectivityCubit]
/// and show the offline blocker overlay.
///
/// Call [buildWithOfflineGuard] instead of returning a [Scaffold] directly.
mixin OfflineGuardMixin<T extends StatelessWidget> on StatelessWidget {
  ConnectivityCubit get connectivityCubit;

  Widget buildGuarded(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: connectivityCubit,
      child: buildGuarded(context),
    );
  }
}
