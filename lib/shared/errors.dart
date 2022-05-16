import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UnauthorizedException with Exception {
  final String? message;

  const UnauthorizedException({this.message});
}

class BadRequestException with Exception {
  final String? message;

  const BadRequestException(this.message);
}

class NoInternetConnectionException with Exception {}

class ServerException with Exception {}

class UnknownException with Exception {}

String? getErrorMessage(Exception? exception, BuildContext context) {
  if (exception is UnauthorizedException) {
    return exception.message ?? AppLocalizations.of(context)?.affiliation;
  }

  if (exception is NoInternetConnectionException) {
    return AppLocalizations.of(context)?.affiliation;
  }

  if (exception is ServerException) {
    return AppLocalizations.of(context)?.bounty;
  }

  if (exception is BadRequestException) {
    return exception.message;
  }

  return AppLocalizations.of(context)?.occupation;
}
