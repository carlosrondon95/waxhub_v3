/**
 * functions/index.js
 * -------------------------------------------
 * 1) HTTP proxy para Google Places (v2 HTTPS)
 * 2) Trigger Firestore (v2) para envío de correos al crear feedback
 */

const { onRequest }         = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger                = require("firebase-functions/logger");
const functionsLegacy       = require("firebase-functions"); // para config()
const admin                 = require("firebase-admin");
const nodemailer            = require("nodemailer");

// Inicializa Admin SDK
admin.initializeApp();

// ────────────────────────────────────────────────────────────────────────
// 1) HTTP proxy para Google Places
// ────────────────────────────────────────────────────────────────────────

exports.nearbyVinylStores = onRequest(
  {
    region: "europe-west1",
    cors: true,
    timeoutSeconds: 15,
    secrets: ["PLACES_KEY"],
  },
  async (req, res) => {
    try {
      const { lat, lng } = req.query;
      const radius = parseInt(req.query.radius, 10) || 10000;

      if (!lat || !lng) {
        return res
          .status(400)
          .json({ error: "Faltan coordenadas (lat, lng)" });
      }

      const apiKey = process.env.PLACES_KEY;
      if (!apiKey) {
        logger.error("PLACES_KEY no definida");
        return res
          .status(500)
          .json({ error: "Configuración del servidor incorrecta" });
      }

      const url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
        `?location=${encodeURIComponent(lat)},${encodeURIComponent(lng)}` +
        `&radius=${encodeURIComponent(radius)}` +
        "&keyword=vinyl+record+store" +
        `&key=${encodeURIComponent(apiKey)}`;

      const apiResp = await fetch(url);
      if (!apiResp.ok) {
        const errText = await apiResp.text();
        logger.error("Error en Places API:", apiResp.status, errText);
        return res.status(apiResp.status).json({ error: errText });
      }

      const data = await apiResp.json();
      return res.status(200).json(data);
    } catch (err) {
      logger.error("nearbyVinylStores error:", err);
      return res
        .status(500)
        .json({ error: "Error interno", details: err.message });
    }
  }
);

// ────────────────────────────────────────────────────────────────────────
// 2) Trigger Firestore (v2) para enviar correo de soporte
// ────────────────────────────────────────────────────────────────────────

const gmailUser    = functionsLegacy.config().gmail.user;
const gmailPass    = functionsLegacy.config().gmail.app_password;
const supportEmail = functionsLegacy.config().support.email;

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: { user: gmailUser, pass: gmailPass },
});

exports.sendSupportEmail = onDocumentCreated(
  {
    region:   "europe-west1",
    // Patrón completo de Firestore para v2:
    document: "databases/{database}/documents/feedback/{docId}",
  },
  async (event) => {
    const data = event.data; // objeto con { subject, message, email, ... }
    const mailOptions = {
      from:    `"WaxHub Soporte" <${gmailUser}>`,
      to:      supportEmail,
      subject: `Soporte: ${data.subject}`,
      text:    `${data.message}\n\nDe: ${data.email || "anónimo"}`,
    };

    try {
      await transporter.sendMail(mailOptions);
      logger.log("Email enviado a:", supportEmail);
    } catch (err) {
      logger.error("Error al enviar email:", err);
    }
  }
);
