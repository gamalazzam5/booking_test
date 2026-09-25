import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/data/repositories/booking_repository.dart';
import 'package:booking_appointments/domain/models/booking_duration.dart';
import 'package:booking_appointments/domain/services/booking_validator.dart';
import 'package:booking_appointments/presentation/cubit/booking_state.dart';

/// Application state for the booking screen.
///
/// Flow: user action → cubit method → [BookingValidator] → emit [BookingLoaded].
/// The cubit holds no rules of its own; it only decides *when* to validate and
/// what the resulting state looks like.
class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required this._repository,
    required this._validator,
  }) : super(const BookingLoading());

  static const BookingDuration defaultDuration = BookingDuration.thirtyMinutes;

  final BookingRepository _repository;
  final BookingValidator _validator;

  /// Loads the schedule and shows the initial, empty-selection screen.
  void load() {
    emit(_buildLoaded(_repository.getSlots(), defaultDuration));
  }

  /// Returns to the initial state: original schedule, default duration, no selection.
  void reset() => load();

  /// Picks [start] and validates it against the current duration.
  void selectStartTime(Duration start) {
    final current = state;
    if (current is! BookingLoaded) return;
    emit(_buildLoaded(current.slots, current.selectedDuration, start: start));
  }

  /// Changes the duration and immediately re-validates the current start (if any).
  /// A start that stops being valid stays selected so the user is told why.
  void selectDuration(BookingDuration duration) {
    final current = state;
    if (current is! BookingLoaded) return;
    emit(_buildLoaded(current.slots, duration, start: current.selectedStart));
  }

  /// Confirms the current selection after validating it again against the
  /// current schedule; books the slots only if it is still valid.
  void confirmBooking() {
    final current = state;
    if (current is! BookingLoaded) return;
    final start = current.selectedStart;
    if (start == null) return;

    final validation = _validator.validateBooking(
      current.slots,
      start,
      current.selectedDuration,
    );
    if (!validation.isValid) {
      emit(_buildLoaded(current.slots, current.selectedDuration, start: start));
      return;
    }

    final bookedSlots = _validator.applyBooking(
      current.slots,
      start,
      current.selectedDuration,
    );
    emit(
      _buildLoaded(
        bookedSlots,
        defaultDuration,
        confirmedBooking: ConfirmedBooking(
          start: start,
          end: start + current.selectedDuration.length,
        ),
      ),
    );
  }

  BookingLoaded _buildLoaded(
    List<TimeSlot> slots,
    BookingDuration duration, {
    Duration? start,
    ConfirmedBooking? confirmedBooking,
  }) {
    return BookingLoaded(
      slots: slots,
      selectedDuration: duration,
      validStartTimes: _validator.getValidStartTimes(slots, duration),
      selection: start == null
          ? null
          : BookingSelection(
              start: start,
              validation: _validator.validateBooking(slots, start, duration),
            ),
      confirmedBooking: confirmedBooking,
    );
  }
}
