import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/utils/slot_style.dart';

/// One swatch in [SlotLegendWidget]. Uses the same [SlotStyle] as the grid cells
/// so the legend can never drift from what the slots actually look like.
class LegendItemWidget extends StatelessWidget {
  const LegendItemWidget({super.key, required this.visual});

  final SlotVisual visual;

  @override
  Widget build(BuildContext context) {
    final style = SlotStyle.of(visual, context);
    final label = SlotStyle.labelOf(visual, S.of(context));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: style.borderColor, width: style.borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (style.icon != null) ...[
            Icon(style.icon, size: 14.r, color: style.foreground),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: AppTextStyles.regular12.copyWith(
              color: style.foreground,
              decoration:
                  style.strikeThrough ? TextDecoration.lineThrough : null,
              decorationColor: style.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
