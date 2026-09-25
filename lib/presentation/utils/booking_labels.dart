import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/domain/models/booking_validation_result.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';

/// Localized names for [BookingDuration] chips and summary rows.
extension BookingDurationLabel on BookingDuration {
  String label(S l10n) => switch (this) {
        BookingDuration.thirtyMinutes => l10n.duration30Min,
        BookingDuration.oneHour => l10n.duration1Hour,
        BookingDuration.oneHalfHour => l10n.duration1Half,
        BookingDuration.twoHours => l10n.duration2Hours,
      };
}

/// The one place a validation reason becomes user-facing text, shared by the
/// inline banner and the snackbar.
extension BookingInvalidReasonMessage on BookingInvalidReason {
  String message(S l10n) => switch (this) {
        BookingInvalidReason.exceedsWorkingHours =>
          l10n.errorExceedsWorkingHours,
        BookingInvalidReason.startSlotBooked => l10n.errorStartSlotBooked,
        BookingInvalidReason.startSlotUnavailable =>
          l10n.errorStartSlotUnavailable,
        BookingInvalidReason.overlapsBooking => l10n.errorOverlapsBooking,
        BookingInvalidReason.insufficientConsecutiveSlots =>
          l10n.errorInsufficientConsecutiveSlots,
        BookingInvalidReason.createsIsolatedGap => l10n.errorCreatesIsolatedGap,
      };
}
