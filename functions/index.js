// functions/index.js

const admin     = require('firebase-admin');
const sgMail    = require('@sendgrid/mail');
const { onRequest } = require('firebase-functions/v2/https');

admin.initializeApp();

// Leemos la API key de la env var (Gen2 no usa functions.config())
const SENDGRID_KEY = process.env.SENDGRID_KEY;
if (!SENDGRID_KEY) {
  throw new Error('SendGrid key no configurada. Pásala con --set-env-vars');
}
sgMail.setApiKey(SENDGRID_KEY);

exports.sendBulkEmail = onRequest(
  {
    region: 'us-central1',
    timeoutSeconds: 60,       // si envías muchos correos, sube este timeout
    maxInstances: 2,          // opcional: control de instancias
  },
  async (req, res) => {
    // --- CORS preflight mínimo ---
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST,OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') {
      return res.status(204).send('');
    }
    if (req.method !== 'POST') {
      return res.status(405).send('Método no permitido');
    }

    // --- Validaciones ---
    const { sender, subject, htmlContent } = req.body || {};
    if (!sender || !subject || !htmlContent) {
      return res
        .status(400)
        .json({ error: 'Debes enviar sender, subject y htmlContent' });
    }

    try {
      // Lee todos los emails de Firestore
      const snapshot = await admin.firestore().collection('subscribers').get();
      const toList = snapshot.docs
        .map(d => d.get('email'))
        .filter(e => typeof e === 'string' && e);

      if (toList.length === 0) {
        return res.json({ success: true, count: 0 });
      }

      // Construye y envía el batch
      const messages = toList.map(email => ({
        to:      email,
        from:    sender,
        subject,
        html:    htmlContent,
      }));
      await sgMail.send(messages, true);

      return res.json({ success: true, count: toList.length });
    } catch (err) {
      console.error('❌ Error en sendBulkEmail:', err);
      return res
        .status(500)
        .json({ error: err.message || err.toString() });
    }
  }
);
