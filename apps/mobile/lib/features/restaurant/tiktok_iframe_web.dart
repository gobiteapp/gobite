import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

final _registeredViews = <String>{};

void registerTikTokView(String viewId, String videoId) {
  if (_registeredViews.contains(viewId)) return;
  _registeredViews.add(viewId);
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
    iframe.src = 'https://www.tiktok.com/embed/v2/$videoId';
    iframe.style.border = 'none';
    iframe.style.width = '100%';
    iframe.style.height = '100%';
    iframe.allowFullscreen = true;
    return iframe;
  });
}
