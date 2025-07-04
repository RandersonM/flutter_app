// Developed by Randerson Mayllon
// Copyright © 2022.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DynamicScroll {
  static final Map<GlobalKey, double> _savedPositions = {};
  Future<void> handleExpansionScroll({
    required GlobalKey expansionTileKey,
    required bool isExpanded,
  }) async {
    final context = expansionTileKey.currentContext;
    if (context == null) {
      return;
    }

    final ScrollController? scrollController = _findScrollController(context);
    if (scrollController == null) {
      return;
    }

    if (isExpanded) {
      _savedPositions[expansionTileKey] = scrollController.offset;
      debugPrint('DynamicScroll: Saved position=${scrollController.offset}');

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _centerExpansionTile(expansionTileKey, scrollController);
      });
    } else {
      final savedPosition = _savedPositions[expansionTileKey];
      if (savedPosition != null) {
        debugPrint('DynamicScroll: Restoring to position=$savedPosition');
        await scrollController.animateTo(
          savedPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _savedPositions.remove(expansionTileKey);
      }
    }
  }

  ScrollController? _findScrollController(BuildContext context) {
    final scrollableState = Scrollable.of(context);
    if (scrollableState.widget.controller != null) {
      return scrollableState.widget.controller;
    }

    CustomScrollView? customScrollView;
    context.visitAncestorElements((element) {
      if (element.widget is CustomScrollView) {
        customScrollView = element.widget as CustomScrollView;
        return false;
      }
      return true;
    });

    return customScrollView?.controller;
  }

  Future<void> _centerExpansionTile(
      GlobalKey expansionTileKey, ScrollController scrollController) async {
    final context = expansionTileKey.currentContext;
    if (context == null) {
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final Offset globalPosition = renderBox.localToGlobal(Offset.zero);

      final double tileHeight = renderBox.size.height;

      const double appBarHeight = 56.0;
      const double bottomNavHeight = 80.0;

      final double availableHeight =
          screenHeight - appBarHeight - statusBarHeight - bottomNavHeight;

      final double targetGlobalY = statusBarHeight +
          appBarHeight +
          (availableHeight / 2) -
          (tileHeight / 2);
      final double currentGlobalY = globalPosition.dy;
      final double scrollDelta = currentGlobalY - targetGlobalY;
      final double targetPosition = scrollController.offset + scrollDelta;

      final double maxScrollExtent = scrollController.position.maxScrollExtent;
      final double finalPosition = targetPosition.clamp(0.0, maxScrollExtent);

      await scrollController.animateTo(
        finalPosition,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint('DynamicScroll: Error in _centerExpansionTile: $e');
    }
  }

  static void clearSavedPositions() {
    _savedPositions.clear();
  }
}
