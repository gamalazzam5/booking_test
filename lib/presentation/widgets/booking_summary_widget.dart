import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';
import 'package:booking_appointments/presentation/utils/booking_labels.dart';
import 'package:booking_appointments/presentation/utils/time_format.dart';
import 'package:booking_appointments/presentation/widgets/summary_row_widget.dart';

/// Card showing the current selection: start, end, chosen duration and total
/// length. Shows a placeholder until a start time is picked. The end time is
/// shown even for a rejected selection (e.g. 6:30 PM) so the user can see why.
class BookingSummaryWidget extends StatelessWidget {
  const BookingSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bookingSummary,
              style: AppTextStyles.semiBold18.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                if (state is! BookingLoaded) return const SizedBox.shrink();
                final start = state.selectedStart;
                final end = state.selectedEnd;
                if (start == null || end == null) {
                  return Text(
                    l10n.noSelectionYet,
                    style: AppTextStyles.regular14.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  children: [
                    SummaryRowWidget(
                      label: l10n.startLabel,
                      value: start.formatTimeOfDay(context),
                    ),
                    SizedBox(height: 6.h),
                    SummaryRowWidget(
                      label: l10n.endLabel,
                      value: end.formatTimeOfDay(context),
                    ),
                    SizedBox(height: 6.h),
                    SummaryRowWidget(
                      label: l10n.durationLabel,
                      value: state.selectedDuration.label(l10n),
                    ),
                    SizedBox(height: 6.h),
                    SummaryRowWidget(
                      label: l10n.totalLabel,
                      value: (end - start).formatSpan(l10n),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
