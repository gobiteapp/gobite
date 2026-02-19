class Restaurant {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? googleRating;
  final int? priceLevel;
  final double? avgPrice;
  final String? phoneNumber;
  final String? website;
  final List<Video> videos;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.googleRating,
    this.priceLevel,
    this.avgPrice,
    this.phoneNumber,
    this.website,
    this.videos = const [],
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      googleRating: json['googleRating']?.toDouble(),
      priceLevel: json['priceLevel'],
      avgPrice: json['avgPrice']?.toDouble(),
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((v) => Video.fromJson(v))
              .toList() ?? [],
    );
  }
}

class Video {
  final String id;
  final String restaurantId;
  final String source;
  final String? tiktokUrl;
  final String? videoUrl;
  final String? creatorHandle;
  final String status;

  Video({
    required this.id,
    required this.restaurantId,
    required this.source,
    this.tiktokUrl,
    this.videoUrl,
    this.creatorHandle,
    required this.status,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      restaurantId: json['restaurantId'],
      source: json['source'],
      tiktokUrl: json['tiktokUrl'],
      videoUrl: json['videoUrl'],
      creatorHandle: json['creatorHandle'],
      status: json['status'],
    );
  }
}