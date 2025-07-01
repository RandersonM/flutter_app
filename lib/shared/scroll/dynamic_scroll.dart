// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DynamicScroll {
  Future<void> scrollToSelectedContent({
    required GlobalKey expansionTileKey,
  }) async {
    final context = expansionTileKey.currentContext;
    if (context == null) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ctx = expansionTileKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }
}
