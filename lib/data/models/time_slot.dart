import 'package:equatable/equatable.dart';

/// Whether a slot can be booked. Display concerns (selected / invalid) are
/// deliberately not part of this enum — the presentation layer derives them.
enum SlotStatus {
  /// Slot is free and may be booked.
  available,

  /// Slot is occupied by an existing appointment.
  booked,

  /// Slot is blocked and cannot be booked (e.g. break, maintenance).
  unavailable,
}

/// One appointment slot in the working day.
///
/// [start] and [end] are offsets from midnight, which keeps this model (and the
/// domain rules that use it) free of `dart:ui` / Flutter types and time zones.
class TimeSlot extends Equatable {
  const TimeSlot({
    required this.start,
    required this.end,
    required this.status,
  });

  final Duration start;
  final Duration end;
  final SlotStatus status;

  bool get isAvailable => status == SlotStatus.available;

  /// A slot that cannot be booked (`X` in the X-O-X rule): booked or unavailable.
  bool get isBlocked => !isAvailable;

  TimeSlot copyWith({SlotStatus? status}) {
    return TimeSlot(start: start, end: end, status: status ?? this.status);
  }

  @override
  List<Object?> get props => [start, end, status];
}
