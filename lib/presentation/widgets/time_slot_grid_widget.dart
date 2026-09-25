import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';
import 'package:booking_appointments/presentation/widgets/slot_cell_widget.dart';

/// The working day as a 3-column grid of slots.
class TimeSlotGridWidget extends StatelessWidget {
  const TimeSlotGridWidget({super.key});

  /// Minimum comfortable touch target (Material guideline), independent of
  /// screen scaling so it holds on small phones.
  static const double _cellHeight = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.timeSlots,
          style: AppTextStyles.semiBold18.copyWith(color: colorScheme.onSurface),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.selectStartTimeHint,
          style: AppTextStyles.regular12.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is! BookingLoaded) return const SizedBox.shrink();
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                mainAxisExtent: _cellHeight,
              ),
              itemCount: state.slots.length,
              itemBuilder: (context, index) {
                final slot = state.slots[index];
                final selectionState = !state.isInSelection(slot)
                    ? SlotSelectionState.none
                    : (state.canConfirm
                        ? SlotSelectionState.valid
                        : SlotSelectionState.invalid);
                return SlotCellWidget(
                  slot: slot,
                  isValidStart: state.validStartTimes.contains(slot.start),
                  selectionState: selectionState,
                  onTap: () =>
                      context.read<BookingCubit>().selectStartTime(slot.start),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
