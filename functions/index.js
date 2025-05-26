/**
 * functions/index.js
 * -------------------------------------------
 * Cloud Function HTTPS que actúa de proxy para la Places API
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

exports.nearbyVinylStores = onRequest(
  {
    region: "europe-west1",   // tu región
    cors: true,               // habilita CORS
    timeoutSeconds: 15,
    secrets: ["PLACES_KEY"],  // el secreto que contiene tu API key
  },
  async (req, res) => {
    try {
      // Parámetros de consulta
      const { lat, lng } = req.query;
      const radius = parseInt(req.query.radius, 10) || 10000;

      if (!lat || !lng) {
        return res.status(400).json({ error: "Faltan coordenadas (lat,y lng)" });
      }

      // Recupera el API key del secreto
      const apiKey = process.env.PLACES_KEY;
      if (!apiKey) {
        logger.error("PLACES_KEY no definida");
        return res.status(500).json({ error: "Configuración del servidor incorrecta" });
      }

      // Construye la URL de la API de Google Places
      const url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
        `?location=${encodeURIComponent(lat)},${encodeURIComponent(lng)}` +
        `&radius=${encodeURIComponent(radius)}` +
        "&keyword=vinyl+record+store" +
        `&key=${encodeURIComponent(apiKey)}`;

      // Llama a la API externa
      const apiResp = await fetch(url);
      if (!apiResp.ok) {
        const errText = await apiResp.text();
        logger.error("Error en Places API:", apiResp.status, errText);
        return res.status(apiResp.status).json({ error: errText });
      }

      // Devuelve el resultado directamente
      const data = await apiResp.json();
      return res.status(200).json(data);

    } catch (err) {
      logger.error("nearbyVinylStores error:", err);
      return res.status(500).json({ error: "Error interno", details: err.message });
    }
  }
);
