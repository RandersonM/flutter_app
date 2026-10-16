import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_routes.dart';
import 'package:opfan/shared/utils/theme.dart';

class GlobalErrorBoundary extends StatefulWidget {
  final Widget child;

  const GlobalErrorBoundary({super.key, required this.child});

  @override
  State<GlobalErrorBoundary> createState() => _GlobalErrorBoundaryState();
}

class _GlobalErrorBoundaryState extends State<GlobalErrorBoundary> {
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;
  ErrorWidgetBuilder? _previousBuilder;

  @override
  void initState() {
    super.initState();
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasError) {
            setState(() {
              _hasError = true;
              _errorDetails = details;
            });
          }
        });
      }
      // Return empty size during exception layout cycle
      return const SizedBox.shrink();
    };
  }

  @override
  void dispose() {
    if (_previousBuilder != null) {
      ErrorWidget.builder = _previousBuilder!;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // This boundary sits above the app's MaterialApp, so the fallback needs
      // its own localizations to resolve AppLocalizations.
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: getLightTheme(),
        darkTheme: getDarkTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: _buildErrorScreen),
      );
    }

    return widget.child;
  }

  Widget _buildErrorScreen(BuildContext localizedContext) {
    final l10n = AppLocalizations.of(localizedContext)!;
    final colorScheme = Theme.of(localizedContext).colorScheme;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.surface, colorScheme.surfaceContainer],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    PhosphorIconsRegular.bug,
                    color: colorScheme.error,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.errorBoundaryTitle,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.errorBoundaryMessage,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_errorDetails != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.24),
                        ),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Text(
                          _errorDetails!.exceptionAsString(),
                          style: TextStyle(
                            color: colorScheme.error,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _errorDetails = null;
                      });
                    },
                    icon: const AppIcon(PhosphorIconsRegular.arrowsClockwise),
                    label: Text(l10n.tryAgain),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _errorDetails = null;
                      });
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    icon: const AppIcon(PhosphorIconsRegular.house),
                    label: Text(l10n.goHomeAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
