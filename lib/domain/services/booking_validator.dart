import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/domain/models/booking_validation_result.dart';

/// All booking rules. Pure Dart and stateless: every method takes the current
/// schedule and returns a result, so the UI and the cubit never re-implement a rule.
///
/// Schedule contract: `slots` is ordered by time and contiguous (each slot starts
/// where the previous one ends). Working hours are the span from the first slot's
/// start to the last slot's end, so no time is hardcoded here.
class BookingValidator {
  const BookingValidator();

  /// Slots that a booking of [duration] starting at [start] would occupy.
  List<TimeSlot> getRequiredSlots(
    List<TimeSlot> slots,
    Duration start,
    BookingDuration duration,
  ) {
    final end = start + duration.length;
    return slots.where((s) => s.start >= start && s.start < end).toList();
  }

  /// True when the whole booking fits between the first slot's start and the
  /// last slot's end.
  bool isWithinWorkingHours(
    List<TimeSlot> slots,
    Duration start,
    BookingDuration duration,
  ) {
    if (slots.isEmpty) return false;
    return start >= slots.first.start &&
        start + duration.length <= slots.last.end;
  }

  /// True when [required] exactly tiles `[start, start + duration)` with no
  /// holes: it begins at [start], ends at the booking end, and every slot
  /// begins where the previous one ends.
  bool areSlotsConsecutive(
    List<TimeSlot> required,
    Duration start,
    BookingDuration duration,
  ) {
    if (required.isEmpty) return false;
    if (required.first.start != start) return false;
    if (required.last.end != start + duration.length) return false;
    for (var i = 1; i < required.length; i++) {
      if (required[i - 1].end != required[i].start) return false;
    }
    return true;
  }

  /// True when any of the [required] slots cannot be booked (booked or unavailable).
  bool hasConflict(List<TimeSlot> required) => required.any((s) => s.isBlocked);

  /// Returns a new schedule with the requested range marked booked.
  /// Does not validate; call [validateBooking] first. Never mutates [slots].
  List<TimeSlot> applyBooking(
    List<TimeSlot> slots,
    Duration start,
    BookingDuration duration,
  ) {
    final end = start + duration.length;
    return List.unmodifiable([
      for (final slot in slots)
        if (slot.start >= start && slot.start < end)
          slot.copyWith(status: SlotStatus.booked)
        else
          slot,
    ]);
  }

  /// X-O-X rule, evaluated on the *resulting* schedule.
  ///
  /// The booking is applied hypothetically, then the schedule is searched for a
  /// free slot with a blocked slot on both sides. It is rejected only if that
  /// gap did not already exist before the booking — a gap the user did not
  /// cause is not this booking's fault.
  bool wouldCreateIsolatedGap(
    List<TimeSlot> slots,
    Duration start,
    BookingDuration duration,
  ) {
    final before = _isolatedSlotStarts(slots);
    final after = _isolatedSlotStarts(applyBooking(slots, start, duration));
    return after.any((slotStart) => !before.contains(slotStart));
  }

  /// Validates a booking and reports the first rule it breaks:
  /// working hours → consecutive slots → conflict → X-O-X gap.
  BookingValidationResult validateBooking(
    List<TimeSlot> slots,
    Duration start,
    BookingDuration duration,
  ) {
    if (!isWithinWorkingHours(slots, start, duration)) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.exceedsWorkingHours,
      );
    }

    final required = getRequiredSlots(slots, start, duration);
    if (!areSlotsConsecutive(required, start, duration)) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.insufficientConsecutiveSlots,
      );
    }

    if (hasConflict(required)) {
      return BookingValidationResult.invalid(_conflictReason(required));
    }

    if (wouldCreateIsolatedGap(slots, start, duration)) {
      return const BookingValidationResult.invalid(
        BookingInvalidReason.createsIsolatedGap,
      );
    }

    return const BookingValidationResult.valid();
  }

  /// Start times from which a booking of [duration] is fully valid. Defined by
  /// [validateBooking], so the two can never disagree.
  List<Duration> getValidStartTimes(
    List<TimeSlot> slots,
    BookingDuration duration,
  ) {
    return [
      for (final slot in slots)
        if (validateBooking(slots, slot.start, duration).isValid) slot.start,
    ];
  }

  /// Most specific reason for a conflicting range. Precedence: the tapped start
  /// slot, then a booked slot later in the range (overlap), then unavailable.
  BookingInvalidReason _conflictReason(List<TimeSlot> required) {
    final first = required.first;
    if (first.status == SlotStatus.booked) {
      return BookingInvalidReason.startSlotBooked;
    }
    if (first.status == SlotStatus.unavailable) {
      return BookingInvalidReason.startSlotUnavailable;
    }
    if (required.any((s) => s.status == SlotStatus.booked)) {
      return BookingInvalidReason.overlapsBooking;
    }
    return BookingInvalidReason.insufficientConsecutiveSlots;
  }

  /// Start times of free slots that have a blocked slot immediately before AND
  /// after. The first and last slot of the day have only one neighbour, so they
  /// are never "between" two blocked slots and are never reported.
  Set<Duration> _isolatedSlotStarts(List<TimeSlot> slots) {
    final isolated = <Duration>{};
    for (var i = 1; i < slots.length - 1; i++) {
      if (slots[i].isAvailable &&
          slots[i - 1].isBlocked &&
          slots[i + 1].isBlocked) {
        isolated.add(slots[i].start);
      }
    }
    return isolated;
  }
}
