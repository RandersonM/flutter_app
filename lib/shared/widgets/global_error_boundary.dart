import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/utils/app_routes.dart';

class GlobalErrorBoundary extends StatefulWidget {
  final Widget child;

  const GlobalErrorBoundary({Key? key, required this.child}) : super(key: key);

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
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
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
                      const AppIcon(
                        PhosphorIconsRegular.bug,
                        color: Color(0xFFE94560),
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Oops! Something went wrong.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'An unexpected error occurred in the user interface. Don\'t worry, the Straw Hats are on it!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_errorDetails != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          constraints: const BoxConstraints(maxHeight: 200),
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Text(
                              _errorDetails!.exceptionAsString(),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94560),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
                        icon: const AppIcon(
                            PhosphorIconsRegular.arrowsClockwise),
                        label: Text(AppLocalizations.of(context)!.tryAgain),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
                              context, AppRoutes.home, (route) => false);
                        },
                        icon: const AppIcon(PhosphorIconsRegular.house),
                        label: Text(AppLocalizations.of(context)!.goHomeAction),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
