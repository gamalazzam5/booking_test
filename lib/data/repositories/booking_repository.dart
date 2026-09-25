import 'package:booking_appointments/data/models/time_slot.dart';

/// Source of the day's schedule. All data is local — there is no API.
abstract interface class BookingRepository {
  /// The full working-day schedule, ordered by time, with no gaps between slots.
  List<TimeSlot> getSlots();
}
