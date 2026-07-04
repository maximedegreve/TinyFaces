(function () {
  var canvas = document.getElementById("bg-shader");
  if (!canvas) return;

  var reduce =
    window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  var gl =
    canvas.getContext("webgl", { antialias: true, premultipliedAlpha: false }) ||
    canvas.getContext("experimental-webgl");

  // If WebGL is unavailable, the CSS grey background remains as a graceful fallback.
  if (!gl) return;

  canvas.classList.add("is-active");

  var vertSrc =
    "attribute vec2 p;" + "void main(){gl_Position=vec4(p,0.0,1.0);}";

  var fragSrc = [
    "precision highp float;",
    "uniform vec2 u_res;",
    "uniform float u_time;",
    // Soft value-noise + fbm for gentle flowing shapes.
    "float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}",
    "float noise(vec2 p){",
    "  vec2 i=floor(p);vec2 f=fract(p);",
    "  float a=hash(i);float b=hash(i+vec2(1.0,0.0));",
    "  float c=hash(i+vec2(0.0,1.0));float d=hash(i+vec2(1.0,1.0));",
    "  vec2 u=f*f*(3.0-2.0*f);",
    "  return mix(a,b,u.x)+(c-a)*u.y*(1.0-u.x)+(d-b)*u.x*u.y;",
    "}",
    "float fbm(vec2 p){",
    "  float v=0.0;float amp=0.5;",
    "  for(int i=0;i<4;i++){v+=amp*noise(p);p*=2.0;amp*=0.5;}",
    "  return v;",
    "}",
    "void main(){",
    "  vec2 uv=gl_FragCoord.xy/u_res.xy;",
    "  vec2 asp=vec2(u_res.x/u_res.y,1.0);",
    "  vec2 q=uv*asp;",
    "  float t=u_time*0.18;",
    // Gentle domain warp so the tints drift slowly.
    "  vec2 w=vec2(fbm(q*1.4+vec2(t,-t)),fbm(q*1.4+vec2(-t,t)+3.7));",
    "  float n=fbm(q*1.6+w*0.9+t);",
    "  float m=fbm(q*1.1-w*0.6-t*0.7);",
    // Light TinyFaces-adjacent tints over the snow base.
    "  vec3 base=vec3(0.960,0.965,0.972);",
    "  vec3 shade=vec3(0.820,0.835,0.855);",
    "  vec3 col=base;",
    "  col=mix(col,shade,smoothstep(0.3,0.92,n)*0.55);",
    "  col=mix(col,shade,smoothstep(0.4,0.95,m)*0.35);",
    // Soft vignette to keep edges calm.
    "  float d=distance(uv,vec2(0.5));",
    "  col=mix(col,base,smoothstep(0.55,1.05,d)*0.4);",
    "  gl_FragColor=vec4(col,1.0);",
    "}",
  ].join("\n");

  function compile(type, src) {
    var s = gl.createShader(type);
    gl.shaderSource(s, src);
    gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) return null;
    return s;
  }

  var vs = compile(gl.VERTEX_SHADER, vertSrc);
  var fs = compile(gl.FRAGMENT_SHADER, fragSrc);
  if (!vs || !fs) {
    canvas.classList.remove("is-active");
    return;
  }

  var prog = gl.createProgram();
  gl.attachShader(prog, vs);
  gl.attachShader(prog, fs);
  gl.linkProgram(prog);
  gl.useProgram(prog);

  var buf = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buf);
  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array([-1, -1, 3, -1, -1, 3]),
    gl.STATIC_DRAW
  );
  var loc = gl.getAttribLocation(prog, "p");
  gl.enableVertexAttribArray(loc);
  gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);

  var uRes = gl.getUniformLocation(prog, "u_res");
  var uTime = gl.getUniformLocation(prog, "u_time");

  function resize() {
    var dpr = Math.min(window.devicePixelRatio || 1, 1.5);
    var w = Math.floor(window.innerWidth * dpr);
    var h = Math.floor(window.innerHeight * dpr);
    if (canvas.width !== w || canvas.height !== h) {
      canvas.width = w;
      canvas.height = h;
      gl.viewport(0, 0, w, h);
    }
  }

  window.addEventListener("resize", resize);
  resize();

  var start = performance.now();

  function frame(now) {
    gl.uniform2f(uRes, canvas.width, canvas.height);
    gl.uniform1f(uTime, (now - start) / 1000);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
    if (!reduce) requestAnimationFrame(frame);
  }

  if (reduce) {
    // Draw a single static frame for reduced-motion users.
    frame(start);
  } else {
    requestAnimationFrame(frame);
  }
})();
