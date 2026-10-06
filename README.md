# CineMood (Flutter) · Flujo de pantallas

Recomendaciones de películas y series según estado de ánimo, géneros, tipo de contenido y tiempo disponible, con porcentaje de compatibilidad.

## Cómo ejecutarlo
```bash
cd cinemood
flutter create . --platforms=android   # genera la carpeta android/ (solo la primera vez)
flutter pub get
flutter run
```

## Flujo de pantallas
```
Login ──► Mood ──► Principal (Inicio · Explorar · Mi lista · Perfil)
  │                     │
  └─► Registro ─► Gustos ─► Mood
                        Inicio/Explorar/Mi lista/Historial ─► Detalle
                        Perfil ─► Editar preferencias (Gustos) · Cambiar mood · Historial · Cerrar sesión
```

## Arquitectura por capas (lib/)
| Carpeta | Qué guarda |
|---|---|
| `models/` | Clases de datos: Contenido, Usuario, Preferencias, EstadoAnimo, Recomendacion |
| `data/` | Catálogo de ejemplo (luego lo reemplaza la API) |
| `services/` | `RecomendacionService`: cálculo de compatibilidad |
| `providers/` | `AppProvider`: sesión, preferencias, mood, mi lista, historial |
| `screens/` | Las 10 pantallas del mockup + contenedor con barra inferior |
| `widgets/` | Piezas reutilizables (botón, campo, chips, tarjetas) |
| `utils/` | Colores, formatos y nombres de rutas |

Dependencias: las pantallas usan providers/widgets/models; los modelos nunca importan pantallas.

## Compatibilidad
Estado de ánimo 50 % · género 20 % · tiempo 15 % · valoración 15 %.
