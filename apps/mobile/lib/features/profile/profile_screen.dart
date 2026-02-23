import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/restaurant.dart';
import '../../core/services/api_service.dart';
import '../restaurant/restaurant_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  List<Restaurant>? _favorites;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await ApiService().getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                   const Text(
                    'Mis Favoritos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_favorites != null && _favorites!.isNotEmpty)
                    Text(
                      '${_favorites!.length} sitios',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFFF5C00))),
            )
          else if (_favorites == null || _favorites!.isEmpty)
            _buildEmptyState()
          else
            _buildFavoritesGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)), // Espacio para la nav bar
      ],
    );
  }

  Widget _buildSliverAppBar(User? user) {
    return SliverAppBar(
      expandedHeight: 280,
      backgroundColor: const Color(0xFF0A0A08),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo con gradiente "apetecible"
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2C1810), // Chocolate oscuro
                    Color(0xFF0A0A08),
                  ],
                ),
              ),
            ),
            // Círculos decorativos
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5C00).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Info del usuario
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF5C00), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 40, // Reducido de 45
                    backgroundColor: const Color(0xFF1C1C18),
                    backgroundImage: user?.userMetadata?['avatar_url'] != null
                        ? NetworkImage(user!.userMetadata!['avatar_url'])
                        : null,
                    child: user?.userMetadata?['avatar_url'] == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white24)
                        : null,
                  ),
                ),
                const SizedBox(height: 8), // Reducido de 12
                Text(
                  user?.userMetadata?['full_name'] ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Reducido de 22
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13, // Reducido de 14
                  ),
                ),
                const SizedBox(height: 12),
                _buildLogoutButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        await _supabase.auth.signOut();
      },
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Cerrar Sesión'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, color: Colors.white.withOpacity(0.1), size: 80),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes favoritos',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Podríamos navegar al mapa aquí si fuera necesario
              },
              child: const Text('¡Empieza a explorar!', style: TextStyle(color: Color(0xFFFF5C00))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final restaurant = _favorites![index];
            return _FavoriteCard(restaurant: restaurant);
          },
          childCount: _favorites!.length,
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Restaurant restaurant;

  const _FavoriteCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantScreen(restaurantId: restaurant.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen/Placeholder apetecible
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFF5C00).withOpacity(0.2),
                          const Color(0xFF1C1C18),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white10, size: 40),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.favorite, color: const Color(0xFFFF5C00), size: 20),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF5C00), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.googleRating?.toString() ?? 'N/A',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      if (restaurant.priceLevel != null)
                        Text(
                          '€' * restaurant.priceLevel!,
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
