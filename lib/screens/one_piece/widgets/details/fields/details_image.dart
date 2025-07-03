// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';

class DetailsImage extends StatefulWidget {
  const DetailsImage({Key? key, required this.image}) : super(key: key);

  final String image;

  @override
  State<DetailsImage> createState() => _DetailsImageState();
}

class _DetailsImageState extends State<DetailsImage> {
  bool _imageLoadError = false;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        leading: const SizedBox.shrink(),
        forceElevated: true,
        backgroundColor: Colors.white,
        expandedHeight: MediaQuery.of(context).size.height / 3,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            margin: const EdgeInsets.all(Constants.margin),
            decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(Constants.margin * 3)),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.all(Radius.circular(Constants.margin * 3)),
              child: _imageLoadError
                  ? _buildPlaceholder()
                  : Image.network(
                      widget.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _imageLoadError = true;
                            });
                          }
                        });
                        return _buildPlaceholder();
                      },
                    ),
            ),
          ),
        ),
      );

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.imageUnavailable,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
