#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_ROOT="$(/usr/bin/time -p pwd)"
PORT="${PORT:-3000}"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
STATIC_DIR="$PROJECT_ROOT/dist"
export PORT WEB_DIR STATIC_DIR
/usr/bin/time -p test -f "$STATIC_DIR/index.html"
/usr/bin/time -p mkdir -p "$WEB_DIR"
if /usr/bin/time -p test -f "$PROJECT_ROOT/package.json"; then
  if /usr/bin/time -p test -f "$PROJECT_ROOT/package-lock.json"; then
    /usr/bin/time -p npm ci --no-audit --no-fund
  else
    /usr/bin/time -p npm install --no-audit --no-fund
  fi
  if /usr/bin/time -p node -e "const p=require('./package.json');process.exit(p.scripts&&p.scripts.build?0:1)"; then
    /usr/bin/time -p npm run build
  fi
  /usr/bin/time -p test -f "$STATIC_DIR/index.html"
fi
/usr/bin/time -p node -e "
const fs=require('fs');
const web=process.env.WEB_DIR;
const dir=process.env.STATIC_DIR;
const project='$PROJECT_ROOT';
fs.mkdirSync(web,{recursive:true});
fs.writeFileSync(web+'/deployment-output.json',JSON.stringify({project:project,directory:dir}));
"
/usr/bin/time -p node -e "
const http=require('http'),fs=require('fs'),path=require('path');
const root=process.env.STATIC_DIR;
const port=Number(process.env.PORT||'3000');
const mime={'.html':'text/html; charset=utf-8','.js':'application/javascript','.css':'text/css','.json':'application/json','.svg':'image/svg+xml','.png':'image/png','.jpg':'image/jpeg','.webp':'image/webp','.wasm':'application/wasm'};
http.createServer((req,res)=>{
  try{
    const u=new URL(req.url,'http://localhost');
    let p=path.normalize(path.join(root,decodeURIComponent(u.pathname)));
    if(p!==root&&!p.startsWith(root+'/')){res.writeHead(404);res.end('Not found');return;}
    if(fs.statSync(p).isDirectory())p=path.join(p,'index.html');
    res.setHeader('Content-Type',mime[path.extname(p)]||'application/octet-stream');
    res.setHeader('Cache-Control','no-cache');
    res.end(fs.readFileSync(p));
  }catch(e){res.writeHead(404);res.end('Not found');}
}).listen(port,'0.0.0.0',()=>console.log('Serving '+root+' on port '+port));
"
