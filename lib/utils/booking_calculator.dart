class BookingCalculator {
  static int calculateNights(
    DateTime checkIn,
    DateTime checkOut,
  ) {
    final start = DateTime(
      checkIn.year,
      checkIn.month,
      checkIn.day,
    );

    final end = DateTime(
      checkOut.year,
      checkOut.month,
      checkOut.day,
    );

    return end.difference(start).inDays;
  }

  static int calculateTotal({
    required int nights,
    required int pricePerNight,
  }) {
    return nights * pricePerNight;
  }

  static String? validateDates({
    DateTime? checkIn,
    DateTime? checkOut,
  }) {
    if (checkIn == null) {
      return 'Please select a check-in date.';
    }

    if (checkOut == null) {
      return 'Please select a check-out date.';
    }

    final today = DateTime.now();

    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final checkInOnly = DateTime(
      checkIn.year,
      checkIn.month,
      checkIn.day,
    );

    final checkOutOnly = DateTime(
      checkOut.year,
      checkOut.month,
      checkOut.day,
    );

    if (checkInOnly.isBefore(todayOnly)) {
      return 'Check-in date cannot be in the past.';
    }

    if (!checkOutOnly.isAfter(checkInOnly)) {
      return 'Check-out date must be after check-in date.';
    }

    return null;
  }
}