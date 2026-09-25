import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet for [text].
///
/// iPad presents the sheet as a popover and needs an anchor rectangle inside
/// the source view. Without one, share_plus refuses to present and the button
/// appears to do nothing, so an anchor is always supplied here.
Future<void> shareText(BuildContext context, String? text) async {
  if (text == null || text.isEmpty) return;

  try {
    await Share.share(text, sharePositionOrigin: _anchorRect(context));
  } catch (e) {
    // Sharing is best effort - never let it break the screen.
  }
}

Rect _anchorRect(BuildContext context) {
  final box = context.findRenderObject();
  if (box is RenderBox && box.hasSize) {
    return box.localToGlobal(Offset.zero) & box.size;
  }

  // Fall back to a small rectangle in the middle of the screen.
  final size = MediaQuery.of(context).size;
  return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2), width: 1, height: 1);
}
