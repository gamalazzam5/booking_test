import 'package:equatable/equatable.dart';

/// Why a booking attempt is invalid. The domain returns the reason; the
/// presentation layer turns it into a localized message.
enum BookingInvalidReason {
  /// The booking would end after the last slot of the working day (6:00 PM),
  /// or start before the first slot.
  exceedsWorkingHours,

  /// The slot the user picked as the start is already booked.
  startSlotBooked,

  /// The slot the user picked as the start is unavailable.
  startSlotUnavailable,

  /// A later slot of the requested range is already booked.
  overlapsBooking,

  /// The range cannot be covered by consecutive available slots (an unavailable
  /// slot in the range, or the start is not a slot boundary).
  insufficientConsecutiveSlots,

  /// The booking would leave a lone free 30-minute slot between two blocked
  /// slots (X-O-X).
  createsIsolatedGap,
}

/// Outcome of validating a booking: either valid, or invalid with a [reason].
class BookingValidationResult extends Equatable {
  const BookingValidationResult.valid()
      : isValid = true,
        reason = null;

  const BookingValidationResult.invalid(BookingInvalidReason this.reason)
      : isValid = false;

  final bool isValid;

  /// Non-null exactly when [isValid] is false.
  final BookingInvalidReason? reason;

  @override
  List<Object?> get props => [isValid, reason];
}
