# GoBite — CLAUDE.md

> **Regla de mantenimiento:** Este archivo debe actualizarse cada vez que se realice un cambio significativo en el proyecto: nueva feature, cambio de arquitectura, nueva dependencia, decisión técnica relevante, cambio en el modelo de datos o en los endpoints. Añade siempre una entrada en el [Historial de cambios](#historial-de-cambios) al final del archivo.

## ¿Qué es este proyecto?
App móvil de descubrimiento de restaurantes en Sevilla. El usuario abre un mapa con pines de restaurantes cercanos, toca uno y ve sus vídeos de TikTok. Incluye sistema de reputación basado en tickets/facturas procesadas con IA (en desarrollo).

**Rama principal:** `main` | **Rama de desarrollo:** `develop`

---

## Stack tecnológico

### Mobile — Flutter (`apps/mobile/`)
| Librería | Versión | Uso |
|---|---|---|
| Flutter / Dart | 3.11+ | Framework |
| flutter_riverpod | 2.0 | State management |
| supabase_flutter | 2.0 | Auth + sesiones |
| flutter_map | 6.0 | Mapa interactivo |
| geolocator | 11.0 | GPS del dispositivo |
| dio | 5.0 | HTTP client |
| webview_flutter | 4.0 | Embed TikTok |
| latlong2 | 0.9 | Coordenadas |

**UI:** Material 3 · dark theme · naranja `#FF5C00`

### Backend — NestJS (`backend/`)
| Tecnología | Versión | Uso |
|---|---|---|
| NestJS / Express | 11.0 | API REST |
| TypeScript | 5.7 | Lenguaje |
| Prisma | 6.19 | ORM + migraciones |
| PostgreSQL | — | BD (vía Supabase) |
| Supabase | — | Auth + BD |
| Jest / Supertest | 30.0 | Testing |

---

## Estructura de carpetas

```
gobite/
├── apps/
│   ├── mobile/                   # Flutter app
│   │   └── lib/
│   │       ├── main.dart         # Entry point, auth routing
│   │       ├── core/
│   │       │   ├── models/       # Restaurant, Video DTOs
│   │       │   ├── providers/    # Riverpod providers
│   │       │   └── services/     # ApiService (Dio)
│   │       └── features/
│   │           ├── auth/         # AuthScreen
│   │           ├── map/          # MapScreen
│   │           └── restaurant/   # RestaurantScreen
│   └── web/                      # Placeholder vacío
├── backend/
│   ├── src/
│   │   ├── auth/                 # Guard JWT + Supabase
│   │   ├── restaurants/          # CRUD + geoloc
│   │   ├── users/                # Sync + perfil
│   │   ├── favorites/            # Favoritos
│   │   ├── videos/               # Moderación vídeos
│   │   ├── tickets/              # Facturas/OCR
│   │   ├── prisma/               # PrismaService global
│   │   └── scripts/              # seed-restaurants.ts
│   └── prisma/
│       ├── schema.prisma         # Fuente de verdad BD
│       └── migrations/           # SQL versionado
├── supabase/                     # Migraciones (vacío, gestionado desde dashboard)
└── CLAUDE.md
```

---

## Modelo de datos (Prisma)

```
User (id, email, name, avatarUrl)
  ├── Favorite (userId, restaurantId) ← unique(userId, restaurantId)
  ├── Review (userId, restaurantId, rating, weight, verified)
  └── Ticket (userId, restaurantId, status, imageUrl, totalAmount)

Restaurant (id, name, address, lat, lng, googlePlaceId, googleRating, priceLevel)
  └── Video (restaurantId, source, tiktokUrl, status)
```

**Enums:**
- `VideoSource`: TIKTOK | UPLOAD
- `VideoStatus`: PENDING | APPROVED | REJECTED
- `TicketStatus`: PENDING | PROCESSING | COMPLETED | FAILED

---

## API Endpoints

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | /restaurants | No | Lista por geoloc (lat, lng, radius=5km) |
| GET | /restaurants/:id | No | Detalle + vídeos APPROVED |
| POST | /users/sync | Sí | Upsert usuario desde Supabase |
| GET | /users/me | Sí | Perfil del usuario |
| PUT | /users/me | Sí | Actualizar perfil |
| GET | /favorites | Sí | Favoritos del usuario |
| POST | /favorites/:restaurantId | Sí | Añadir favorito |
| DELETE | /favorites/:restaurantId | Sí | Quitar favorito |
| GET | /videos/restaurant/:id | No | Vídeos de un restaurante |
| POST | /videos | Sí | Subir vídeo (PENDING) |
| PATCH | /videos/:id/approve | Sí | Aprobar vídeo |
| PATCH | /videos/:id/reject | Sí | Rechazar vídeo |
| GET | /tickets | Sí | Tickets del usuario |
| POST | /tickets | Sí | Subir ticket/factura |

---

## Variables de entorno

### Backend (`backend/.env`)
```env
PORT=3000
DATABASE_URL=postgresql://...
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...
GOOGLE_PLACES_API_KEY=...
OPENAI_API_KEY=...          # Para GPT-4 Vision (tickets)
```

### Mobile (`apps/mobile/lib/main.dart`)
> ⚠️ Actualmente hardcodeadas en `main.dart`. Pendiente migrar a `.env` o archivo de configuración.
```dart
supabaseUrl: 'https://xxx.supabase.co'
supabaseAnonKey: '...'
```

---

## Comandos importantes

### Backend
```bash
cd backend
npm run start:dev        # Desarrollo con hot-reload
npm run start:prod       # Producción
npm run build            # Compilar TypeScript
npm run lint             # ESLint con auto-fix
npm run format           # Prettier
npm test                 # Tests unitarios
npm run test:e2e         # Tests E2E
npx prisma migrate dev   # Aplicar migraciones
npx prisma studio        # GUI de la BD
npx ts-node src/scripts/seed-restaurants.ts  # Seed datos Sevilla
```

### Mobile
```bash
cd apps/mobile
flutter pub get          # Instalar dependencias
flutter run              # Lanzar en simulador/dispositivo
flutter build apk        # Build Android
flutter build ios        # Build iOS
flutter analyze          # Análisis estático
```

---

## Convenciones de código

### Backend (NestJS)
- **Estilo:** Single quotes, trailing commas, Prettier automático
- **Estructura:** Un módulo por feature (module / controller / service / spec)
- **Auth:** Usar `@UseGuards(AuthGuard)` en endpoints protegidos
- **BD:** Siempre usar PrismaService (nunca SQL raw salvo necesidad)
- **Nuevos endpoints:** Añadir spec test junto al módulo

### Mobile (Flutter)
- **State:** Riverpod — FutureProvider para async, StateProvider para UI local
- **Screens:** `ConsumerStatefulWidget` si necesita Riverpod + lifecycle
- **HTTP:** Todo a través de `ApiService` (no usar Dio directamente en widgets)
- **Rutas:** Push/replacement directo (sin GoRouter por ahora)
- **Tema:** Material 3, dark, siempre usar `Theme.of(context).colorScheme`

---

## Decisiones técnicas

| Decisión | Motivo |
|---|---|
| Supabase solo para auth | Simplifica la gestión de sesiones; el backend verifica JWTs con `SUPABASE_SERVICE_ROLE_KEY` |
| Tabla `User` propia en Prisma | Permite datos extra (name, avatarUrl) sin depender de Supabase |
| Haversine en memoria (no PostGIS) | Suficiente para pocos restaurantes; cuando escale, migrar a PostGIS |
| Vídeos con moderación PENDING→APPROVED | Evita contenido inapropiado; falta panel admin |
| MapTiler (no OSM directo) | Mejor calidad de tiles para dark mode |
| Sin routing avanzado en Flutter | Correcto para el tamaño actual; migrar a GoRouter cuando crezca |
| Riverpod (no Bloc/Redux) | Más simple y reactivo para este tamaño de app |

---

## Estado actual de features

| Feature | Estado | Notas |
|---|---|---|
| Auth email + Google OAuth | ✅ Completo | |
| Mapa interactivo con pines | ✅ Completo | MapTiler dark |
| User sync Supabase ↔ Prisma | ✅ Completo | En sign-in |
| 10 restaurantes seed (Sevilla reales) | ✅ Completo | Eslava, La Brunilda, etc. |
| Detalle restaurante + vídeos TikTok | ✅ UI completa | |
| Favoritos | ⚠️ Parcial | API lista; UI no persiste al salir |
| Reviews | ⚠️ Parcial | Esquema BD listo; sin endpoint ni UI |
| Apple Sign-In | ⚠️ Parcial | UI lista; falta configuración Apple Developer |
| Tickets / OCR con IA | ❌ Pendiente | |
| Panel de moderación vídeos | ❌ Pendiente | |
| CI/CD | ❌ Pendiente | |
| Push notifications | ❌ Pendiente | |

---

## Historial de cambios

| Fecha | Descripción |
|---|---|
| 2026-02-22 | Creación del archivo CLAUDE.md con análisis completo del proyecto: stack, estructura, endpoints, convenciones y estado de features |
| 2026-02-22 | `api_service.dart`: cambiado `baseUrl` de `localhost:3000` a `10.0.2.2:3000` para compatibilidad con emulador Android |
| 2026-02-22 | `map_screen.dart`: corregido flujo de permisos — `checkPermission()` antes de `requestPermission()`, manejo de `deniedForever`, `mounted` check |
| 2026-02-22 | `map_screen.dart`: añadido `isLocationServiceEnabled()`, `getLastKnownPosition()`, timeout 10s en `getCurrentPosition()` y fallback al centro de Sevilla |
| 2026-02-22 | `AndroidManifest.xml`: añadido permiso `INTERNET` — sin él Android bloquea todas las llamadas de red |
| 2026-02-22 | `restaurant_screen.dart`: WebView con embed URL de TikTok (`/embed/v2/ID`), `Positioned.fill` para pantalla completa, `setBackgroundColor(black)`, `MutationObserver` para eliminar banner de cookies del DOM, CSS agresivo para ocultar perfil/botones/música/descripción y forzar vídeo a `100vw x 100vh` |
