class Weather {
  String name;
  String address;
  String city;
  String country;
  String street;
  String postalCode;

  Weather({
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.street,
    required this.postalCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      name: json['name'] ?? 'Unknown',
      address: json['address_1'] ?? 'No Address',
      city: json['city'] ?? 'No City',
      postalCode: json['postal_code'] ?? '00000',
      country: json['country'] ?? 'Unknown',
      street: json['street'] ?? 'No Street',
    );
  }
}
