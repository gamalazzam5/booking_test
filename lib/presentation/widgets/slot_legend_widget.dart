import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/utils/slot_style.dart';
import 'package:booking_appointments/presentation/widgets/legend_item_widget.dart';

/// Key to every look a slot can have.
class SlotLegendWidget extends StatelessWidget {
  const SlotLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.legend,
          style: AppTextStyles.semiBold18.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            for (final visual in SlotVisual.values)
              LegendItemWidget(visual: visual),
          ],
        ),
      ],
    );
  }
}
