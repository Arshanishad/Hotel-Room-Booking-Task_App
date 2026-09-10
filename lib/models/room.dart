class Room {
  final String code;
  final String name;
  final String image;
  final String description;
  final double price;
  final int maxGuests;
  final List<String> amenities;
  final String bed;

  const Room({
    required this.code,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.maxGuests,
    required this.amenities,
    required this.bed,
  });
}
