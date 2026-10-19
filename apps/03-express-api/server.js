'use strict';

const http = require('node:http');

const PORT = Number(process.env.PORT || 3000);

const shipments = new Map([
  ['SHP-1001', { id: 'SHP-1001', status: 'in_transit', carrier: 'northwind-freight' }],
  ['SHP-1002', { id: 'SHP-1002', status: 'delivered', carrier: 'northwind-freight' }],
]);

function json(res, status, body) {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    'content-type': 'application/json',
    'content-length': Buffer.byteLength(payload),
  });
  res.end(payload);
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (url.pathname === '/healthz') {
    return json(res, 200, { status: 'ok', service: 'express-api' });
  }

  if (url.pathname === '/api/shipments') {
    return json(res, 200, { shipments: [...shipments.values()] });
  }

  const match = url.pathname.match(/^\/api\/shipments\/([A-Z0-9-]+)$/);
  if (match) {
    const shipment = shipments.get(match[1]);
    return shipment
      ? json(res, 200, shipment)
      : json(res, 404, { error: 'shipment not found' });
  }

  return json(res, 404, { error: 'not found' });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`shipments api listening on :${PORT}`);
});
