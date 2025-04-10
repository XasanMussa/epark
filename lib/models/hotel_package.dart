class HotelPackage {
  final String name;
  final String description;
  final int pricePerNight;
  final List<String> features;
  final bool includesParking;
  final int parkingPrice;

  const HotelPackage({
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.features,
    required this.includesParking,
    required this.parkingPrice,
  });
}
