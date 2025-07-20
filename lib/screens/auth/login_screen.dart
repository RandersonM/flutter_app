// Developed by Randerson Mayllon
// Copyright © 2025.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/services/service_locator.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/app_routes.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/utils/theme.dart';
import 'package:opfan/widgets/atoms/circle_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _currentImageIndex = 0;
  bool _isChanging = false;
  final List<String> _loginImages = [
    'assets/logo/login-image.jpg',
    'assets/logo/login-image-2.jpg',
    'assets/logo/login-image-3.jpeg',
    'assets/logo/login-image-4.webp',
    'assets/logo/login-image-5.webp',
    'assets/logo/login-image-6.webp',
    'assets/logo/login-image-7.webp',
  ];

  @override
  void initState() {
    super.initState();
    _currentImageIndex =
        DateTime.now().millisecondsSinceEpoch % _loginImages.length;
  }

  void _nextImage() {
    if (_isChanging) return;
    _isChanging = true;
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _loginImages.length;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _isChanging = false;
    });
  }

  void _previousImage() {
    if (_isChanging) return;
    _isChanging = true;
    setState(() {
      _currentImageIndex =
          (_currentImageIndex - 1 + _loginImages.length) % _loginImages.length;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _isChanging = false;
    });
  }

  void _goToImage(int index) {
    if (_isChanging || index == _currentImageIndex) return;
    _isChanging = true;
    setState(() {
      _currentImageIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _isChanging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _handleSuccessfulAuth(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: GestureDetector(
            onPanEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 500) {
                _previousImage();
              } else if (details.velocity.pixelsPerSecond.dx < -500) {
                _nextImage();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_loginImages[_currentImageIndex]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.margin),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        _buildWelcomeText(),
                        const SizedBox(height: Constants.margin),
                        _buildSubtitleText(),
                        const SizedBox(height: Constants.margin * 3),
                        _buildLoginButton(),
                        const SizedBox(height: Constants.margin * 2),
                        _buildSkipButton(),
                        const Spacer(),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSuccessfulAuth(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments != null && arguments is Map<String, dynamic>) {
      final returnRoute = arguments['returnRoute'] as String?;
      final returnArguments = arguments['returnArguments'];

      if (returnRoute != null) {
        Navigator.of(context)
            .pushReplacementNamed(returnRoute, arguments: returnArguments);
        return;
      }
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Widget _buildWelcomeText() {
    return Text(
      AppLocalizations.of(context)!.welcomeToOpfan,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitleText() {
    return Text(
      AppLocalizations.of(context)!.loginWelcomeSubtitle,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthSignInRequested());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.purple[600],
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.purple[600]!),
                    ),
                  )
                : const Icon(
                    Icons.login,
                    size: 24,
                  ),
            label: Text(
              isLoading ? AppLocalizations.of(context)!.signingIn : AppLocalizations.of(context)!.signInWithGoogle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      },
      child: Text(
        AppLocalizations.of(context)!.skipForNow,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: List.generate(_loginImages.length, (index) {
            return GestureDetector(
              onTap: () => _goToImage(index),
              child: CircleIndicator(
                isActive: index == _currentImageIndex,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Colors.white,
              ),
            );
          }),
        ),
        const SizedBox(height: Constants.margin),
        Text(
          '${AppLocalizations.of(context)!.version} 1.0.1',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
