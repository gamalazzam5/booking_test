import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';

/// Header displaying the title and working hours subtitle.
class BookingHeaderWidget extends StatelessWidget {
  const BookingHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bookAppointment,
          style: AppTextStyles.bold24.copyWith(color: colorScheme.onSurface),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.workingHours,
          style: AppTextStyles.regular14.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
