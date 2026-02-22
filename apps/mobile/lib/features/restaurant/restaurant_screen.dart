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
  WebViewController? _controller;

  /// Convierte una URL normal de TikTok en la URL del embed oficial.
  /// https://www.tiktok.com/@user/video/12345 → https://www.tiktok.com/embed/v2/12345
  String _toEmbedUrl(String url) {
    final match = RegExp(r'/video/(\d+)').firstMatch(url);
    if (match != null) {
      return 'https://www.tiktok.com/embed/v2/${match.group(1)}';
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    final originalUrl = widget.video.tiktokUrl;
    if (originalUrl == null) return;

    final embedUrl = _toEmbedUrl(originalUrl);
    final uri = Uri.tryParse(embedUrl);
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      debugPrint('URL de vídeo inválida: $embedUrl');
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final dest = Uri.tryParse(request.url);
          if (dest == null || (dest.scheme != 'https' && dest.scheme != 'http')) {
            debugPrint('WebView bloqueó deep link: ${request.url}');
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (_) => _injectCleanup(),
      ))
      ..loadRequest(uri);
  }

  Future<void> _injectCleanup() async {
    await _controller?.runJavaScript(r'''
      (function() {

        // ============================================================
        // PRIORIDAD 1: COOKIES
        // Eliminar el banner del DOM + MutationObserver para detectarlo
        // cuando aparece tarde (TikTok lo inyecta de forma asíncrona)
        // ============================================================
        function removeCookieBanner() {
          const selectors = [
            '[data-e2e="cookie-banner"]',
            '[class*="CookieBanner"]',
            '[class*="cookie-banner"]',
            '[class*="DivConsent"]',
            '[class*="ConsentBanner"]',
            '[class*="consent-modal"]',
            '[class*="tiktok-cookie"]',
            '[id*="cookie"]',
            '[id*="consent"]',
          ];
          selectors.forEach(sel =>
            document.querySelectorAll(sel).forEach(el => el.remove())
          );
          // Fallback: click en botón de aceptar todo usando dispatchEvent
          // (btn.click() puede ser bloqueado por React; dispatchEvent no)
          document.querySelectorAll('button').forEach(btn => {
            const t = (btn.textContent || '').trim().toLowerCase();
            if (t === 'allow all' || t === 'accept all' || t === 'aceptar todo' ||
                t.includes('allow all') || t.includes('accept all')) {
              btn.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true, view: window }));
            }
          });
          // Guardar consentimiento en localStorage para evitar que reaparezca
          try { localStorage.setItem('tt_consent_v2', '1'); } catch(e) {}
        }

        removeCookieBanner();

        // Observer activo 15s — detecta el banner si aparece tarde
        const cookieObserver = new MutationObserver(() => removeCookieBanner());
        cookieObserver.observe(document.documentElement, { childList: true, subtree: true });
        setTimeout(() => cookieObserver.disconnect(), 15000);

        // ============================================================
        // PRIORIDAD 2 + 3: TAMAÑO Y ELEMENTOS SOBRANTES
        // CSS inyectado una sola vez
        // ============================================================
        if (document.getElementById('gobite-clean')) return;

        const css = `
          html, body {
            width: 100vw !important;
            height: 100vh !important;
            margin: 0 !important;
            padding: 0 !important;
            background: #000 !important;
            overflow: hidden !important;
          }

          /* Contenedor raíz de TikTok embed: forzar a pantalla completa */
          body > div {
            width: 100vw !important;
            max-width: 100vw !important;
            height: 100vh !important;
            max-height: 100vh !important;
            margin: 0 !important;
            border-radius: 0 !important;
            overflow: hidden !important;
          }

          /* El vídeo ocupa toda la pantalla */
          video {
            width: 100vw !important;
            height: 100vh !important;
            max-width: 100vw !important;
            max-height: 100vh !important;
            object-fit: cover !important;
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            z-index: 1 !important;
          }

          /* Ocultar: foto + nombre del creador (arriba) */
          [class*="AuthorInfo"],
          [class*="DivAuthor"],
          [class*="AuthorAvatar"],
          [class*="AuthorName"],
          [class*="UserAvatar"],
          [class*="DivUserInfo"],
          [class*="UniqueId"],

          /* Ocultar: botones de la derecha (like, comment, share, follow) */
          [class*="ActionItemContainer"],
          [class*="DivActionItem"],
          [class*="SideBar"],
          [class*="DivSideBar"],
          [class*="ActionBar"],

          /* Ocultar: descripción y hashtags */
          [class*="DescriptionContainer"],
          [class*="DivCaption"],
          [class*="DivDesc"],
          [class*="SpanHashtag"],
          [class*="SpanHashTag"],

          /* Ocultar: información de música */
          [class*="MusicInfo"],
          [class*="DivMusic"],
          [class*="MusicCard"],

          /* Ocultar: 'Watch now' / 'View profile' / 'Watch on TikTok' */
          [class*="WatchNow"],
          [class*="ViewProfile"],
          [class*="WatchOnTikTok"],
          [class*="FollowButton"],

          /* Ocultar: header y footer del embed */
          [class*="EmbedHeader"],
          [class*="DivHeader"],
          [class*="EmbedFooter"],
          [class*="DivFooter"],

          /* Ocultar: nombre de usuario abajo */
          [class*="DivUsername"],

          /* Ocultar: cookies y consent (por si el observer falla) */
          [class*="cookie"], [class*="Cookie"],
          [class*="consent"], [class*="Consent"],
          [id*="cookie"], [id*="consent"] {
            display: none !important;
          }

          /* Mantener controles de vídeo visibles encima del vídeo */
          [class*="PlayerControl"],
          [class*="player-control"],
          [class*="Controls"],
          [class*="controls"] {
            z-index: 2 !important;
            position: relative !important;
          }
        `;

        const style = document.createElement('style');
        style.id = 'gobite-clean';
        style.textContent = css;
        document.head.appendChild(style);

      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: Icon(Icons.videocam_off, color: Colors.grey, size: 60));
    }
    return SizedBox.expand(
      child: WebViewWidget(controller: _controller!),
    );
  }
}