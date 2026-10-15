#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
PORT="${PORT:-3000}"
export PORT
OPENCODE_WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
export OPENCODE_WEB_DIR
/usr/bin/time -p mkdir -p dist
/usr/bin/time -p mkdir -p "$OPENCODE_WEB_DIR"
/usr/bin/time -p bash -c 'if [ -f package.json ]; then npm install --no-audit --no-fund; else echo "no package.json, skipping install"; fi'
/usr/bin/time -p bash -c 'if [ -f package.json ] && npm run --silent build 2>/dev/null; then echo "npm build done"; elif [ -f index.html ]; then cp -f index.html dist/index.html && echo "copied index.html to dist/"; else echo "using existing dist/"; fi'
/usr/bin/time -p test -f dist/index.html
/usr/bin/time -p node -e 'const fs=require("fs"),path=require("path");const project=path.resolve(".");const directory=path.resolve("dist");const out=path.join(process.env.OPENCODE_WEB_DIR,"deployment-output.json");fs.writeFileSync(out,JSON.stringify({project,directory}));console.log("wrote "+out+" -> "+directory);'
/usr/bin/time -p node -e 'const fs=require("fs"),path=require("path");const o=JSON.parse(fs.readFileSync(path.join(process.env.OPENCODE_WEB_DIR,"deployment-output.json"),"utf8"));if(o.project!==path.resolve(".")||!o.directory)throw new Error("bad deployment-output");fs.statSync(path.join(o.directory,"index.html"));console.log("verified "+o.directory);'
/usr/bin/time -p node -e '
const http=require("http"),fs=require("fs"),path=require("path");
const root=path.resolve("dist");
const mime={".html":"text/html",".js":"application/javascript",".css":"text/css",".json":"application/json",".svg":"image/svg+xml",".png":"image/png",".jpg":"image/jpeg",".webp":"image/webp",".wasm":"application/wasm",".glb":"model/gltf-binary",".ico":"image/x-icon",".txt":"text/plain"};
const server=http.createServer((req,res)=>{
  try{
    const u=new URL(req.url,"http://localhost");
    let p=path.resolve(root,"."+decodeURIComponent(u.pathname));
    if(p!==root&&!p.startsWith(root+"/")){res.writeHead(404);res.end("Not found");return;}
    let f=p;try{if(fs.statSync(f).isDirectory())f=path.join(f,"index.html");}catch{ f=path.join(root,"index.html"); if(u.pathname!=="/"&&!u.pathname.endsWith(".html")&&!fs.existsSync(p)){ try{fs.statSync(f);}catch{res.writeHead(404);res.end("Not found");return;} } }
    try{ if(fs.statSync(f).isDirectory())f=path.join(f,"index.html"); }catch{res.writeHead(404);res.end("Not found");return;}
    const ext=path.extname(f).toLowerCase();
    res.setHeader("Content-Type",mime[ext]||"application/octet-stream");
    res.setHeader("Cache-Control","no-cache");
    res.end(fs.readFileSync(f));
  }catch{res.writeHead(404);res.end("Not found");}
});
const port=Number(process.env.PORT||3000);
server.listen(port,"0.0.0.0",()=>console.log("PlayGround static server serving "+root+" on "+port));
'
