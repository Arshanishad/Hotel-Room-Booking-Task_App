import 'package:flutter/material.dart';
import 'package:hotel_room_booking/models/room.dart';

class HotelRoomBookingPage extends StatefulWidget {
  const HotelRoomBookingPage({super.key});

  @override
  State<HotelRoomBookingPage> createState() => _HotelRoomBookingPageState();
}

class _HotelRoomBookingPageState extends State<HotelRoomBookingPage> {
  DateTime? checkIn;
  DateTime? checkOut;
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;

  Future<void> _selectTime({required bool isCheckIn}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn
          ? (checkInTime ?? const TimeOfDay(hour: 14, minute: 0))
          : (checkOutTime ?? const TimeOfDay(hour: 11, minute: 0)),
    );

    if (!mounted || picked == null) return;

    setState(() {
      if (isCheckIn) {
        checkInTime = picked;
      } else {
        checkOutTime = picked;
      }
    });
  }

  int? selectedRoomIndex;

  String? dateError;
  String? roomError;
  String formatCurrentDate() {
    return formatDate(today);
  }

  final TextEditingController guestNameController = TextEditingController(
    text: 'Rajesh K. Sharma',
  );

  final TextEditingController phoneController = TextEditingController(
    text: '+91 98201 44829',
  );

  final TextEditingController emailController = TextEditingController(
    text: 'rajsharma@example.in',
  );

  // Sample room data provided by Raintech Software Limited.
  final List<Room> rooms = const [
    Room(
      code: 'R101',
      name: 'Deluxe Room',
      image: 'assets/room1.jpg',
      description: 'Deluxe Room',
      price: 3500,
      maxGuests: 2,
      bed: 'King',
      amenities: ['WiFi', 'Mini Bar', 'Free Breakfast'],
    ),
    Room(
      code: 'R102',
      name: 'Deluxe Room',
      image: 'assets/room2.jpg',
      description: 'Floor 2 • City View',
      price: 3500,
      maxGuests: 2,
      bed: 'King',
      amenities: ['WiFi', 'City View', 'Free Breakfast'],
    ),
    Room(
      code: 'R201',
      name: 'Executive Suite',
      image: 'assets/room3.jpg',
      description: 'Executive Suite',
      price: 5800,
      maxGuests: 3,
      bed: 'King',
      amenities: ['WiFi', 'Living Area', 'Jacuzzi'],
    ),
    Room(
      code: 'R202',
      name: 'Executive Suite',
      image: 'assets/room3.jpg',
      description: 'Executive Suite',
      price: 5800,
      maxGuests: 3,
      bed: 'King',
      amenities: ['WiFi', 'Living Area', 'Jacuzzi'],
    ),
    Room(
      code: 'R301',
      name: 'Family Room',
      image: 'assets/room4.jpg',
      description: 'Floor 3 • Double Queen',
      price: 4200,
      maxGuests: 4,
      bed: '2 Queen',
      amenities: ['WiFi', 'TV', 'Free Breakfast'],
    ),
  ];

  Room? get selectedRoom {
    if (selectedRoomIndex == null) {
      return null;
    }

    if (selectedRoomIndex! < 0 || selectedRoomIndex! >= rooms.length) {
      return null;
    }

    return rooms[selectedRoomIndex!];
  }

  DateTime get today {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  // Dynamic date used for "Audit Date" and "Rates are current as of".
  String get currentDateText {
    return formatDate(today);
  }

  bool get datesSelected {
    return checkIn != null && checkOut != null;
  }

  bool get isDateRangeValid {
    if (checkIn == null || checkOut == null) {
      return false;
    }

    return checkOut!.isAfter(checkIn!);
  }

  // Uses UTC date-only values so the calculation is based purely
  // on calendar dates and not time/DST differences.
  int _daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime.utc(start.year, start.month, start.day);

    final endDate = DateTime.utc(end.year, end.month, end.day);

    return endDate.difference(startDate).inDays;
  }

  int get nights {
    if (!isDateRangeValid) {
      return 0;
    }

    return _daysBetween(checkIn!, checkOut!);
  }

  double get subtotal {
    final room = selectedRoom;

    if (room == null || nights <= 0) {
      return 0;
    }

    return room.price.toDouble() * nights;
  }

  double get total {
    return subtotal;
  }

  @override
  void dispose() {
    guestNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> selectDate({required bool isCheckIn}) async {
    final minimumDate = today;

    // Check-out cannot be selected before check-in.
    if (!isCheckIn && checkIn == null) {
      setState(() {
        dateError = 'Please select a check-in date first.';
      });
      return;
    }

    DateTime initialDate;

    if (isCheckIn) {
      initialDate = checkIn ?? minimumDate;
    } else {
      final minimumCheckoutDate = checkIn!.add(const Duration(days: 1));

      if (checkOut != null && checkOut!.isAfter(checkIn!)) {
        initialDate = checkOut!;
      } else {
        initialDate = minimumCheckoutDate;
      }

      if (initialDate.isBefore(minimumCheckoutDate)) {
        initialDate = minimumCheckoutDate;
      }
    }

    if (initialDate.isBefore(minimumDate)) {
      initialDate = minimumDate;
    }

    final minimumCheckoutDate = checkIn?.add(const Duration(days: 1));

    final firstDate = isCheckIn ? minimumDate : minimumCheckoutDate!;

    // Allow dates far enough into the future instead of
    // hardcoding 2030.
    final lastDate = DateTime(
      minimumDate.year + 10,
      minimumDate.month,
      minimumDate.day,
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF092C50)),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      dateError = null;

      if (isCheckIn) {
        checkIn = picked;

        // Existing checkout becomes invalid if it is
        // on or before the new check-in date.
        if (checkOut != null && !checkOut!.isAfter(checkIn!)) {
          checkOut = null;
          dateError = 'Check-out date must be after check-in date.';
        }
      } else {
        if (checkIn == null) {
          dateError = 'Please select a check-in date first.';
          return;
        }

        if (!picked.isAfter(checkIn!)) {
          checkOut = null;
          dateError = 'Check-out date must be after check-in date.';
          return;
        }

        checkOut = picked;
        dateError = null;
      }
    });
  }

  bool validateBooking() {
    String? newDateError;
    String? newRoomError;

    final currentDate = today;

    // Date validation.
    if (checkIn == null) {
      newDateError = 'Please select a check-in date.';
    } else if (checkIn!.isBefore(currentDate)) {
      newDateError = 'Check-in date cannot be in the past.';
    } else if (checkOut == null) {
      newDateError = 'Please select a check-out date.';
    } else if (!checkOut!.isAfter(checkIn!)) {
      newDateError = 'Check-out date must be after check-in date.';
    }

    // Room validation.
    if (selectedRoomIndex == null) {
      newRoomError = 'Please select a room.';
    }

    setState(() {
      dateError = newDateError;
      roomError = newRoomError;
    });

    return newDateError == null && newRoomError == null;
  }

  void selectRoom(int index) {
    if (index < 0 || index >= rooms.length) {
      return;
    }

    setState(() {
      selectedRoomIndex = index;
      roomError = null;
    });
  }

  void resetSelection() {
    setState(() {
      checkIn = null;
      checkOut = null;
      selectedRoomIndex = null;
      dateError = null;
      roomError = null;
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String formatMoney(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  String formatRoomPrice(num value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width < 800) {
              return _buildMobileLayout();
            }

            if (width < 1200) {
              return _buildTabletLayout();
            }

            return _buildDesktopLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.15)),
      child: Column(
        children: [
          _buildTopNavigation(),
          _buildPageHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
              child: Column(
                children: [
                  _buildDesktopMainContent(),
                  const SizedBox(height: 14),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildDateCard(),
              const SizedBox(height: 12),
              _buildAvailableRoomsCard(),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(flex: 3, child: _buildBookingSummaryCard()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildTopNavigation(),
        _buildPageHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildDateCard(),
                const SizedBox(height: 12),
                _buildAvailableRoomsCard(),
                const SizedBox(height: 12),
                _buildBookingSummaryCard(),
                const SizedBox(height: 15),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildMobilePageTitle(),
                const SizedBox(height: 10),
                _buildDateCard(),
                const SizedBox(height: 10),
                _buildAvailableRoomsCard(),
                const SizedBox(height: 10),
                _buildBookingSummaryCard(),
                const SizedBox(height: 15),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E7ED))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.hotel, color: Color(0xFF092C50), size: 22),
          const SizedBox(width: 7),
          const Text(
            'GrandPMS',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF092C50),
            ),
          ),
          const SizedBox(width: 32),
          _navItem('Front Desk', false),
          _navItem('Room Booking', true),
          _navItem('Inventory & Rates', false),
          _navItem('Guests', false),
          const Spacer(),
          _systemStatus(),
          const SizedBox(width: 15),
          const Text(
            'Front Desk Agent',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5563),
            ),
          ),
          const SizedBox(width: 7),
          const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xFF092C50),
            child: Icon(Icons.person, color: Colors.white, size: 17),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E7ED))),
      ),
      child: Row(
        children: [
          const Icon(Icons.hotel, size: 21, color: Color(0xFF092C50)),
          const SizedBox(width: 6),
          const Text(
            'GrandPMS',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF092C50),
            ),
          ),
          const Spacer(),
          _systemStatus(),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF092C50),
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String text, bool selected) {
    return Container(
      height: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        border: selected
            ? const Border(
                bottom: BorderSide(color: Color(0xFF0A5C98), width: 2),
              )
            : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? const Color(0xFF092C50) : const Color(0xFF657180),
          ),
        ),
      ),
    );
  }

  Widget _systemStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9FAF2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: Color(0xFF139C67)),
          SizedBox(width: 5),
          Text(
            'SYSTEM OPERATIONAL',
            style: TextStyle(
              color: Color(0xFF08764B),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 11),
      color: const Color(0xFFF7F9FC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_box_outlined,
                size: 16,
                color: Color(0xFF173C5F),
              ),
              const SizedBox(width: 7),
              const Text(
                'Hotel Room Booking',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF173C5F),
                ),
              ),
              const SizedBox(width: 8),
              _greenBadge('LIVE RESERVATION ENGINE'),
              const Spacer(),
              _smallHeaderInfo('Property', 'Grand Horizon Hotel'),
              const SizedBox(width: 8),
              _smallHeaderInfo('Audit Date', currentDateText),
              const SizedBox(width: 8),
              _smallHeaderInfo('Base Currency', 'INR (₹)'),
              const SizedBox(width: 8),
              _smallHeaderInfo('Room Feeds', 'Sync OK'),
            ],
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.only(left: 23),
            child: Text(
              'Select dates and a room to book. '
              'PMS instant-rate recalculation active.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePageTitle() {
    return Row(
      children: [
        const Icon(
          Icons.check_box_outlined,
          size: 16,
          color: Color(0xFF173C5F),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'Hotel Room Booking',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF173C5F),
            ),
          ),
        ),
        _greenBadge('LIVE'),
      ],
    );
  }

  Widget _greenBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF8EC),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Color(0xFF08764B),
        ),
      ),
    );
  }

  Widget _smallHeaderInfo(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E5EB)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontSize: 10, color: Color(0xFF87909B)),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF364354),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF173C5F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  '1.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SELECT DATES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'Standard Rate Window',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                return Column(
                  children: [
                    _dateSelector(
                      title: 'CHECK-IN DATE',
                      date: checkIn,
                      onTap: () => selectDate(isCheckIn: true),
                    ),
                    const SizedBox(height: 10),
                    _dateSelector(
                      title: 'CHECK-OUT DATE',
                      date: checkOut,
                      onTap: () => selectDate(isCheckIn: false),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _dateSelector(
                      title: 'CHECK-IN DATE',
                      date: checkIn,
                      onTap: () => selectDate(isCheckIn: true),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: _dateSelector(
                      title: 'CHECK-OUT DATE',
                      date: checkOut,
                      onTap: () => selectDate(isCheckIn: false),
                    ),
                  ),
                ],
              );
            },
          ),
          if (dateError != null) ...[
            const SizedBox(height: 9),
            _errorMessage(dateError!),
          ],
          const SizedBox(height: 9),
          if (isDateRangeValid)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE4FAF0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Color(0xFF0E9C63),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$nights nights selected '
                      '(${formatDate(checkIn)} → '
                      '${formatDate(checkOut)})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF08764B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _greenBadge('Valid'),
                ],
              ),
            ),
          if (isDateRangeValid) const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 5,
            children: [
              // const _InfoBullet(
              //   text: 'Check-in time 14:00',
              // ),
              GestureDetector(
                onTap: () => _selectTime(isCheckIn: false),
                child: _InfoBullet(
                  text:
                      'Check-out time ${checkOutTime?.format(context) ?? 'Select time'}',
                ),
              ),
              // const _InfoBullet(
              //   text: 'Check-out time 11:00',
              // ),
              GestureDetector(
                onTap: () => _selectTime(isCheckIn: true),
                child: _InfoBullet(
                  text:
                      'Check-in time ${checkInTime?.format(context) ?? 'Select time'}',
                ),
              ),
              _InfoBullet(
                text: 'Rates are current as of ${formatCurrentDate()}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateSelector({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFFE1E5EA)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 15,
              color: Color(0xFF6F7B87),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatDate(date),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: date == null
                          ? const Color(0xFF89939D)
                          : const Color(0xFF26384B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 17,
              color: Color(0xFF7A8490),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF2CACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 15, color: Color(0xFFC0392B)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC0392B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableRoomsCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            number: '2',
            title: 'AVAILABLE ROOMS',
            trailing: '${rooms.length} available',
          ),
          const SizedBox(height: 10),
          _buildRoomImageCards(),
          const SizedBox(height: 13),
          _buildRoomTable(),
          if (roomError != null) ...[
            const SizedBox(height: 8),
            _errorMessage(roomError!),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomImageCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int count = 3;

        if (width < 600) {
          count = 1;
        } else if (width < 850) {
          count = 2;
        }

        final cardWidth = count == 1
            ? width
            : (width - ((count - 1) * 9)) / count;

        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: rooms.asMap().entries.map((entry) {
            return SizedBox(
              width: cardWidth,
              child: _roomImageCard(entry.value, entry.key),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _roomImageCard(Room room, int index) {
    final selected = selectedRoomIndex == index;

    return GestureDetector(
      onTap: () {
        selectRoom(index);
      },
      child: Container(
        height: 116,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected ? const Color(0xFF0A5C98) : const Color(0xFFE0E5EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _roomPlaceholder(index),
                  Positioned(
                    left: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF092C50),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${room.name} • '
                        '${formatRoomPrice(room.price)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF26384B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7C8792),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${room.price.toStringAsFixed(0)} '
                      '/ night',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF092C50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomPlaceholder(int index) {
    const images = [
      'assets/images/hotel_room_image1.jpeg',
      'assets/images/hotel_room_image2.jpeg',
      'assets/images/hotel_room_image3.jpeg',
      'assets/images/hotel_room_image4.jpeg',
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8796A2), Color(0xFF344755)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        images[index % images.length],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white,
              size: 35,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth < 650 ? 650 : tableWidth,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 5,
                  ),
                  color: const Color(0xFFF3F6F9),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text('ROOM\nCODE', style: _tableHeaderStyle),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'ROOM TYPE & AMENITIES',
                          style: _tableHeaderStyle,
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text('PRICE /\nNIGHT', style: _tableHeaderStyle),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text('MAX\nGUESTS', style: _tableHeaderStyle),
                      ),
                      SizedBox(
                        width: 45,
                        child: Text('SELECT', style: _tableHeaderStyle),
                      ),
                    ],
                  ),
                ),
                ...rooms.asMap().entries.map((entry) {
                  return _buildRoomRow(entry.value, entry.key);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomRow(Room room, int index) {
    final selected = selectedRoomIndex == index;

    return InkWell(
      onTap: () {
        selectRoom(index);
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF4FAFE) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFE9EDF1))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                room.code,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? const Color(0xFF0A5C98)
                      : const Color(0xFF4C5B69),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          room.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334454),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 3,
                    children: room.amenities.map((amenity) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 11,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            amenity,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${room.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334454),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'per night',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 13,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      '${room.maxGuests} Guests',
                      style: const TextStyle(fontSize: 9, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 45,
              child: Radio<int>(
                value: index,
                groupValue: selectedRoomIndex,
                activeColor: const Color(0xFF0A5C98),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  selectRoom(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            number: '3',
            title: 'BOOKING SUMMARY',
            trailing: 'DRAFT RESERVATION',
          ),
          const SizedBox(height: 10),
          _selectedRoomSummary(),
          const SizedBox(height: 12),
          _guestInformation(),
          const SizedBox(height: 12),
          _bookingButtons(),
        ],
      ),
    );
  }

  Widget _selectedRoomSummary() {
    final room = selectedRoom;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE3E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECTED ROOM',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7E8995),
            ),
          ),
          const SizedBox(height: 4),
          if (room == null)
            const Text(
              'No room selected',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7E8995),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${room.name} (${room.code})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF26384B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F1FB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${room.maxGuests} Guests max',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C6595),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: Color(0xFF7A8692),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${formatDate(checkIn)} → '
                  '${formatDate(checkOut)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF687581),
                  ),
                ),
              ),
              Text(
                nights > 0 ? '$nights Nights' : '0 Nights',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF536270),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 11, color: Color(0xFF7A8692)),
              const SizedBox(width: 5),
              Text(
                'Check-in ${checkInTime?.format(context) ?? 'Select time'}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF687581)),
              ),
              const SizedBox(width: 15),
              Text(
                'Check-out ${checkOutTime?.format(context) ?? 'Select time'}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF687581)),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFDDE2E7)),
          _priceRow(
            'Price / Night',
            room == null ? '₹0.00' : '₹${room.price.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 5),
          _priceRow(
            'Total Room Price ($nights nights)',
            '₹${subtotal.toStringAsFixed(2)}',
          ),
          const Divider(height: 18, color: Color(0xFFDDE2E7)),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL AMOUNT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF52606D),
                  ),
                ),
              ),
              Text(
                formatMoney(total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF152F49),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Nights × price per night',
            style: TextStyle(fontSize: 11, color: Color(0xFF8A949F)),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String amount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 10, color: Color(0xFF687581)),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475766),
          ),
        ),
      ],
    );
  }

  Widget _guestInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.person_outline, size: 14, color: Color(0xFF53687A)),
            SizedBox(width: 5),
            Text(
              'Guest Information',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF35485A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        _textField(label: 'Guest Full Name *', controller: guestNameController),
        const SizedBox(height: 7),
        _textField(label: 'Phone Number', controller: phoneController),
        const SizedBox(height: 7),
        _textField(label: 'Guest Email ID', controller: emailController),
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 11, color: Color(0xFF35485A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF89939D)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDDE3E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFDDE3E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF0A5C98)),
        ),
      ),
    );
  }

  Widget _bookingButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 38,
          child: ElevatedButton.icon(
            onPressed: () {
              final isValid = validateBooking();

              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please fix the validation '
                      'errors before booking.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );

                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking confirmed: '
                    '${selectedRoom!.code} '
                    'for $nights nights '
                    '(${formatMoney(total)})',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.lock_outline, size: 14),
            label: Text(
              'Confirm Booking '
              '(${formatMoney(total)})',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF062B4C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 30,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.schedule, size: 12),
                  label: const Text(
                    'Hold for 15 Mins',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C6A77),
                    side: const BorderSide(color: Color(0xFFDDE2E7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: SizedBox(
                height: 30,
                child: OutlinedButton.icon(
                  onPressed: resetSelection,
                  icon: const Icon(Icons.refresh, size: 12),
                  label: const Text(
                    'Reset Selection',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5C6A77),
                    side: const BorderSide(color: Color(0xFFDDE2E7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE0E5EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle({
    required String number,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 19,
            height: 19,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1F8),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF184F78),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF314A60),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF677481),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Text(
          'GrandPMS Room Booking Engine v4.5',
          style: TextStyle(fontSize: 9, color: Color(0xFF8A949D)),
        ),
        const Spacer(),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0E9C63),
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          '4 of 5 units free for dispatch',
          style: TextStyle(fontSize: 9, color: Color(0xFF7A8792)),
        ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String text;

  const _InfoBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 4, color: Color(0xFF87919B)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF7B8792)),
        ),
      ],
    );
  }
}

const TextStyle _tableHeaderStyle = TextStyle(
  fontSize: 8,
  height: 1.2,
  fontWeight: FontWeight.w900,
  color: Color(0xFF7B8792),
);

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF15966A)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(0, size.height * .72);

    path.lineTo(size.width * .14, size.height * .55);

    path.lineTo(size.width * .28, size.height * .63);

    path.lineTo(size.width * .42, size.height * .30);

    path.lineTo(size.width * .55, size.height * .42);

    path.lineTo(size.width * .68, size.height * .15);

    path.lineTo(size.width * .83, size.height * .35);

    path.lineTo(size.width, size.height * .08);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
