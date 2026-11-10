import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/TextStyles.dart';
import '../../../../utils/colors/app_colors.dart';

/// Compact single-select row: label on the left, tick-style options on the
/// right. [selected] must read an observable so the internal Obx rebuilds.
class TickSelectRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String Function() selected;
  final void Function(String) onSelect;
  final bool requiredMark;
  final TextStyle? labelStyle;

  const TickSelectRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.requiredMark = false,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                requiredMark ? "$label *" : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle ?? TextStyles.registerFieldLabel,
              ),
            ),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              child: Obx(() {
                final String current = selected();
                return Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: options
                      .map((o) => _option(o, current == o))
                      .toList(),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _option(String option, bool isSelected) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: "$label: $option",
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelect(option),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.sizeExtraSmall,
            vertical: ScreenConstant.sizeSmall,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected ? CustomColor.colorBE185D : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? CustomColor.colorBE185D
                          : CustomColor.color94A3B8,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: CustomColor.colorWhite,
                        )
                      : null,
                ),
                SizedBox(width: ScreenConstant.sizeExtraSmall),
                Text(
                  option,
                  style: TextStyles.policiesPillText.copyWith(
                    color: isSelected
                        ? CustomColor.colorBE185D
                        : CustomColor.color334155,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
