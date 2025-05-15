const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const fetch = require('node-fetch');

exports.imageProxy = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const imageUrl = req.query.url;
    if (!imageUrl) {
      return res.status(400).send('Parámetro url es obligatorio');
    }
    try {
      const response = await fetch(imageUrl);
      if (!response.ok) {
        return res.status(502).send('Error al obtener la imagen');
      }
      const contentType = response.headers.get('content-type');
      res.set('Content-Type', contentType || 'image/jpeg');
      // Cachear por una hora
      res.set('Cache-Control', 'public, max-age=3600');
      const buffer = await response.arrayBuffer();
      res.send(Buffer.from(buffer));
    } catch (e) {
      console.error('Proxy error:', e);
      res.status(500).send('Error interno en el proxy');
    }
  });
});
