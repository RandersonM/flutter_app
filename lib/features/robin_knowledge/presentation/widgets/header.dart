import 'package:flutter/material.dart';
import 'dart:math';

import 'package:opfan/shared/utils/theme.dart';

class RobinKnowledgeHeader extends StatefulWidget {
  const RobinKnowledgeHeader({Key? key}) : super(key: key);

  @override
  State<RobinKnowledgeHeader> createState() => _RobinKnowledgeHeaderState();
}

class _RobinKnowledgeHeaderState extends State<RobinKnowledgeHeader> {
  late String _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectRandomImage();
  }

  void _selectRandomImage() {
    final random = Random();
    final images = [
      'assets/logo/nico-robin-1.gif',
    ];
    _selectedImage = images[random.nextInt(images.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple[350]!.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      width: double.infinity,
      height: 250,
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        _selectedImage,
        fit: BoxFit.cover,
      ),
    );
  }
}
