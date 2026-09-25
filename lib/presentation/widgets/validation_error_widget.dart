import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/domain/models/booking_validation_result.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';
import 'package:booking_appointments/presentation/utils/booking_labels.dart';

/// Inline banner that explains why the current selection is invalid.
/// Renders nothing while the selection is valid or empty.
class ValidationErrorWidget extends StatelessWidget {
  const ValidationErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BookingCubit, BookingState, BookingInvalidReason?>(
      selector: (state) => state is BookingLoaded ? state.invalidReason : null,
      builder: (context, reason) {
        if (reason == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: _ErrorBanner(message: reason.message(S.of(context))),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;

    // liveRegion: screen readers announce the message as soon as it appears.
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: error.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: error, size: 18.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.regular14.copyWith(color: error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
