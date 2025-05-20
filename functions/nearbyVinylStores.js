// functions/nearbyVinylStores.js
import functions from "firebase-functions/v2/https";
import fetch from "node-fetch";

export const nearbyVinylStores = functions.onRequest(async (req, res) => {
  const { lat, lng, radius = 10000 } = req.query;
  if (!lat || !lng) return res.status(400).json({ error: "coords missing" });

  const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json` +
              `?location=${lat},${lng}&keyword=vinyl+record+store` +
              `&radius=${radius}&key=${process.env.PLACES_KEY}`;

  const resp = await fetch(url);
  const data = await resp.json();

  res.set("Access-Control-Allow-Origin", "https://tudominio.web.app"); // ajusta
  res.json(data);
});
