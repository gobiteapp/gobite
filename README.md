# # 🍽️ [NOMBRE POR DEFINIR] — App de Descubrimiento de Restaurantes

> Decide dónde comer en minutos viendo comida real cerca de ti.

![Estado](https://img.shields.io/badge/estado-planificación-yellow)
![Stack](https://img.shields.io/badge/stack-Flutter%20%7C%20NestJS%20%7C%20Supabase-blue)
![Ciudad](https://img.shields.io/badge/ciudad%20inicial-Sevilla-orange)

---

## 📖 Descripción

Aplicación móvil que permite descubrir y decidir dónde comer cerca en pocos minutos usando un mapa de restaurantes con vídeos cortos reales de creadores foodies.

**El problema que resuelve:** buscar restaurante hoy es lento y disperso. Los usuarios alternan entre Google Maps, TikTok e Instagram sin llegar a una decisión rápida. Esta app unifica el mapa y el vídeo en el mismo flujo, sin saltar entre plataformas.

**Objetivo:** elegir restaurante en menos de 4 minutos.

---

## ✨ Funcionalidades del MVP

- 📍 Detección de ubicación y mapa centrado en el usuario
- 🫧 Burbujas en el mapa con frame estático del vídeo de cada restaurante
- 🎬 Ficha de restaurante con vídeos en vertical a pantalla completa
- 🖼️ Fallback a fotos de Google Places cuando no hay vídeos disponibles
- ❤️ Botón de favoritos de un solo tap
- 🔐 Login básico (Google o anónimo)
- 🗺️ 20–30 restaurantes iniciales en Sevilla

---

## 🛠️ Stack Técnico

| Capa | Tecnología | Motivo |
|------|-----------|--------|
| App móvil | Flutter | iOS + Android desde una base de código |
| Backend | NestJS | Estructura por módulos/servicios/controladores |
| Base de datos / Auth | Supabase (PostgreSQL) | Auth lista, API automática, CRUD estándar |
| Datos iniciales | Google Places API | Puntuación, fotos y metadatos en frío |
| Procesamiento de tickets | GPT-4 Vision / Gemini | Extracción de datos sin OCR propio |
| Vídeos MVP | Embeds oficiales de TikTok | Sin alojar vídeo propio en esta fase |

---

## 🗂️ Estructura del Proyecto

```
/
├── mobile/          # App Flutter (iOS + Android)
├── backend/         # API en NestJS
│   ├── src/
│   │   ├── restaurants/
│   │   ├── videos/
│   │   ├── users/
│   │   ├── tickets/
│   │   └── reviews/
├── docs/            # Documentación del proyecto
└── README.md
```

> ⚠️ La estructura de módulos de NestJS está pendiente de definir en detalle.

---

## 🚀 Instalación y Puesta en Marcha

### Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.x
- [Node.js](https://nodejs.org/) >= 18.x
- [NestJS CLI](https://docs.nestjs.com/) (`npm install -g @nestjs/cli`)
- Cuenta en [Supabase](https://supabase.com/)
- API Keys: Google Places, OpenAI (GPT-4 Vision) o Google Gemini

### Backend (NestJS)

```bash
cd backend
npm install
cp .env.example .env   # Rellenar variables de entorno
npm run start:dev
```

### App móvil (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## ⚙️ Variables de Entorno

Crea un archivo `.env` en la carpeta `backend/` con las siguientes claves:

```env
SUPABASE_URL=
SUPABASE_KEY=
GOOGLE_PLACES_API_KEY=
OPENAI_API_KEY=          # Para GPT-4 Vision (procesamiento de tickets)
```

---

## 🗺️ Hoja de Ruta

### MVP (en curso)
- [x] Documento de proyecto v1.0
- [ ] Definición del modelo de datos en Supabase
- [ ] Arquitectura de módulos NestJS
- [ ] Mapa con burbujas de restaurantes
- [ ] Ficha de restaurante con vídeos embebidos de TikTok
- [ ] Login con Google / anónimo
- [ ] Carga manual de 20–30 restaurantes en Sevilla

### Post-MVP
- [ ] Validación comunitaria de vídeos (validar / denunciar)
- [ ] Subida de tickets para verificar visitas
- [ ] Reseñas verificadas con sistema de reputación por categoría
- [ ] Crowdsourcing de URLs de vídeos por usuarios
- [ ] Filtros avanzados (alérgenos, precio, tipo de cocina, distancia)
- [ ] Modo descubrir — navegación lineal sin mapa
- [ ] Rutas temáticas (croquetas, brunch, sushi…)
- [ ] Rankings semanales y mensuales
- [ ] Perfiles sociales y reservas integradas

---

## 🔒 Sistema de Reputación

Las reseñas se validan mediante **foto del ticket**, procesada por IA para extraer:
- Fecha y hora de la visita
- Nombre del restaurante
- Total y precio medio por persona
- Platos pedidos (ranking de platos más populares)

Esto garantiza que solo quien ha comido en el sitio puede opinar con peso real.

---

## ⚠️ Decisiones Pendientes

- [ ] Nombre definitivo de la app
- [ ] Diseño visual y branding (paleta, tipografía, icono)
- [ ] Modelo de datos definitivo en Supabase
- [ ] Política de privacidad y términos (tickets y geolocalización)
- [ ] Criterios de selección de los 20–30 restaurantes iniciales
- [ ] Estrategia de captación de primeros 50 usuarios

---

## 👥 Equipo

| Nombre | Rol |
|--------|-----|
| —      | —   |

---

## 📄 Licencia

Uso interno · Confidencial · © 2026
