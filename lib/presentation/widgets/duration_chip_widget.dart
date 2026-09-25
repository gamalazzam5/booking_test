import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';

/// One selectable duration. Built on [ChoiceChip] so it gets a 48 dp touch
/// target, ripple, keyboard focus and "selected" semantics.
class DurationChipWidget extends StatelessWidget {
  const DurationChipWidget({
    super.key,
    required this.duration,
    required this.isSelected,
    required this.label,
  });

  final BookingDuration duration;
  final bool isSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      selectedColor: AppColors.primary,
      backgroundColor:
          isDark ? const Color(0xFF1E2340) : AppColors.surfaceVariant,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.outline,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: AppTextStyles.medium14.copyWith(
        color: isSelected
            ? AppColors.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onSelected: (_) => context.read<BookingCubit>().selectDuration(duration),
    );
  }
}
