import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Markdown configs for text the app did not write (AI answers, which may echo
/// web search results). The package default loads any remote image on render
/// and launches any link scheme, which turns prompt injection into data
/// exfiltration through an image URL or a `sms:`/`tel:` link.
List<WidgetConfig> untrustedMarkdownConfigs(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return [
    ImgConfig(builder: (url, attributes) => const SizedBox.shrink()),
    LinkConfig(
      style: TextStyle(
        color: colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      onTap: (url) => confirmAndOpenExternalLink(context, url),
    ),
  ];
}

/// Only absolute `https` links with a host may leave the app.
Uri? trustedExternalUri(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
  return uri;
}

Future<void> confirmAndOpenExternalLink(
  BuildContext context,
  String raw,
) async {
  final uri = trustedExternalUri(raw);
  if (uri == null) return;

  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.openExternalLinkTitle),
      content: Text(l10n.openExternalLinkMessage(uri.toString())),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.openExternalLinkAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
