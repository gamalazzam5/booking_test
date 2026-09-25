// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Appointment Booking';

  @override
  String get bookAppointment => 'Book an Appointment';

  @override
  String get workingHours => 'Working hours: 9:00 AM – 6:00 PM';

  @override
  String get selectDuration => 'Select Duration';

  @override
  String get duration30Min => '30 min';

  @override
  String get duration1Hour => '1 hr';

  @override
  String get duration1Half => '1.5 hr';

  @override
  String get duration2Hours => '2 hr';

  @override
  String get timeSlots => 'Time Slots';

  @override
  String get legend => 'Legend';

  @override
  String get available => 'Available';

  @override
  String get booked => 'Booked';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get selected => 'Selected';

  @override
  String get bookingSummary => 'Booking Summary';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get durationLabel => 'Duration';

  @override
  String get noSelectionYet => 'No time slot selected yet.';

  @override
  String get reset => 'Reset';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get bookingSuccessful =>
      'Your appointment has been booked successfully!';

  @override
  String get selectStartTimeHint =>
      'Tap a slot to choose a start time. Outlined slots cannot start a booking of this length.';

  @override
  String get invalid => 'Invalid';

  @override
  String get cannotStartHere => 'Can\'t start here';

  @override
  String slotSemantics(String time, String status) {
    return '$time, $status';
  }

  @override
  String get totalLabel => 'Total';

  @override
  String durationHours(int count) {
    return '$count hr';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String get errorExceedsWorkingHours =>
      'The selected duration extends beyond 6:00 PM.';

  @override
  String get errorStartSlotBooked => 'This time slot is already booked.';

  @override
  String get errorStartSlotUnavailable => 'This time slot is unavailable.';

  @override
  String get errorOverlapsBooking =>
      'This time overlaps with a booked appointment.';

  @override
  String get errorInsufficientConsecutiveSlots =>
      'The selected time does not contain enough consecutive available slots.';

  @override
  String get errorCreatesIsolatedGap =>
      'This booking would leave an unusable 30-minute gap.';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get appSubtitle => 'Serv5 Booking System';

  @override
  String get copyright => '© 2026 Serv5. All rights reserved.';
}
