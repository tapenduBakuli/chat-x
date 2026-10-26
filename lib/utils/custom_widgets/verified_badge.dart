import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../TextStyles.dart';
import '../colors/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final String text;

  const VerifiedBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: CustomColor.colorE9D5FF.withOpacity(0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: CustomColor.colorEC4899,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyles.landingSubTitleBadge,
          ),
        ],
      ),
    );
  }
}