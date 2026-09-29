const http=require("node:http");
function createServer({color=process.env.APP_COLOR||"local",version=process.env.VERSION||"dev"}={}){return http.createServer((req,res)=>{if(req.url==="/health"||req.url==="/ready"){res.writeHead(200,{"content-type":"text/plain"});res.end("ok\n");return}if(req.url==="/version"){res.writeHead(200,{"content-type":"application/json"});res.end(JSON.stringify({app:"blue-green-demo",color,version})+"\n");return}res.writeHead(200,{"content-type":"text/html"});res.end(`<h1>Blue-Green Demo</h1><p>Release ${version} from ${color}</p>\n`)})}
if(require.main===module){const s=createServer();s.listen(Number(process.env.PORT||8080),"0.0.0.0");const stop=()=>s.close(()=>process.exit(0));process.on("SIGTERM",stop);process.on("SIGINT",stop)}
module.exports={createServer};
