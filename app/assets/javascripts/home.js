var c = document.getElementById("canv");
var $ = c.getContext("2d");
c.width = window.innerWidth;
c.height = window.innerHeight;

var max = 100;
var num = 1;
var darr = [];
var dst;
var gsz = 50;
var msX = 0;
var msY = 0;
var grav = 150;
var _psz = 1;
dst = Dist(gsz);

for (var i = 0; i < num; i++) {
  dst.add(Node(c));
}

function nPart() {
  var p;
  if (dst.parr.length < max) {
    if (darr.length > 0) {
      p = darr.pop();
      p.res_(msX, msY);
      dst.add(p);
    } else {
      p = Node(c, msX, msY)
      dst.add(p);
    }
  }
  return p;
}

var pull = .03;

function draw() {
 $.fillStyle = '#6937e2';
 $.fillRect(0, 0, c.width, c.height);
  dst.ref();
  var pos = dst.pos;
  var i = dst.parr.length;
  while (i--) {
    var p = dst.parr[i];
    var n = dst.next(p);
    if (n) {
      var l = n.length;
      while (l--) {
        var pnxt = n[l];
        if (pnxt === p) {
          continue;
        }
        conn(p, pnxt);
        _px = (p.x - pnxt.x) / _dist(pnxt, p);
        _py = (p.y - pnxt.y) / _dist(pnxt, p);
        p.velX -= _px * pull;
        p.velY -= _py * pull;
      }
    }
  }
  upd();
}

function addP(px, py) {
  var p = Node(c, px, py);
  dst.add(p);
}

function conn(p1, p2) {
  $.strokeStyle = '#FFFFFF';
  var dist = _dist(p1, p2);
  $.globalAlpha = 1 - dist / 100;
  $.beginPath();
  $.moveTo(p1.x, p1.y);
  $.lineTo(p2.x, p2.y);
  $.stroke();
}

function _dist(p1, p2) {
  var _px = 0;
  var _py = 0;
  _px = p2.x - p1.x;
  _px = _px * _px;
  _py = p2.y - p1.y;
  _py = _py * _py;
  return Math.sqrt(_px + _py);
}

function upd() {
  for (var i = 0; i < dst.parr.length; i++) {
    dst.parr[i].upos();
  }
}

function pRem(p) {
  var i = dst.rem(p)
  darr.push(i[0]);
}

var frict = .9;

function Node(c, px, py) {
  var _p = {};
     _p.res_ = function(px, py) {
     _p.mass = rnd(1, 10);
     _p.gx = rnd(-5, 5);
     _p.gy = rnd(-5, 5);
     _p.x = px || rnd(10, c.width - 10);
     _p.y = py || rnd(10, c.height - 10);
     _p.gx2 = rnd(-2, 2) * .5;
     _p.gy2 = rnd(-2, 2) * .5;

 var vel = 25;
     _p.velX = rnd(-vel, vel);
     _p.velY = rnd(-vel, vel);
}
  _p.upos = function() {
    if (Math.abs(_p.velX) < 1 && Math.abs(_p.velY) < 1) pRem(_p);
    if (rnd(0, 100) > 98) {
      var np = nPart();
      if (np) {
        np.res_(_p.x, _p.y);
        np.velX += rnd(-5, 5);
        np.velY += rnd(-5, 5);
      }
    }
    _p.velX *= frict;
    _p.velY *= frict;

    if (_p.x + _p.velX > c.width) _p.velX *= -1;
    else if (_p.x + _p.velX < 0)  _p.velX *= -1;
    if (_p.y + _p.velY > c.height) _p.velY *= -1;
    else if (_p.y + _p.velY < 0) _p.velY *= -1;

    conn(_p, {
      x: _p.x + _p.velX,
      y: _p.y + _p.velY
    })
    _p.x += _p.velX;
    _p.y += _p.velY;
  }
  _p.res_(px, py);
  return _p;
}

function Dist(gsz) {
  var ret = {};
      ret.gsz = gsz;
      ret.parr = [];
      ret.pos = [];

  ret.next = function(a) {
    var x = Math.ceil(a.x / gsz);
    var y = Math.ceil(a.y / gsz);
    var p = ret.pos;
    var r = p[x][y];

    try {
      if (p[x - 1][y - 1]) {
        r = r.concat(p[x - 1][y - 1]);
      }
    } catch (e) {}
    try {
      if (p[x][y - 1]) {
        r = r.concat(p[x][y - 1]);
      }
    } catch (e) {}
    try {
      if (p[x + 1][y - 1]) {
        r = r.concat(p[x + 1][y - 1]);
      }
    } catch (e) {}
    try {
      if (p[x - 1][y]) {
        r = r.concat(p[x - 1][y]);
      }
    } catch (e) {}
    try {
      if (p[x + 1][y]) {
        r = r.concat(p[x + 1][y]);
      }
    } catch (e) {}
    try {
      if (p[x - 1][y + 1]) {
        r = r.concat(p[x - 1][y + 1]);
      }
    } catch (e) {}
    try {
      if (p[x][y + 1]) {
        r = r.concat(p[x][y + 1]);
      }
    } catch (e) {}
    try {
      if (p[x + 1][y + 1]) {
        r = r.concat(p[x + 1][y + 1]);
      }
    } catch (e) {}
    return r;
  }

  ret.ref = function() {
    ret.pos = [];
    var i = ret.parr.length;
    while (i--) {
      var a = ret.parr[i];
      var x = Math.ceil(a.x / gsz);
      var y = Math.ceil(a.y / gsz);
      if (!ret.pos[x]) ret.pos[x] = [];
      if (!ret.pos[x][y]) ret.pos[x][y] = [a];
      continue;
      ret.pos[x][y].push(a);
    }
  }
  ret.add = function(a) {
    ret.parr.push(a);
  }

  ret.rem = function(a) {
    var i = ret.parr.length;
    while (i--) {
      if (ret.parr[i] === a) return ret.parr.splice(i, 1);
    }
  }
  return ret;
}

function rnd(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

window.addEventListener('mousemove', function(e) {
  var np = nPart();
  if (np) np.res_(e.clientX, e.clientY);
}, false);

window.addEventListener('touchmove', function(e) {
  e.preventDefault();
  var np = nPart();
  if (np)  np.res_(e.touches[0].clientX, e.touches[0].clientY);
}, false);

function run() {
  window.requestAnimationFrame(run);
  draw();
}
run();

window.addEventListener('resize',function(){
  c.width = window.innerWidth;
  c.height = window.innerHeight;
}, false);
