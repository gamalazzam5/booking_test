import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/data/repositories/booking_repository.dart';

/// Serves a predefined, in-memory schedule: 09:00–18:00 in 30-minute slots.
///
/// The seed mixes booked, unavailable and available slots so every booking rule
/// (overlap, unavailable, 6 PM boundary, X-O-X gap) can be exercised by hand:
///   • 10:00–11:00 booked → overlap / consecutive-slot rules.
///   • 13:30 unavailable  → blocked-slot rule.
///   • 15:00 booked       → 14:00 for 30 min would strand 14:30 (X-O-X).
///   • 17:00 and 17:30    → 6 PM boundary cases.
class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl();

  static const Duration _dayStart = Duration(hours: 9);
  static const Duration _slotLength = Duration(minutes: 30);

  /// Status of each slot in order, starting at [_dayStart]. One entry per slot.
  static const List<SlotStatus> _seed = [
    SlotStatus.available, //   09:00
    SlotStatus.available, //   09:30
    SlotStatus.booked, //      10:00
    SlotStatus.booked, //      10:30
    SlotStatus.available, //   11:00
    SlotStatus.available, //   11:30
    SlotStatus.available, //   12:00
    SlotStatus.available, //   12:30
    SlotStatus.available, //   13:00
    SlotStatus.unavailable, // 13:30
    SlotStatus.available, //   14:00
    SlotStatus.available, //   14:30
    SlotStatus.booked, //      15:00
    SlotStatus.available, //   15:30
    SlotStatus.available, //   16:00
    SlotStatus.available, //   16:30
    SlotStatus.available, //   17:00
    SlotStatus.available, //   17:30
  ];

  @override
  List<TimeSlot> getSlots() {
    return List.unmodifiable([
      for (var i = 0; i < _seed.length; i++)
        TimeSlot(
          start: _dayStart + _slotLength * i,
          end: _dayStart + _slotLength * (i + 1),
          status: _seed[i],
        ),
    ]);
  }
}
