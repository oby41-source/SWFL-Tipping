/**
 * _worker.js — Cloudflare Pages Worker
 * Automatically runs on your Pages domain (no extra setup needed)
 * Handles /graphql → proxies to PlayHQ
 * Everything else → serves the static files normally
 */

const PLAYHQ_URL    = 'https://api.playhq.com/graphql';
const PLAYHQ_KEY    = 'b710b64f-2797-4030-95d1-0a1bc9f03bb3';
const PLAYHQ_TENANT = 'afl';

const CORS = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default {
  async fetch(request, env) {
    const url  = new URL(request.url);
    const path = url.pathname;

    // Let Cloudflare Pages serve static files (index.html, links.html etc)
    if (path === '/' || path === '/index.html' || path === '/links.html') {
      return env.ASSETS.fetch(request);
    }

    // Handle OPTIONS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS });
    }

    // /graphql  — proxy to PlayHQ
    if (path === '/graphql' && request.method === 'POST') {
      try {
        const body = await request.text();
        const upstream = await fetch(PLAYHQ_URL, {
          method:  'POST',
          headers: {
            'Content-Type':  'application/json',
            'Accept':        'application/json',
            'x-api-key':     PLAYHQ_KEY,
            'x-phq-tenant':  PLAYHQ_TENANT,
            'Origin':        'https://www.playhq.com',
            'Referer':       'https://www.playhq.com/',
          },
          body,
        });
        const data = await upstream.text();
        return new Response(data, {
          status:  upstream.status,
          headers: { ...CORS, 'Content-Type': 'application/json' },
        });
      } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), {
          status:  502,
          headers: { ...CORS, 'Content-Type': 'application/json' },
        });
      }
    }

    // Everything else → static assets
    return env.ASSETS.fetch(request);
  },
};
