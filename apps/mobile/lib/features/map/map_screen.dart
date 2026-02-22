import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/models/restaurant.dart';
import '../../core/providers/restaurants_provider.dart';
import '../restaurant/restaurant_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Position? _position;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() => _position = position);
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A08),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5C00)),
        ),
      );
    }

    final location = (lat: _position!.latitude, lng: _position!.longitude);
    final restaurantsAsync = ref.watch(restaurantsProvider(location));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A08),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_position!.latitude, _position!.longitude),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
urlTemplate: 'https://api.maptiler.com/maps/streets-v2-dark/{z}/{x}/{y}.png?key=ERObcBdy6K6B8cGKfVCM',              ),
              restaurantsAsync.when(
                data: (restaurants) => MarkerLayer(
                  markers: restaurants.map((r) => _buildMarker(r)).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (error, _) {
                  debugPrint('Error en mapa al cargar restaurantes: $error');
                  return const MarkerLayer(markers: []);
                },
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_position!.latitude, _position!.longitude),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5C00),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              'GoBite',
              style: TextStyle(
                color: const Color(0xFFFF5C00),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
  top: 60,
  right: 20,
  child: GestureDetector(
    onTap: () async {
      await Supabase.instance.client.auth.signOut();
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.logout, color: Colors.white),
    ),
  ),
),
        ],
      ),
    );
  }

  Marker _buildMarker(Restaurant restaurant) {
    return Marker(
      point: LatLng(restaurant.latitude, restaurant.longitude),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantScreen(restaurantId: restaurant.id),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF5C00),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}