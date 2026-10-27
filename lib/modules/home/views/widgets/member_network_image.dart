import 'package:flutter/material.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/colors/app_colors.dart';

/// Shared remote-photo widget used by the grid cards, deck card, and detail
/// carousel. It always covers its box and never shows a broken-image glyph:
/// while loading it shows a neutral box with a rose spinner, and on error it
/// falls back to a dark gradient with a white person icon.
class MemberNetworkImage extends StatelessWidget {
  final String url;

  const MemberNetworkImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _errorFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: CustomColor.colorF1F5F9,
          alignment: Alignment.center,
          child: SizedBox(
            width: ScreenConstant.smallIconSize,
            height: ScreenConstant.smallIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                CustomColor.colorBE185D,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _errorFallback(),
    );
  }

  Widget _errorFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColor.color0F172A,
            CustomColor.color334155,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: ScreenConstant.texIconSize,
        color: CustomColor.colorWhite.withOpacity(0.8),
      ),
    );
  }
}
