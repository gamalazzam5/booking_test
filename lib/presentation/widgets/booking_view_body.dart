import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/extensions/snack_bar_extensions.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';
import 'package:booking_appointments/presentation/utils/booking_labels.dart';
import 'package:booking_appointments/presentation/widgets/booking_action_bar_widget.dart';
import 'package:booking_appointments/presentation/widgets/booking_header_widget.dart';
import 'package:booking_appointments/presentation/widgets/booking_summary_widget.dart';
import 'package:booking_appointments/presentation/widgets/duration_selector_widget.dart';
import 'package:booking_appointments/presentation/widgets/slot_legend_widget.dart';
import 'package:booking_appointments/presentation/widgets/time_slot_grid_widget.dart';
import 'package:booking_appointments/presentation/widgets/validation_error_widget.dart';

/// Layout of the booking screen plus its one-off feedback (snackbars).
///
/// Only the loading → loaded switch is decided here; every section below
/// subscribes to the cubit on its own, so a state change rebuilds just the
/// widgets that show it.
class BookingViewBody extends StatelessWidget {
  const BookingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listenWhen: _shouldGiveFeedback,
      listener: (context, state) {
        if (state is! BookingLoaded) return;
        final l10n = S.of(context);
        if (state.confirmedBooking != null) {
          context.showSuccessSnackBar(l10n.bookingSuccessful);
        } else if (state.invalidReason != null) {
          context.showErrorSnackBar(state.invalidReason!.message(l10n));
        }
      },
      child: BlocBuilder<BookingCubit, BookingState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          if (state is! BookingLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return const _BookingContent();
        },
      ),
    );
  }

  /// Snackbar only for something new: a fresh confirmation, or a selection whose
  /// validation just changed to invalid — not on every unrelated rebuild.
  static bool _shouldGiveFeedback(BookingState previous, BookingState current) {
    if (current is! BookingLoaded) return false;
    final before = previous is BookingLoaded ? previous : null;

    final newConfirmation = current.confirmedBooking != null &&
        before?.confirmedBooking != current.confirmedBooking;
    final newError =
        current.invalidReason != null && before?.selection != current.selection;
    return newConfirmation || newError;
  }
}

class _BookingContent extends StatelessWidget {
  const _BookingContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BookingHeaderWidget(),
          SizedBox(height: 24.h),
          const DurationSelectorWidget(),
          SizedBox(height: 20.h),
          const TimeSlotGridWidget(),
          SizedBox(height: 16.h),
          const SlotLegendWidget(),
          SizedBox(height: 20.h),
          const BookingSummaryWidget(),
          const ValidationErrorWidget(),
          SizedBox(height: 24.h),
          const BookingActionBarWidget(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
