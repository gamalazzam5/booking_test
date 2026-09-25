import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/data/repositories/booking_repository_impl.dart';
import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/domain/models/booking_validation_result.dart';
import 'package:booking_appointments/domain/services/booking_validator.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';

import '../../helpers/schedule_builder.dart';

void main() {
  /// Cubit over the real seed schedule.
  BookingCubit seedCubit() => BookingCubit(
        repository: const BookingRepositoryImpl(),
        validator: const BookingValidator(),
      );

  /// Cubit over a hand-written schedule.
  BookingCubit cubitFor(String pattern) => BookingCubit(
        repository: FakeBookingRepository(buildSchedule(pattern)),
        validator: const BookingValidator(),
      );

  BookingLoaded loaded(BookingCubit cubit) => cubit.state as BookingLoaded;

  test('starts in the loading state', () {
    expect(seedCubit().state, const BookingLoading());
  });

  group('load', () {
    blocTest<BookingCubit, BookingState>(
      'shows the schedule with the default duration and nothing selected',
      build: seedCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        final state = loaded(cubit);
        expect(state.slots, hasLength(18));
        expect(state.selectedDuration, BookingCubit.defaultDuration);
        expect(state.selection, isNull);
        expect(state.selectedEnd, isNull);
        expect(state.canConfirm, isFalse);
        expect(state.confirmedBooking, isNull);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'calculates the valid start times for the default duration',
      build: seedCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(loaded(cubit).validStartTimes, contains(at(11)));
        expect(loaded(cubit).validStartTimes, isNot(contains(at(9)))); // X-O-X
        expect(loaded(cubit).validStartTimes, isNot(contains(at(10)))); // booked
      },
    );
  });

  group('selectStartTime', () {
    blocTest<BookingCubit, BookingState>(
      'a valid start is selected, valid, with the calculated end time',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectDuration(BookingDuration.oneHour);
        cubit.selectStartTime(at(11));
      },
      verify: (cubit) {
        final state = loaded(cubit);
        expect(state.selectedStart, at(11));
        expect(state.selectedEnd, at(12));
        expect(state.selection!.validation.isValid, isTrue);
        expect(state.invalidReason, isNull);
        expect(state.canConfirm, isTrue);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'a booked start is selected but invalid, with the specific reason',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(10));
      },
      verify: (cubit) {
        expect(loaded(cubit).selectedStart, at(10));
        expect(loaded(cubit).invalidReason, BookingInvalidReason.startSlotBooked);
        expect(loaded(cubit).canConfirm, isFalse);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'an X-O-X start is invalid even though its own slot is free',
      build: () => cubitFor('.B..B.'),
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(10));
      },
      verify: (cubit) {
        expect(loaded(cubit).invalidReason, BookingInvalidReason.createsIsolatedGap);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'changing the start time revalidates against the new start',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(10)); // booked → invalid
        cubit.selectStartTime(at(11)); // free → valid
      },
      verify: (cubit) {
        expect(loaded(cubit).selectedStart, at(11));
        expect(loaded(cubit).invalidReason, isNull);
        expect(loaded(cubit).canConfirm, isTrue);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'does nothing before the schedule is loaded',
      build: seedCubit,
      act: (cubit) => cubit.selectStartTime(at(11)),
      expect: () => <BookingState>[],
    );
  });

  group('selectDuration', () {
    blocTest<BookingCubit, BookingState>(
      '30 min → 1 hour keeps a start that is still valid and moves the end',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(15, 30));
        cubit.selectDuration(BookingDuration.oneHour);
      },
      verify: (cubit) {
        expect(loaded(cubit).selectedStart, at(15, 30));
        expect(loaded(cubit).selectedEnd, at(16, 30));
        expect(loaded(cubit).canConfirm, isTrue);
      },
    );

    blocTest<BookingCubit, BookingState>(
      '30 min → 2 hours keeps the start selected and explains why it is now invalid',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(17));
        cubit.selectDuration(BookingDuration.twoHours);
      },
      verify: (cubit) {
        final state = loaded(cubit);
        expect(state.selectedStart, at(17));
        expect(state.selectedEnd, at(19)); // still shown, so the user sees why
        expect(state.invalidReason, BookingInvalidReason.exceedsWorkingHours);
        expect(state.canConfirm, isFalse);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'a longer duration that reaches a booked slot flags an overlap',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(9, 30));
        cubit.selectDuration(BookingDuration.oneHalfHour);
      },
      verify: (cubit) {
        expect(loaded(cubit).invalidReason, BookingInvalidReason.overlapsBooking);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'recomputes the valid start times for the new duration',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectDuration(BookingDuration.twoHours);
      },
      verify: (cubit) {
        final valid = loaded(cubit).validStartTimes;
        expect(valid, isNot(contains(at(17, 30)))); // would end 19:30
        expect(valid, isNot(contains(at(16)))); // ends 18:00 but strands 15:30
        expect(valid, isNot(contains(at(11)))); // strands 13:00 next to unavailable 13:30
        expect(valid, contains(at(15, 30))); // 15:30–17:30 leaves only the edge slot free
      },
    );

    blocTest<BookingCubit, BookingState>(
      'a duration change with no start selected just updates the duration',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectDuration(BookingDuration.oneHour);
      },
      verify: (cubit) {
        expect(loaded(cubit).selectedDuration, BookingDuration.oneHour);
        expect(loaded(cubit).selection, isNull);
      },
    );
  });

  group('confirmBooking', () {
    blocTest<BookingCubit, BookingState>(
      'books the slots, reports the confirmation and clears the selection',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectDuration(BookingDuration.oneHour);
        cubit.selectStartTime(at(11));
        cubit.confirmBooking();
      },
      verify: (cubit) {
        final state = loaded(cubit);
        expect(state.confirmedBooking, ConfirmedBooking(start: at(11), end: at(12)));
        expect(state.selection, isNull);
        expect(state.selectedDuration, BookingCubit.defaultDuration);
        final booked = state.slots.where((s) => s.start == at(11) || s.start == at(11, 30));
        expect(booked.every((s) => s.status == SlotStatus.booked), isTrue);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'recomputes valid start times from the updated schedule',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(11));
        cubit.confirmBooking();
      },
      verify: (cubit) {
        // Before the booking 12:00 was valid. With 11:00 now booked, booking 12:00
        // would strand 11:30 between two booked slots, so it is no longer offered.
        final before = (seedCubit()..load()).state as BookingLoaded;
        expect(before.validStartTimes, contains(at(12)));
        expect(loaded(cubit).validStartTimes, isNot(contains(at(12))));
      },
    );

    blocTest<BookingCubit, BookingState>(
      'does not book an invalid selection',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(10)); // booked
        cubit.confirmBooking();
      },
      verify: (cubit) {
        final state = loaded(cubit);
        expect(state.confirmedBooking, isNull);
        expect(state.invalidReason, BookingInvalidReason.startSlotBooked);
        expect(state.slots, const BookingRepositoryImpl().getSlots());
      },
    );

    blocTest<BookingCubit, BookingState>(
      'does nothing when no start time is selected',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.confirmBooking();
      },
      expect: () => [isA<BookingLoaded>()], // only the load emission
    );

    blocTest<BookingCubit, BookingState>(
      'the next interaction after a confirmation clears the confirmation',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(11));
        cubit.confirmBooking();
        cubit.selectStartTime(at(15, 30));
      },
      verify: (cubit) => expect(loaded(cubit).confirmedBooking, isNull),
    );
  });

  group('reset', () {
    blocTest<BookingCubit, BookingState>(
      'returns to the initial state after a selection, a duration change and a booking',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectDuration(BookingDuration.twoHours);
        cubit.selectStartTime(at(11));
        cubit.confirmBooking();
        cubit.selectDuration(BookingDuration.oneHour);
        cubit.selectStartTime(at(15, 30));
        cubit.reset();
      },
      verify: (cubit) {
        final initial = seedCubit()..load();
        expect(cubit.state, initial.state);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'clears an error state',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(10)); // booked → invalid
        cubit.reset();
      },
      verify: (cubit) {
        expect(loaded(cubit).selection, isNull);
        expect(loaded(cubit).invalidReason, isNull);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'restores bookings that were confirmed during the session',
      build: seedCubit,
      act: (cubit) {
        cubit.load();
        cubit.selectStartTime(at(11));
        cubit.confirmBooking();
        cubit.reset();
      },
      verify: (cubit) {
        final slot = loaded(cubit).slots.firstWhere((s) => s.start == at(11));
        expect(slot.status, SlotStatus.available);
      },
    );
  });
}
