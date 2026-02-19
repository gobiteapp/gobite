import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final restaurantsProvider = FutureProvider.family<List<Restaurant>, ({double lat, double lng})>(
  (ref, location) async {
    final api = ref.read(apiServiceProvider);
    return api.getRestaurants(location.lat, location.lng);
  },
);

final selectedRestaurantProvider = FutureProvider.family<Restaurant, String>(
  (ref, id) async {
    final api = ref.read(apiServiceProvider);
    return api.getRestaurant(id);
  },
);

final favoritesProvider = FutureProvider<List<Restaurant>>(
  (ref) async {
    final api = ref.read(apiServiceProvider);
    return api.getFavorites();
  },
);