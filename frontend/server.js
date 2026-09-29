'use strict';
const http = require('node:http');
function createServer({color=process.env.APP_COLOR||'local', version=process.env.APP_VERSION||'dev', apiUrl=process.env.API_URL, fetcher=fetch}={}) {
  return http.createServer(async (req,res)=>{
    try {
      if (req.url==='/health') { const r=apiUrl?await fetcher(`${apiUrl}/health`):null; const ok=!apiUrl||r.ok; res.writeHead(ok?200:503,{'content-type':'application/json'}); res.end(JSON.stringify({status:ok?'ok':'unhealthy',color,version,api:ok})+'\n'); return; }
      if (req.url==='/version') { const api=apiUrl?await (await fetcher(`${apiUrl}/version`)).json():null; res.writeHead(200,{'content-type':'application/json'}); res.end(JSON.stringify({app:'frontend',color,version,api})+'\n'); return; }
      res.writeHead(200,{'content-type':'text/html; charset=utf-8'}); res.end(`<h1>Blue-Green demo</h1><p>Frontend ${color} · release ${version}</p>\n`);
    } catch { res.writeHead(503); res.end('dependency unavailable\n'); }
  });
}
if(require.main===module){const s=createServer();s.listen(Number(process.env.PORT||8080),'0.0.0.0');const stop=()=>s.close(()=>process.exit(0));process.on('SIGTERM',stop);process.on('SIGINT',stop);}
module.exports={createServer};
