const {test}=require("node:test"),assert=require("node:assert/strict"),{createServer}=require("../app/server");
async function serve(fn){const s=createServer({color:"green",version:"test-42"});await new Promise(ok=>s.listen(0,"127.0.0.1",ok));try{await fn(`http://127.0.0.1:${s.address().port}`)}finally{await new Promise((ok,fail)=>s.close(e=>e?fail(e):ok()))}}
test("health endpoint returns ready",()=>serve(async u=>{const x=await fetch(u+"/health");assert.equal(x.status,200);assert.equal(await x.text(),"ok\n")}));
test("release endpoint exposes color and version",()=>serve(async u=>{const x=await fetch(u+"/version");assert.deepEqual(await x.json(),{app:"blue-green-demo",color:"green",version:"test-42"})}));
