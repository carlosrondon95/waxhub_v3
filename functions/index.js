// functions/index.js (GCF v2 – Node 22)

import { onRequest } from 'firebase-functions/v2/https';
import fetch from 'node-fetch';
import cors from 'cors';

const corsHandler = cors({ origin: true });

export const imageProxy = onRequest(
  { region: 'us-central1', timeoutSeconds: 10, memory: '256MiB' },
  (req, res) => {
    corsHandler(req, res, async () => {
      try {
        const url = req.query.url;
        if (!url) {
          res.status(400).send('Missing url param');
          return;
        }

        const resp = await fetch(url.toString(), {
          headers: { 'User-Agent': 'WaxHubProxy/1.0 (+https://waxhub.app)' },
        });

        if (!resp.ok) {
          res.status(resp.status).send(`Upstream error: ${resp.statusText}`);
          return;
        }

        // Copia tipo & longitud si existen
        res.set('Content-Type', resp.headers.get('content-type') || 'image/jpeg');
        const len = resp.headers.get('content-length');
        if (len) res.set('Content-Length', len);

        // Stream directo
        resp.body.pipe(res);
      } catch (e) {
        console.error(e);
        res.status(500).send('Proxy error');
      }
    });
  }
);
