import 'package:equatable/equatable.dart';
import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/domain/models/booking_validation_result.dart';

sealed class BookingState extends Equatable {
  const BookingState();
}

/// Before the schedule has been loaded.
final class BookingLoading extends BookingState {
  const BookingLoading();

  @override
  List<Object?> get props => [];
}

/// A start time the user picked, together with the outcome of validating it for
/// the current duration. Kept as one object so "a start with no validation"
/// cannot exist.
class BookingSelection extends Equatable {
  const BookingSelection({required this.start, required this.validation});

  final Duration start;
  final BookingValidationResult validation;

  @override
  List<Object?> get props => [start, validation];
}

/// A booking that was just confirmed; present only on the state emitted by
/// `confirmBooking` so the UI can react once (e.g. show a snackbar).
class ConfirmedBooking extends Equatable {
  const ConfirmedBooking({required this.start, required this.end});

  final Duration start;
  final Duration end;

  @override
  List<Object?> get props => [start, end];
}

/// The screen once the schedule is loaded.
final class BookingLoaded extends BookingState {
  const BookingLoaded({
    required this.slots,
    required this.selectedDuration,
    required this.validStartTimes,
    this.selection,
    this.confirmedBooking,
  });

  /// The authoritative schedule (includes bookings confirmed this session).
  /// Never contains display-only states — selection is expressed by [selection].
  final List<TimeSlot> slots;

  final BookingDuration selectedDuration;

  /// Start times that are fully valid for [selectedDuration].
  final List<Duration> validStartTimes;

  /// The user's chosen start and its validation, or null when nothing is chosen.
  final BookingSelection? selection;

  /// Set only on the state that follows a successful confirmation.
  final ConfirmedBooking? confirmedBooking;

  Duration? get selectedStart => selection?.start;

  /// Calculated end of the selection. Available even when the selection is
  /// invalid (e.g. 6:30 PM) so the UI can show why it fails.
  Duration? get selectedEnd {
    final start = selectedStart;
    return start == null ? null : start + selectedDuration.length;
  }

  BookingInvalidReason? get invalidReason => selection?.validation.reason;

  bool get canConfirm => selection?.validation.isValid ?? false;

  /// True when [slot] lies inside the requested range `[start, end)`.
  bool isInSelection(TimeSlot slot) {
    final start = selectedStart;
    final end = selectedEnd;
    if (start == null || end == null) return false;
    return slot.start >= start && slot.start < end;
  }

  @override
  List<Object?> get props => [
        slots,
        selectedDuration,
        validStartTimes,
        selection,
        confirmedBooking,
      ];
}
