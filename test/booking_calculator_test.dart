import 'package:flutter_test/flutter_test.dart';

import 'package:hotel_room_booking/utils/booking_calculator.dart';

void main() {
  group('BookingCalculator', () {
    test(
      'calculates correct number of nights',
      () {
        final checkIn = DateTime(2026, 9, 10);
        final checkOut = DateTime(2026, 9, 13);

        final nights =
            BookingCalculator.calculateNights(
          checkIn,
          checkOut,
        );

        expect(nights, 3);
      },
    );

    test(
      'calculates correct total price',
      () {
        final total =
            BookingCalculator.calculateTotal(
          nights: 3,
          pricePerNight: 3500,
        );

        expect(total, 10500);
      },
    );

    test(
      'rejects same check-in and check-out dates',
      () {
        final date = DateTime(2026, 9, 10);

        final error =
            BookingCalculator.validateDates(
          checkIn: date,
          checkOut: date,
        );

        expect(
          error,
          'Check-out date must be after check-in date.',
        );
      },
    );

    test(
      'rejects check-out before check-in',
      () {
        final checkIn = DateTime(2026, 9, 15);
        final checkOut = DateTime(2026, 9, 12);

        final error =
            BookingCalculator.validateDates(
          checkIn: checkIn,
          checkOut: checkOut,
        );

        expect(
          error,
          'Check-out date must be after check-in date.',
        );
      },
    );

    test(
      'requires check-in date',
      () {
        final error =
            BookingCalculator.validateDates(
          checkIn: null,
          checkOut: DateTime(2026, 9, 12),
        );

        expect(
          error,
          'Please select a check-in date.',
        );
      },
    );

    test(
      'requires check-out date',
      () {
        final error =
            BookingCalculator.validateDates(
          checkIn: DateTime(2026, 9, 10),
          checkOut: null,
        );

        expect(
          error,
          'Please select a check-out date.',
        );
      },
    );
  });
}