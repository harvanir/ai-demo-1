const express = require('express');
const fetch = require('node-fetch');

const app = express();
app.use(express.json());

// Environment variables used by this relay (keep minimal and technology-agnostic):
// - WEBHOOK_TARGET_URL : the target webhook URL (preferred, generic)
// - VERIFY_TOKEN : webhook verification token
// - PORT or RELAY_PORT : server listen port
const VERIFY_TOKEN = process.env.VERIFY_TOKEN || 'your_verify_token';
const TARGET_WEBHOOK = process.env.WEBHOOK_TARGET_URL || 'http://n8n:5678/webhook/wa/incoming';

// GET verification from Meta
app.get('/webhook/wa', (req, res) => {
	const mode = req.query['hub.mode'];
	const token = req.query['hub.verify_token'];
	const challenge = req.query['hub.challenge'];

	if (mode === 'subscribe' && token === VERIFY_TOKEN) {
		console.log('WEBHOOK_VERIFIED');
		return res.status(200).send(challenge);
	}
	return res.sendStatus(403);
});

// POST incoming messages → forward to n8n
app.post('/webhook/wa', async (req, res) => {
	try {
		await fetch(TARGET_WEBHOOK, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(req.body),
		});
		res.sendStatus(200);
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
	}
});

app.get('/health', (_, res) => res.json({ ok: true }));

const port = process.env.PORT || process.env.RELAY_PORT || 3000;
app.listen(port, () => {
	const maskedToken = VERIFY_TOKEN ? (VERIFY_TOKEN.length > 8 ? VERIFY_TOKEN.slice(0,4) + '...' + VERIFY_TOKEN.slice(-4) : '****') : 'not-set';
	console.log('WA relay listening on :', port);
	console.log('Using TARGET_WEBHOOK ->', TARGET_WEBHOOK);
	console.log('VERIFY_TOKEN (masked) ->', maskedToken);
});