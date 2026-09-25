import 'package:flutter_test/flutter_test.dart';
import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/data/repositories/booking_repository_impl.dart';
import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/domain/models/booking_validation_result.dart';
import 'package:booking_appointments/domain/services/booking_validator.dart';

import '../../helpers/schedule_builder.dart';

void main() {
  const validator = BookingValidator();

  /// Validates and returns the invalid reason, or null when the booking is valid.
  BookingInvalidReason? reasonFor(
    String pattern,
    Duration start,
    BookingDuration duration,
  ) {
    return validator
        .validateBooking(buildSchedule(pattern), start, duration)
        .reason;
  }

  group('valid bookings on a free day', () {
    final slots = buildSchedule(freeDay);

    test('30 minutes is valid', () {
      final result = validator.validateBooking(
        slots,
        at(11),
        BookingDuration.thirtyMinutes,
      );
      expect(result.isValid, isTrue);
    });

    test('1 hour is valid', () {
      final result = validator.validateBooking(
        slots,
        at(11),
        BookingDuration.oneHour,
      );
      expect(result.isValid, isTrue);
    });

    test('1.5 hours is valid', () {
      final result = validator.validateBooking(
        slots,
        at(11),
        BookingDuration.oneHalfHour,
      );
      expect(result.isValid, isTrue);
    });

    test('2 hours is valid', () {
      final result = validator.validateBooking(
        slots,
        at(11),
        BookingDuration.twoHours,
      );
      expect(result.isValid, isTrue);
    });
  });

  group('getRequiredSlots', () {
    final slots = buildSchedule(freeDay);

    test('returns one slot per 30 minutes starting at the start time', () {
      final required = validator.getRequiredSlots(
        slots,
        at(10),
        BookingDuration.oneHalfHour,
      );
      expect(required.map((s) => s.start), [at(10), at(10, 30), at(11)]);
    });

    test('returns fewer slots than needed when the range runs past the day', () {
      final required = validator.getRequiredSlots(
        slots,
        at(17, 30),
        BookingDuration.oneHour,
      );
      expect(required.map((s) => s.start), [at(17, 30)]);
    });
  });

  group('booked and unavailable slots', () {
    test('rejects a start slot that is booked', () {
      expect(
        reasonFor('..B.......', at(10), BookingDuration.thirtyMinutes),
        BookingInvalidReason.startSlotBooked,
      );
    });

    test('rejects a start slot that is unavailable', () {
      expect(
        reasonFor('..U.......', at(10), BookingDuration.thirtyMinutes),
        BookingInvalidReason.startSlotUnavailable,
      );
    });

    test('rejects 1.5 h at 09:00 when 10:00 is booked (brief §2.2 example)', () {
      expect(
        reasonFor('..B.......', at(9), BookingDuration.oneHalfHour),
        BookingInvalidReason.overlapsBooking,
      );
    });

    test('rejects a range whose last slot is booked', () {
      expect(
        reasonFor('...B......', at(9), BookingDuration.twoHours),
        BookingInvalidReason.overlapsBooking,
      );
    });

    test('rejects a range that overlaps an unavailable slot as not enough consecutive slots', () {
      expect(
        reasonFor('..U.......', at(9), BookingDuration.oneHalfHour),
        BookingInvalidReason.insufficientConsecutiveSlots,
      );
    });

    test('reports overlap with a booking before an unavailable slot in the same range', () {
      expect(
        reasonFor('.BU.......', at(9), BookingDuration.oneHalfHour),
        BookingInvalidReason.overlapsBooking,
      );
    });

    test('rejects a range crossing several consecutive blocked slots', () {
      expect(
        reasonFor('..BUUB....', at(9), BookingDuration.twoHours),
        BookingInvalidReason.overlapsBooking,
      );
    });

    test('accepts a range that ends right before a booked slot', () {
      // 09:00–10:00 fills both free slots; 10:00 is booked. Nothing is stranded.
      expect(
        reasonFor('..B.......', at(9), BookingDuration.oneHour),
        isNull,
      );
    });

    test('rejects a start that is not on a slot boundary', () {
      expect(
        reasonFor(freeDay, at(9, 15), BookingDuration.thirtyMinutes),
        BookingInvalidReason.insufficientConsecutiveSlots,
      );
    });
  });

  group('areSlotsConsecutive', () {
    test('is true for adjacent slots covering the whole range', () {
      final slots = buildSchedule(freeDay);
      final required = validator.getRequiredSlots(
        slots,
        at(9),
        BookingDuration.oneHour,
      );
      expect(
        validator.areSlotsConsecutive(required, at(9), BookingDuration.oneHour),
        isTrue,
      );
    });

    test('is false when a slot is missing from the middle of the range', () {
      final slots = buildSchedule(freeDay);
      final withHole = [slots[0], slots[2]]; // 09:00 and 10:00, no 09:30
      expect(
        validator.areSlotsConsecutive(
          withHole,
          at(9),
          BookingDuration.oneHalfHour,
        ),
        isFalse,
      );
    });

    test('is false for an empty range', () {
      expect(
        validator.areSlotsConsecutive(
          const [],
          at(9),
          BookingDuration.thirtyMinutes,
        ),
        isFalse,
      );
    });
  });

  group('working-hours boundary (6 PM)', () {
    test('30 min at 17:30 ends exactly at 18:00 and is valid', () {
      expect(reasonFor(freeDay, at(17, 30), BookingDuration.thirtyMinutes), isNull);
    });

    test('1 hour at 17:00 ends exactly at 18:00 and is valid', () {
      expect(reasonFor(freeDay, at(17), BookingDuration.oneHour), isNull);
    });

    test('1.5 hours at 16:30 ends exactly at 18:00 and is valid', () {
      expect(reasonFor(freeDay, at(16, 30), BookingDuration.oneHalfHour), isNull);
    });

    test('2 hours at 16:00 ends exactly at 18:00 and is valid', () {
      expect(reasonFor(freeDay, at(16), BookingDuration.twoHours), isNull);
    });

    test('1 hour at 17:30 would end at 18:30 and is rejected', () {
      expect(
        reasonFor(freeDay, at(17, 30), BookingDuration.oneHour),
        BookingInvalidReason.exceedsWorkingHours,
      );
    });

    test('2 hours at 16:30 would end at 18:30 and is rejected', () {
      expect(
        reasonFor(freeDay, at(16, 30), BookingDuration.twoHours),
        BookingInvalidReason.exceedsWorkingHours,
      );
    });

    test('a start after the last slot is rejected', () {
      expect(
        reasonFor(freeDay, at(18), BookingDuration.thirtyMinutes),
        BookingInvalidReason.exceedsWorkingHours,
      );
    });

    test('a start before the first slot is rejected', () {
      expect(
        reasonFor(freeDay, at(8, 30), BookingDuration.thirtyMinutes),
        BookingInvalidReason.exceedsWorkingHours,
      );
    });

    test('an empty schedule rejects every booking', () {
      expect(
        validator
            .validateBooking(const [], at(9), BookingDuration.thirtyMinutes)
            .reason,
        BookingInvalidReason.exceedsWorkingHours,
      );
    });
  });

  group('X-O-X rule', () {
    test('rejects booking the first free slot of X O O X (leaves X X O X)', () {
      expect(
        reasonFor('.B..B.', at(10), BookingDuration.thirtyMinutes),
        BookingInvalidReason.createsIsolatedGap,
      );
    });

    test('rejects booking the second free slot of X O O X (leaves X O X X)', () {
      expect(
        reasonFor('.B..B.', at(10, 30), BookingDuration.thirtyMinutes),
        BookingInvalidReason.createsIsolatedGap,
      );
    });

    test('accepts booking both free slots of X O O X (leaves X X X X)', () {
      expect(reasonFor('.B..B.', at(10), BookingDuration.oneHour), isNull);
    });

    test('rejects a longer booking that strands one free slot', () {
      // B . . . B → booking the first two leaves the third between two blocked slots.
      expect(
        reasonFor('.B...B.', at(10), BookingDuration.oneHour),
        BookingInvalidReason.createsIsolatedGap,
      );
    });

    test('accepts a longer booking that leaves two free slots together', () {
      // B . . . . B → booking the first two leaves two free slots (a usable hour).
      expect(reasonFor('.B....B.', at(10), BookingDuration.oneHour), isNull);
    });

    test('treats an unavailable slot on the left as blocked', () {
      // U . . B → booking 10:30 strands 10:00 between U (09:30) and the new booking.
      expect(
        reasonFor('.U..B.', at(10, 30), BookingDuration.thirtyMinutes),
        BookingInvalidReason.createsIsolatedGap,
      );
    });

    test('treats an unavailable slot on the right as blocked', () {
      // B . . U → booking 10:00 strands 10:30 between the new booking and U (11:00).
      expect(
        reasonFor('.B..U.', at(10), BookingDuration.thirtyMinutes),
        BookingInvalidReason.createsIsolatedGap,
      );
    });

    test('handles runs of several blocked slots on both sides', () {
      // BBB . . BB → booking the first free slot strands the second.
      expect(
        reasonFor('.BBB..BB.', at(11, 0), BookingDuration.thirtyMinutes),
        BookingInvalidReason.createsIsolatedGap,
      );
    });

    test('is judged on the resulting schedule, not only the chosen slots', () {
      // Every chosen slot is free and in range, yet the booking is still rejected.
      final slots = buildSchedule('.B..B.');
      final required = validator.getRequiredSlots(
        slots,
        at(10),
        BookingDuration.thirtyMinutes,
      );
      expect(validator.hasConflict(required), isFalse);
      expect(
        validator.wouldCreateIsolatedGap(
          slots,
          at(10),
          BookingDuration.thirtyMinutes,
        ),
        isTrue,
      );
    });

    test('a booking that fills an existing isolated slot is accepted', () {
      // B . B — the lone free slot is filled, nothing new is stranded.
      expect(reasonFor('.B.B....', at(10), BookingDuration.thirtyMinutes), isNull);
    });

    test('an isolated slot that already existed does not block an unrelated booking', () {
      // The lone slot at 09:30 (between two booked slots) exists before the user
      // does anything. Booking 12:00 must not be blamed for it.
      expect(
        reasonFor('B.B.......', at(12), BookingDuration.thirtyMinutes),
        isNull,
      );
    });

    test('a free slot at the very start or end of the day is not X-O-X', () {
      // Booking 09:30 leaves 09:00 free at the start of the day (one neighbour).
      expect(reasonFor('..B', at(9, 30), BookingDuration.thirtyMinutes), isNull);
      // Booking 09:30 leaves 10:00 free at the end of the day (one neighbour).
      expect(reasonFor('B..', at(9, 30), BookingDuration.thirtyMinutes), isNull);
    });
  });

  group('applyBooking', () {
    test('marks exactly the requested slots as booked', () {
      final slots = buildSchedule(freeDay);
      final result = validator.applyBooking(slots, at(10), BookingDuration.oneHour);
      final booked = result.where((s) => s.status == SlotStatus.booked);
      expect(booked.map((s) => s.start), [at(10), at(10, 30)]);
    });

    test('does not mutate the original schedule', () {
      final slots = buildSchedule(freeDay);
      validator.applyBooking(slots, at(10), BookingDuration.oneHour);
      expect(slots.every((s) => s.isAvailable), isTrue);
    });
  });

  group('getValidStartTimes', () {
    test('excludes starts that overlap a booking or cross 6 PM', () {
      // Free slots 09:00–10:00 then booked 10:00–11:00, rest free; 1 hour.
      final slots = buildSchedule('..BB..........');
      final valid = validator.getValidStartTimes(slots, BookingDuration.oneHour);
      expect(valid, isNot(contains(at(9, 30)))); // would overlap 10:00
      expect(valid, isNot(contains(at(10)))); // booked
      expect(valid, contains(at(9))); // 09:00–10:00 fits exactly
      expect(valid, contains(at(11))); // first slot after the booking
      expect(valid, isNot(contains(at(15, 30)))); // would end past this short schedule
    });

    test('changes with the selected duration', () {
      final slots = buildSchedule(freeDay);
      final thirty = validator.getValidStartTimes(slots, BookingDuration.thirtyMinutes);
      final twoHours = validator.getValidStartTimes(slots, BookingDuration.twoHours);
      expect(thirty, hasLength(18));
      expect(twoHours.last, at(16)); // 16:00 + 2 h = 18:00
      expect(twoHours, hasLength(15));
    });

    test('never lists a start that validateBooking rejects', () {
      final slots = const BookingRepositoryImpl().getSlots();
      for (final duration in BookingDuration.values) {
        final valid = validator.getValidStartTimes(slots, duration);
        for (final slot in slots) {
          expect(
            valid.contains(slot.start),
            validator.validateBooking(slots, slot.start, duration).isValid,
            reason: '${slot.start} for $duration',
          );
        }
      }
    });

    test('lists the expected 30-minute starts on the seed schedule', () {
      final slots = const BookingRepositoryImpl().getSlots();
      final valid = validator.getValidStartTimes(slots, BookingDuration.thirtyMinutes);
      expect(valid, [
        at(9, 30), // leaves 09:00 at the edge of the day: allowed
        at(11), //   next to the booking, nothing stranded
        at(12), //   11:00 / 11:30 stay free together
        at(13), //   12:30 stays free next to 12:00; 13:30 is unavailable
        at(15, 30),
        at(16, 30),
        at(17),
        at(17, 30),
      ]);
    });

    test('rejects seed starts that would strand a slot', () {
      final slots = const BookingRepositoryImpl().getSlots();
      final valid = validator.getValidStartTimes(slots, BookingDuration.thirtyMinutes);
      expect(valid, isNot(contains(at(9)))); // strands 09:30 between 09:00 and 10:00
      expect(valid, isNot(contains(at(11, 30)))); // strands 11:00 next to booked 10:30
      expect(valid, isNot(contains(at(12, 30)))); // strands 13:00 next to unavailable 13:30
      expect(valid, isNot(contains(at(14)))); // strands 14:30 before booked 15:00
      expect(valid, isNot(contains(at(14, 30)))); // strands 14:00 between 13:30 U and 14:30
      expect(valid, isNot(contains(at(16)))); // strands 15:30 after booked 15:00
    });
  });
}
