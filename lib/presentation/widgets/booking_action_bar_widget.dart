import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';

/// Reset (always available) and Confirm (enabled only for a valid selection).
class BookingActionBarWidget extends StatelessWidget {
  const BookingActionBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final cubit = context.read<BookingCubit>();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // A snackbar about the selection being cleared would be stale.
              ScaffoldMessenger.of(context).clearSnackBars();
              cubit.reset();
            },
            child: Text(l10n.reset),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: BlocSelector<BookingCubit, BookingState, bool>(
            selector: (state) => state is BookingLoaded && state.canConfirm,
            builder: (context, canConfirm) {
              return ElevatedButton(
                onPressed: canConfirm ? cubit.confirmBooking : null,
                child: Text(l10n.confirmBooking),
              );
            },
          ),
        ),
      ],
    );
  }
}
