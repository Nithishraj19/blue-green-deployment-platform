'use strict';
const http=require('node:http');
function createServer({role=process.env.APP_ROLE||'api',color=process.env.APP_COLOR||'local',version=process.env.APP_VERSION||'dev',services=[process.env.SERVICE_A_URL,process.env.SERVICE_B_URL].filter(Boolean),fetcher=fetch}={}){
 const details=async()=>Promise.all(services.map(async url=>{const r=await fetcher(`${url}/version`);if(!r.ok)throw Error('service unavailable');return r.json()}));
 return http.createServer(async(req,res)=>{try{if(req.url==='/health'){const deps=role==='api'?await details():[];res.writeHead(200,{'content-type':'application/json'});res.end(JSON.stringify({status:'ok',role,color,version,dependencies:deps.length})+'\n');return}if(req.url==='/version'){const deps=role==='api'?await details():[];res.writeHead(200,{'content-type':'application/json'});res.end(JSON.stringify({role,color,version,services:deps})+'\n');return}res.writeHead(200,{'content-type':'application/json'});res.end(JSON.stringify({role,color,version})+'\n')}catch{res.writeHead(503);res.end('dependency unavailable\n')}});
}
if(require.main===module){const s=createServer();s.listen(Number(process.env.PORT||8081),'0.0.0.0');const stop=()=>s.close(()=>process.exit(0));process.on('SIGTERM',stop);process.on('SIGINT',stop);}
module.exports={createServer};
