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
// functions/index.js
/**
 * Cloud Functions HTTPS para proxy de imágenes y Places API
 * Usando fetch global de Node 18+
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// ────────────────
// 1) Proxy de imágenes con CORS (Cloud Function v2)
// ────────────────
exports.imageProxy = onRequest(
  {
    region: "europe-west1",  // Región Europa
    cors: true,              // CORS abierto
    timeoutSeconds: 60,      // Tiempo máximo de ejecución
  },
  async (req, res) => {
    try {
      const url = req.query.url;
      if (!url) {
        res.status(400).send("Missing url param");
        return;
      }

      // Usamos el fetch global
      const apiResp = await fetch(url);
      if (!apiResp.ok) {
        logger.error(`imageProxy: HTTP ${apiResp.status} for ${url}`);
        res.status(apiResp.status).send(`Proxy error: ${apiResp.status}`);
        return;
      }

      const buffer = await apiResp.arrayBuffer();
      const contentType = apiResp.headers.get("content-type") || "image/jpeg";

      res
        .set("Access-Control-Allow-Origin", "*")
        .set("Content-Type", contentType)
        .send(Buffer.from(buffer));
    } catch (err) {
      logger.error("imageProxy internal error:", err);
      res.status(500).send("Internal proxy error");
    }
  }
);

// ────────────────
// 2) Proxy para Places API (buscar tiendas de vinilo)
// ────────────────
exports.nearbyVinylStores = onRequest(
  {
    region: "europe-west1",   // Región Europa
    cors: true,               // CORS abierto
    timeoutSeconds: 15,
    secrets: ["PLACES_KEY"],  // Nombre del secreto en Firebase
  },
  async (req, res) => {
    try {
      const { lat, lng, radius = 10000 } = req.query;
      if (!lat || !lng) {
        return res.status(400).json({ error: "coords missing (lat,lng)" });
      }

      const apiKey = process.env.PLACES_KEY;
      if (!apiKey) {
        logger.error("nearbyVinylStores: PLACES_KEY undefined");
        return res.status(500).json({ error: "server misconfigured" });
      }

      const url =
        `https://maps.googleapis.com/maps/api/place/nearbysearch/json` +
        `?location=${lat},${lng}` +
        `&keyword=vinyl+record+store` +
        `&radius=${radius}` +
        `&key=${apiKey}`;

      const apiResp = await fetch(url);
      const data = await apiResp.json();
      res.json(data);
    } catch (err) {
      logger.error("nearbyVinylStores internal error:", err);
      res.status(500).json({ error: "internal", details: err.message });
    }
  }
);
