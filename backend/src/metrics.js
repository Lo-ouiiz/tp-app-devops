const client = require('prom-client');

// Collecte CPU, RAM, event loop, etc
client.collectDefaultMetrics();

// Histogramme HTTP
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 1, 1.5, 2, 5],
});

module.exports = {
  client,
  httpRequestDuration,
};
