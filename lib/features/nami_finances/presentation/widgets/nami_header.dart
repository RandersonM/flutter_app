import 'package:flutter/material.dart';
import 'dart:math';

class NamiHeader extends StatefulWidget {
  const NamiHeader({Key? key}) : super(key: key);

  @override
  State<NamiHeader> createState() => _NamiHeaderState();
}

class _NamiHeaderState extends State<NamiHeader> {
  late String _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectRandomImage();
  }

  void _selectRandomImage() {
    final random = Random();
    final images = [
      'assets/logo/nami-one-piece-1.gif',
      'assets/logo/nami-one-piece-2.gif',
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
            color: Colors.orange.withValues(alpha: 0.2),
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