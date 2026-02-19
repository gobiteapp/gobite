import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/models/restaurant.dart';
import '../../core/providers/restaurants_provider.dart';

class RestaurantScreen extends ConsumerWidget {
  final String restaurantId;

  const RestaurantScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(selectedRestaurantProvider(restaurantId));

    return restaurantAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A0A08),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5C00))),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Color(0xFF0A0A08),
        body: Center(child: Text('Error: $e', style: TextStyle(color: Colors.white))),
      ),
      data: (restaurant) => _RestaurantDetail(restaurant: restaurant),
    );
  }
}

class _RestaurantDetail extends StatefulWidget {
  final Restaurant restaurant;
  const _RestaurantDetail({required this.restaurant});

  @override
  State<_RestaurantDetail> createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<_RestaurantDetail> {
  int _currentVideoIndex = 0;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final hasVideos = restaurant.videos.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A08),
      body: Stack(
        children: [
          // Video o placeholder
          if (hasVideos)
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: restaurant.videos.length,
              onPageChanged: (i) => setState(() => _currentVideoIndex = i),
              itemBuilder: (_, i) => _VideoPlayer(video: restaurant.videos[i]),
            )
          else
            Container(
              color: const Color(0xFF1C1C18),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.grey, size: 60),
                    SizedBox(height: 16),
                    Text('Sé el primero en añadir un vídeo',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            ),

          // Datos superpuestos abajo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (restaurant.googleRating != null) ...[
                        const Icon(Icons.star, color: Color(0xFFFF5C00), size: 18),
                        const SizedBox(width: 4),
                        Text('${restaurant.googleRating}',
                            style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(width: 16),
                      ],
                      if (restaurant.priceLevel != null)
                        Text('€' * restaurant.priceLevel!,
                            style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(restaurant.address,
                      style: const TextStyle(color: Colors.white60, fontSize: 14)),
                ],
              ),
            ),
          ),

          // Botón volver
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // Botón favorito
          Positioned(
            top: 50,
            right: 16,
            child: GestureDetector(
              onTap: () => setState(() => _isFavorite = !_isFavorite),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? const Color(0xFFFF5C00) : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  final Video video;
  const _VideoPlayer({required this.video});

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.video.tiktokUrl != null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.video.tiktokUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.video.tiktokUrl == null) {
      return const Center(child: Icon(Icons.videocam_off, color: Colors.grey, size: 60));
    }
    return WebViewWidget(controller: _controller);
  }
}