/// Dirección base de la API de CineMood (desplegada en Render).
const apiBaseUrl = 'https://cinemood-dxra.onrender.com';

/// En el plan gratuito de Render, la primera petición tras un rato sin uso
/// puede tardar cerca de un minuto mientras el servidor despierta.
const apiTimeout = Duration(seconds: 75);
