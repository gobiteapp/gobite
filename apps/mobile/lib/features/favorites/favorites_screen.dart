import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/restaurant.dart';
import '../../core/services/api_service.dart';
import '../restaurant/restaurant_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Restaurant>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = ApiService().getFavorites();
  }

  void _refresh() {
    setState(() {
      _favoritesFuture = ApiService().getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Supabase.instance.client.auth.currentSession != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A08),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A08),
        foregroundColor: Colors.white,
        title: const Text(
          'Mis favoritos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _refresh,
          ),
        ],
      ),
      body: !isLoggedIn
          ? _buildNotLoggedIn()
          : FutureBuilder<List<Restaurant>>(
              future: _favoritesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF5C00)),
                  );
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                final favorites = snapshot.data ?? [];
                if (favorites.isEmpty) {
                  return _buildEmpty();
                }
                return _buildList(favorites);
              },
            ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Inicia sesión para ver\ntus favoritos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes favoritos',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pulsa el corazón en cualquier restaurante\npara guardarlo aquí',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 56),
          const SizedBox(height: 16),
          const Text(
            'No se pudieron cargar los favoritos',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _refresh,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF5C00)),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Restaurant> favorites) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: favorites.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final r = favorites[index];
        return _RestaurantTile(
          restaurant: r,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RestaurantScreen(restaurantId: r.id),
              ),
            );
            _refresh();
          },
        );
      },
    );
  }
}

class _RestaurantTile extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _RestaurantTile({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFFFF5C00).withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: Color(0xFFFF5C00), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.address,
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (r.googleRating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFF5C00), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${r.googleRating}',
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        if (r.priceLevel != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            '€' * r.priceLevel!,
                            style: const TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
