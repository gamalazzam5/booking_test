import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_appointments/core/services/services_locator.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/widgets/app_drawer_widget.dart';
import 'package:booking_appointments/presentation/widgets/booking_view_body.dart';

/// Route widget for the booking screen. Provides [BookingCubit] (and loads the
/// schedule) for the subtree and delegates layout to [BookingViewBody].
class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return BlocProvider(
      create: (_) => getIt<BookingCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookAppointment),
          centerTitle: true,
        ),
        drawer: const AppDrawerWidget(),
        body: const SafeArea(child: BookingViewBody()),
      ),
    );
  }
}
