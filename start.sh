#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
PORT="${PORT:-3000}"
export PORT
PROJECT_ROOT="$(pwd)"
DIST_DIR="$PROJECT_ROOT/dist"
export DIST_DIR
# Install dependencies when a package project is present.
/usr/bin/time -p test ! -f "$PROJECT_ROOT/package.json" || /usr/bin/time -p npm install --no-audit --no-fund
# Build when a build script is present (static fallback keeps dist/index.html).
/usr/bin/time -p bash -c 'if [ -f package.json ] && node -e "const p=require(\"./package.json\");process.exit(p.scripts&&p.scripts.build?0:1)"; then npm run build --if-present; else true; fi'
/usr/bin/time -p test -f "$DIST_DIR/index.html" || { echo "Static deployment output must contain dist/index.html." >&2; exit 1; }
/usr/bin/time -p mkdir -p "${OPENCODE_WEB_DIR:?}"
/usr/bin/time -p node -e 'const fs=require("fs"),path=require("path");const root=process.cwd();const dir=path.join(root,"dist");const out=path.join(process.env.OPENCODE_WEB_DIR,"deployment-output.json");fs.writeFileSync(out,JSON.stringify({project:root,directory:dir}));console.log("wrote "+out);'
/usr/bin/time -p cat "${OPENCODE_WEB_DIR}/deployment-output.json"
/usr/bin/time -p node -e '
const http=require("http"),fs=require("fs"),path=require("path");
const root=process.env.DIST_DIR||path.join(process.cwd(),"dist");
const port=Number(process.env.PORT||3000);
const mime={".html":"text/html",".js":"application/javascript",".css":"text/css",".json":"application/json",".svg":"image/svg+xml",".png":"image/png",".jpg":"image/jpeg",".webp":"image/webp",".wasm":"application/wasm",".glb":"model/gltf-binary"};
const server=http.createServer((req,res)=>{
  try{
    const url=new URL(req.url,"http://localhost");
    let p=path.resolve(root,"."+decodeURIComponent(url.pathname));
    if(p!==path.resolve(root)&&!p.startsWith(path.resolve(root)+"/")){res.writeHead(404);res.end();return;}
    let file=p; try{ if(fs.statSync(file).isDirectory()) file=path.join(file,"index.html"); }catch{ file=path.join(root,"index.html"); }
    res.setHeader("Content-Type",mime[path.extname(file)]||"application/octet-stream");
    res.setHeader("Cache-Control","no-cache");
    res.end(fs.readFileSync(file));
  }catch{ res.writeHead(404); res.end("Not found"); }
});
server.listen(port,"0.0.0.0",()=>console.log("serving "+root+" on "+port));
'
