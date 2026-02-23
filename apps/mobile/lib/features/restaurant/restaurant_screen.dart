import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../core/models/restaurant.dart';
import '../../core/providers/restaurants_provider.dart';
import '../../core/services/api_service.dart';

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
  bool _isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    if (Supabase.instance.client.auth.currentSession == null) return;
    try {
      final favorites = await ApiService().getFavorites();
      if (mounted) {
        setState(() => _isFavorite = favorites.any((r) => r.id == widget.restaurant.id));
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (Supabase.instance.client.auth.currentSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para guardar favoritos'),
          backgroundColor: Color(0xFF1C1C18),
        ),
      );
      return;
    }
    if (_isFavoriteLoading) return;
    final newValue = !_isFavorite;
    setState(() { _isFavorite = newValue; _isFavoriteLoading = true; });
    try {
      if (newValue) {
        await ApiService().addFavorite(widget.restaurant.id);
      } else {
        await ApiService().removeFavorite(widget.restaurant.id);
      }
    } catch (_) {
      if (mounted) setState(() => _isFavorite = !newValue);
    } finally {
      if (mounted) setState(() => _isFavoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final hasVideos = restaurant.videos.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A08),
      body: Stack(
        children: [
          // Video o placeholder — Positioned.fill garantiza que ocupa todo el Stack
          Positioned.fill(
            child: hasVideos
                ? PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: restaurant.videos.length,
                    onPageChanged: (i) => setState(() => _currentVideoIndex = i),
                    itemBuilder: (_, i) => _VideoPlayer(video: restaurant.videos[i]),
                  )
                : Container(
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
          ),

          // Datos superpuestos abajo — IgnorePointer para no bloquear el swipe del PageView
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
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
              onTap: _toggleFavorite,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: _isFavoriteLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? const Color(0xFFFF5C00) : Colors.white,
                        size: 28,
                      ),
              ),
            ),
          ),

          // Indicador de vídeos (solo si hay más de uno)
          if (hasVideos && restaurant.videos.length > 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    restaurant.videos.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      width: 4,
                      height: _currentVideoIndex == i ? 20 : 8,
                      decoration: BoxDecoration(
                        color: _currentVideoIndex == i
                            ? const Color(0xFFFF5C00)
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
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
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  String? _videoId;

  /// Extrae el ID numérico de vídeo de una URL de TikTok.
  String? _extractVideoId(String url) {
    final match = RegExp(r'/video/(\d+)').firstMatch(url);
    return match?.group(1);
  }

  /// HTML wrapper que embebe el vídeo en un <iframe allow="autoplay">.
  /// Esto deja que el player JavaScript de TikTok gestione la reproducción.
  String _buildEmbedHtml(String videoId) => '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    html,body{width:100vw;height:100vh;background:#000;overflow:hidden}
    #tk{position:fixed;top:0;left:0;width:100%;height:100%;border:0}
  </style>
</head>
<body>
  <iframe id="tk"
    src="https://www.tiktok.com/embed/v2/$videoId?autoplay=1&music_info=0&description=0"
    allow="autoplay; fullscreen; encrypted-media"
    allowfullscreen scrolling="no" frameborder="0">
  </iframe>
  <script>
    var frame=document.getElementById('tk'), done=false;
    function notify(msg){
      if(!done&&typeof GoBiteLog!=='undefined'){done=true;GoBiteLog.postMessage(msg);}
    }
    frame.addEventListener('load',function(){setTimeout(function(){notify('tiktok_loaded');},800);});
    frame.addEventListener('error',function(){notify('tiktok_error');});
    setTimeout(function(){notify('tiktok_loaded');},10000);
  </script>
</body>
</html>''';

  @override
  void initState() {
    super.initState();
    final originalUrl = widget.video.tiktokUrl;
    if (originalUrl == null) return;

    _videoId = _extractVideoId(originalUrl);
    if (_videoId == null) {
      debugPrint('No se pudo extraer el ID del vídeo: $originalUrl');
      return;
    }

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        'GoBiteLog',
        onMessageReceived: (message) {
          debugPrint('WebLog: ${message.message}');
          if (!mounted) return;
          if (message.message == 'tiktok_loaded') {
            setState(() => _isLoading = false);
          } else if (message.message == 'tiktok_error') {
            setState(() { _hasError = true; _isLoading = false; });
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() { _isLoading = true; _hasError = false; });
        },
        onPageFinished: (_) {
          // Nuestro HTML wrapper cargó; TikTok sigue cargando dentro del iframe.
          // _isLoading se gestiona desde GoBiteLog ('tiktok_loaded').
        },
        onWebResourceError: (error) {
          debugPrint('WebError: ${error.description}');
          if (error.isForMainFrame == true) {
            if (mounted) setState(() { _hasError = true; _isLoading = false; });
          }
        },
      ));

    // Permitir reproducción automática sin interacción del usuario (Autoplay) en Android
    final platform = _controller!.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller!.loadHtmlString(_buildEmbedHtml(_videoId!));
  }

  Widget _buildLoadingOverlay() {
    return AnimatedOpacity(
      opacity: _isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: IgnorePointer(
        ignoring: !_isLoading,
        child: Container(
          color: const Color(0xFF0A0A08),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFFFF5C00),
                  strokeWidth: 2.5,
                ),
                const SizedBox(height: 20),
                Text(
                  'Cargando vídeo...',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: const Color(0xFF0A0A08),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_off_rounded, color: Colors.white.withOpacity(0.3), size: 52),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar el vídeo',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Comprueba tu conexión',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
            const SizedBox(height: 24),
            if (_retryCount < 3)
              TextButton(
                onPressed: _retry,
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF5C00)),
                child: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }

  void _retry() {
    if (_videoId == null) return;
    setState(() { _isLoading = true; _hasError = false; _retryCount++; });
    _controller?.loadHtmlString(_buildEmbedHtml(_videoId!));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: Icon(Icons.videocam_off, color: Colors.grey, size: 60));
    }
    if (_hasError && !_isLoading) {
      return _buildErrorWidget();
    }
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          WebViewWidget(controller: _controller!),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }
}
