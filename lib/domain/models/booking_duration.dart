/// The selectable appointment lengths.
enum BookingDuration {
  thirtyMinutes(Duration(minutes: 30)),
  oneHour(Duration(hours: 1)),
  oneHalfHour(Duration(hours: 1, minutes: 30)),
  twoHours(Duration(hours: 2));

  const BookingDuration(this.length);

  /// Wall-clock length of a booking with this duration.
  final Duration length;
}
