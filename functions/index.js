/**
 * functions/index.js
 * -------------------------------------------
 * Cloud Function HTTPS que actúa de proxy para la Places API
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// ⬇️ Aquí empieza la definición -----------------------------
exports.nearbyVinylStores = onRequest(
  {
    region: "europe-west1",   // ← tu región
    cors: true,               // CORS abierto
    timeoutSeconds: 15,
    secrets: ["PLACES_KEY"],  // ← ¡IMPORTANTE! indica qué secreto usar
  },
  async (req, res) => {
    try {
      const { lat, lng, radius = 10000 } = req.query;
      if (!lat || !lng) {
        return res.status(400).json({ error: "coords missing (lat,lng)" });
      }

      const apiKey = process.env.PLACES_KEY;   // ya disponible
      if (!apiKey) {
        logger.error("PLACES_KEY undefined");
        return res.status(500).json({ error: "server misconfigured" });
      }

      const url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
        `?location=${lat},${lng}` +
        "&keyword=vinyl+record+store" +
        `&radius=${radius}` +
        `&key=${apiKey}`;

      const apiResp = await fetch(url);
      const data = await apiResp.json();

      res.json(data);
    } catch (err) {
      logger.error("nearbyVinylStores error", err);
      res.status(500).json({ error: "internal", details: err.message });
    }
  }
);
// ⬆️ Aquí termina la definición ------------------------------
