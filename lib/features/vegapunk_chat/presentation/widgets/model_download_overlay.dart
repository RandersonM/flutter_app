import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/constants.dart';

import '../../cubit/vegapunk_chat_state.dart';

/// Full-screen overlay for model lifecycle states (not installed / downloading /
/// loading / error). Rendered on top of the empty chat scaffold.
class ModelDownloadOverlay extends StatelessWidget {
  const ModelDownloadOverlay({
    super.key,
    required this.state,
    required this.onDownload,
    required this.onRetry,
  });

  final VegapunkChatState state;
  final VoidCallback onDownload;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      VegapunkModelNotInstalled() => _NotInstalledView(onDownload: onDownload),
      VegapunkModelDownloading(:final progress) =>
        _DownloadingView(progress: progress),
      VegapunkModelLoading() => const _LoadingView(),
      VegapunkChatError(:final message, :final isInstallError) => _ErrorView(
          message: message,
          isInstallError: isInstallError,
          onRetry: onRetry,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── Not Installed ─────────────────────────────────────────────────────────────

class _NotInstalledView extends StatelessWidget {
  const _NotInstalledView({required this.onDownload});
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _Shell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.robot,
            size: Constants.size64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: Constants.size16),
          Text(
            l10n.vegapunkModelDownloadTitle,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.size12),
          Text(
            l10n.vegapunkModelDownloadSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.size32),
          FilledButton.icon(
            onPressed: onDownload,
            icon: const Icon(PhosphorIconsRegular.downloadSimple),
            label: Text(l10n.vegapunkModelDownloadTitle),
          ),
        ],
      ),
    );
  }
}

// ── Downloading ───────────────────────────────────────────────────────────────

class _DownloadingView extends StatelessWidget {
  const _DownloadingView({required this.progress});
  final int progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _Shell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.cloudArrowDown,
            size: Constants.size64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: Constants.size16),
          Text(
            l10n.vegapunkModelDownloadTitle,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.size24),
          LinearProgressIndicator(
            value: progress / 100,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: Constants.margin),
          Text(
            '$progress%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _Shell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: Constants.size48,
            height: Constants.size48,
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: Constants.size24),
          Text(
            l10n.vegapunkModelLoadingTitle,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.isInstallError,
    required this.onRetry,
  });

  final String message;
  final bool isInstallError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return _Shell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.warningCircle,
            size: Constants.size64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: Constants.size16),
          Text(
            l10n.vegapunkModelErrorTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Constants.size12),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Constants.size32),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(PhosphorIconsRegular.arrowCounterClockwise),
            label: Text(l10n.vegapunkRetry),
          ),
        ],
      ),
    );
  }
}

// ── Shell ─────────────────────────────────────────────────────────────────────

class _Shell extends StatelessWidget {
  const _Shell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Constants.size32),
        child: child,
      ),
    );
  }
}
