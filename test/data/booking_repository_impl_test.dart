import 'package:flutter_test/flutter_test.dart';
import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/data/repositories/booking_repository_impl.dart';

import '../helpers/schedule_builder.dart';

void main() {
  final slots = const BookingRepositoryImpl().getSlots();

  test('provides 18 half-hour slots from 09:00 to 18:00', () {
    expect(slots, hasLength(18));
    expect(slots.first.start, at(9));
    expect(slots.last.end, at(18));
    for (final slot in slots) {
      expect(slot.end - slot.start, const Duration(minutes: 30));
    }
  });

  test('slots are contiguous — each starts where the previous one ends', () {
    for (var i = 1; i < slots.length; i++) {
      expect(slots[i].start, slots[i - 1].end);
    }
  });

  test('contains available, booked and unavailable slots', () {
    final statuses = slots.map((s) => s.status).toSet();
    expect(statuses, SlotStatus.values.toSet());
  });

  test('seed statuses match the documented schedule', () {
    SlotStatus statusAt(Duration start) =>
        slots.firstWhere((s) => s.start == start).status;
    expect(statusAt(at(10)), SlotStatus.booked);
    expect(statusAt(at(10, 30)), SlotStatus.booked);
    expect(statusAt(at(13, 30)), SlotStatus.unavailable);
    expect(statusAt(at(15)), SlotStatus.booked);
    expect(statusAt(at(17, 30)), SlotStatus.available);
  });

  test('the schedule cannot be modified by callers', () {
    expect(() => slots.add(slots.first), throwsUnsupportedError);
  });

  test('each call returns an equal schedule', () {
    expect(const BookingRepositoryImpl().getSlots(), slots);
  });
}
