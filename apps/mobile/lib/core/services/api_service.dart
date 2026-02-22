import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
    ));
  }

  Future<List<Restaurant>> getRestaurants(double lat, double lng, {double radius = 5}) async {
    final response = await _dio.get('/restaurants', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    });
    return (response.data as List).map((r) => Restaurant.fromJson(r)).toList();
  }

  Future<Restaurant> getRestaurant(String id) async {
    final response = await _dio.get('/restaurants/$id');
    return Restaurant.fromJson(response.data);
  }

  Future<void> addFavorite(String restaurantId) async {
    await _dio.post('/favorites/$restaurantId');
  }

  Future<void> removeFavorite(String restaurantId) async {
    await _dio.delete('/favorites/$restaurantId');
  }

  Future<List<Restaurant>> getFavorites() async {
    final response = await _dio.get('/favorites');
    return (response.data as List).map((r) => Restaurant.fromJson(r['restaurant'])).toList();
  }

  Future<void> syncUser(User user) async {
  try {
    await _dio.post('/users/sync', data: {
      'id': user.id,
      'email': user.email,
      'user_metadata': user.userMetadata,
    });
  } catch (e) {
    // Si falla no bloqueamos el login
    debugPrint('Error syncing user: $e');
  }
}
}