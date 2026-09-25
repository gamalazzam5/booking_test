import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';
import 'package:booking_appointments/presentation/utils/booking_labels.dart';
import 'package:booking_appointments/presentation/widgets/duration_chip_widget.dart';

/// The duration options. Chips wrap onto a second line on narrow screens rather
/// than scrolling, so every option is always visible.
class DurationSelectorWidget extends StatelessWidget {
  const DurationSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectDuration,
          style: AppTextStyles.semiBold18.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        BlocSelector<BookingCubit, BookingState, BookingDuration>(
          selector: (state) => state is BookingLoaded
              ? state.selectedDuration
              : BookingCubit.defaultDuration,
          builder: (context, selected) {
            return Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                for (final duration in BookingDuration.values)
                  DurationChipWidget(
                    duration: duration,
                    isSelected: duration == selected,
                    label: duration.label(l10n),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
