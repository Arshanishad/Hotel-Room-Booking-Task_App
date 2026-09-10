import 'package:flutter/material.dart';
import 'package:hotel_room_booking/screens/booking_screen.dart';

void main() {
  runApp(const GrandPmsApp());
}

class GrandPmsApp extends StatelessWidget {
  const GrandPmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Room Booking',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF092C50),
        ),
      ),
      home: const HotelRoomBookingPage(),
    );
  }
}