# Talleres Freightliner - App Móvil (Flutter)

Este es el proyecto frontend móvil para el sistema de gestión de Talleres Freightliner. Está construido utilizando Flutter y se conecta a la API REST construida en FastAPI.

## 🛠️ Requisitos Previos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versión 3.0 o superior)
- Dart SDK
- Android Studio / VS Code (con las extensiones de Flutter)

---

## 🚀 Guía de Instalación desde Cero

Si estás clonando el repositorio o quieres reconstruir el proyecto desde el principio, sigue estos comandos en tu terminal.

### 1. Crear el proyecto base
```bash
flutter create mobile --platforms android,ios
cd mobile
```

### 2. Instalar Librerías Principales
Estas librerías manejan el estado, las peticiones HTTP, rutas seguras y almacenamiento encriptado:
```bash
flutter pub add dio provider flutter_secure_storage go_router json_annotation
```

### 3. Instalar Librerías de Desarrollo (Dev Dependencies)
Necesarias para autogenerar código (como la lectura de JSON desde el backend):
```bash
flutter pub add --dev build_runner json_serializable
```

### 4. Generar la Estructura de Carpetas
Ejecuta este comando para crear toda la arquitectura limpia dentro de la carpeta `lib/`:
```bash
mkdir -p lib/core/network lib/core/storage lib/core/constants lib/core/errors lib/core/theme lib/models lib/repositories lib/providers lib/routes lib/screens/auth lib/screens/admin lib/screens/mechanic lib/screens/client lib/screens/shared lib/screens/splash lib/widgets/bottom_nav
```

---

## 📂 Arquitectura del Proyecto (`lib/`)

La aplicación sigue un patrón escalable basado en **Features y Roles**:

*   `core/`: Configuración central (Tema, Constantes de API, Interceptores HTTP de Dio, Manejo global de errores y Storage Seguro).
*   `models/`: Clases de datos (Espejos directos de Pydantic del backend).
*   `repositories/`: Capa de datos encargada exclusivamente de realizar peticiones a la API.
*   `providers/`: Capa de estado usando `ChangeNotifier` para actualizar la interfaz.
*   `routes/`: Archivo central de `go_router` con protecciones de redirección según si el usuario es Admin, Técnico o Cliente.
*   `screens/`: Pantallas organizadas por módulo o rol.
*   `widgets/`: Componentes UI reutilizables (Botones, TextFields, Menús de navegación inferior por rol).

---

## ⚙️ Generación de Código Automático
Cuando se modifiquen los `models` (para adaptar las respuestas JSON del backend), debes correr este comando para regenerar los serializadores:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
