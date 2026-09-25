import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/data/repositories/booking_repository.dart';

/// Time of day as an offset from midnight, e.g. `at(17, 30)` = 5:30 PM.
Duration at(int hour, [int minute = 0]) => Duration(hours: hour, minutes: minute);

/// Builds a schedule of 30-minute slots from a readable pattern, starting at
/// [dayStart] (default 09:00):
///
///   `.` available   `B` booked   `U` unavailable
///
/// `'.B..B.'` is six slots: free, booked, free, free, booked, free.
List<TimeSlot> buildSchedule(
  String pattern, {
  Duration dayStart = const Duration(hours: 9),
}) {
  const slotLength = Duration(minutes: 30);
  return [
    for (var i = 0; i < pattern.length; i++)
      TimeSlot(
        start: dayStart + slotLength * i,
        end: dayStart + slotLength * (i + 1),
        status: switch (pattern[i]) {
          '.' => SlotStatus.available,
          'B' => SlotStatus.booked,
          'U' => SlotStatus.unavailable,
          final other => throw ArgumentError('Unknown slot symbol "$other"'),
        },
      ),
  ];
}

/// A full 09:00–18:00 day with every slot available.
String get freeDay => '.' * 18;

/// [BookingRepository] that serves a fixed schedule.
class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository(this._slots);

  final List<TimeSlot> _slots;

  @override
  List<TimeSlot> getSlots() => _slots;
}
