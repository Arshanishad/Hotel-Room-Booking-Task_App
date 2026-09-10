# Hotel Room Booking

A Flutter-based Hotel Room Booking front-end application developed as part of the **Raintech Software Limited Developer Skills Assessment**.

The application allows users to select check-in/check-out dates, choose an available hotel room, and view the calculated number of nights and total room price.

## Tech Stack

* **Flutter**
* **Dart**
* Material UI
* Hardcoded sample room data
* No backend or database

## Features

* Display available hotel rooms

* Select a check-in date

* Select a check-out date

* Select one room from the available rooms

* Display room details and amenities

* Calculate the number of nights automatically

* Calculate total price using:

  `Number of Nights × Price Per Night`

* Validate check-in date

* Prevent selecting a check-in date in the past

* Validate check-out date

* Prevent same-day check-in/check-out

* Prevent check-out before check-in

* Display clear validation messages

* Responsive layout for desktop, tablet, and mobile

* Reset selected dates and room

* Select check-in and check-out times

## Sample Room Data

| Room Code | Room Type       | Price / Night | Max Guests |
| --------- | --------------- | ------------- | ---------- |
| R101      | Deluxe Room     | ₹3,500        | 2          |
| R102      | Deluxe Room     | ₹3,500        | 2          |
| R201      | Executive Suite | ₹5,800        | 3          |
| R202      | Executive Suite | ₹5,800        | 3          |
| R301      | Family Room     | ₹4,200        | 4          |

## Date & Price Calculation

The application calculates the number of nights based on the difference between the check-in and check-out calendar dates.

For example:

```text
Check-in: 10 Sep 2026
Check-out: 13 Sep 2026

Number of nights = 3

Room price = ₹3,500 / night

Total = 3 × ₹3,500
      = ₹10,500
```

## Validation

The following cases are handled:

* Check-in date is required
* Check-in date cannot be in the past
* Check-out date is required
* Check-out date must be after check-in date
* A room must be selected before confirming the booking

Validation errors are displayed clearly to the user instead of failing silently.

## Project Structure

```text
lib/
├── models/
│   └── room.dart
│
└── pages/
    └── hotel_room_booking_page.dart
```

> File names may vary depending on the final project structure.

## How to Run

### Prerequisites

Make sure Flutter is installed and configured.

Check your Flutter installation:

```bash
flutter doctor
```

### Run the project

Clone the repository and navigate into the project:

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd hotel_room_booking
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

### Run on Chrome

For Flutter Web:

```bash
flutter run -d chrome
```

### Build Web

```bash
flutter build web
```

## Assets

The project uses local room images stored inside the assets directory.

```text
assets/
└── images/
    ├── hotel_room_image1.jpeg
    ├── hotel_room_image2.jpeg
    ├── hotel_room_image3.jpeg
    └── hotel_room_image4.jpeg
```

Make sure the assets are declared in `pubspec.yaml`.

## What I Would Improve With More Time

If additional development time were available, I would consider adding:

* Unit tests for date and price calculations
* Room availability based on existing bookings
* Guest-count based room filtering
* More comprehensive form validation
* Improved accessibility
* Persistent booking state
* Additional booking confirmation details

These features were intentionally kept outside the core implementation because the assessment does not require a backend, database, authentication, payments, or booking persistence.

## Assessment Scope

This project intentionally focuses on the requirements specified in the coding assessment:

* Room listing
* Date selection
* Room selection
* Night calculation
* Price calculation
* Date validation
* Room validation
* Clear error handling
* Clean and readable Flutter implementation

## Author

**Arsha Nishad**

Flutter Developer
