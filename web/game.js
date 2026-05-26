const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');

const ui = {
  wave: document.getElementById('wave'),
  baseHp: document.getElementById('baseHp'),
  money: document.getElementById('money'),
  level: document.getElementById('level'),
  xp: document.getElementById('xp'),
  message: document.getElementById('message'),
  log: document.getElementById('log'),
};

const state = {
  wave: 1,
  baseHp: 100,
  money: 250,
  xp: 0,
  level: 1,
  selectedTower: 'turret',
  towers: [],
  zombies: [],
  bullets: [],
  particles: [],
  waveRunning: false,
  spawnLeft: 0,
  spawnTimer: 0,
  speed: 1,
  autoWave: false,
  effects: false,
  lastTime: performance.now(),
  paused: false,
};

const path = [
  {x: -40, y: 260},
  {x: 160, y: 260},
  {x: 160, y: 120},
  {x: 420, y: 120},
  {x: 420, y: 410},
  {x: 720, y: 410},
  {x: 720, y: 260},
  {x: 930, y: 260},
];

const base = {x: 900, y: 210, w: 50, h: 100};

const towerDefs = {
  turret: {name: 'Tourelle', cost: 100, range: 115, fireRate: 0.55, damage: 12, color: '#ffca3a', bullet: '#2b9348'},
  grenade: {name: 'Grenade', cost: 180, range: 100, fireRate: 1.3, damage: 28, splash: 45, color: '#f77f00', bullet: '#d62828'},
  cryo: {name: 'Cryo', cost: 150, range: 105, fireRate: 0.8, damage: 5, slow: 0.55, color: '#48cae4', bullet: '#90e0ef'},
  sniper: {name: 'Sniper', cost: 220, range: 210, fireRate: 1.6, damage: 55, color: '#9d4edd', bullet: '#5a189a'},
};

function log(msg) {
  const row = document.createElement('div');
  row.textContent = `[V${state.wave}] ${msg}`;
  ui.log.prepend(row);
}

function setMessage(msg) { ui.message.textContent = msg; }

function updateUi() {
  ui.wave.textContent = state.wave;
  ui.baseHp.textContent = Math.max(0, Math.floor(state.baseHp));
  ui.money.textContent = Math.floor(state.money);
  ui.level.textContent = state.level;
  ui.xp.textContent = state.xp;
}

function addXp(amount) {
  state.xp += amount;
  const need = state.level * 100;
  if (state.xp >= need) {
    state.xp -= need;
    state.level++;
    state.money += 100;
    log(`Niveau ${state.level} atteint. Bonus +100 argent.`);
  }
}

function waveStats() {
  const boss = state.wave % 10 === 0;
  const hp = boss ? 260 + state.wave * 40 : 40 + state.wave * 8;
  const count = boss ? 1 : Math.min(14 + Math.floor(state.wave * 1.2), 90);
  const speed = boss ? 32 + state.wave * 0.4 : 45 + state.wave * 0.35;
  return {boss, hp, count, speed};
}

function startWave() {
  if (state.waveRunning) return;
  const s = waveStats();
  state.spawnLeft = s.count;
  state.spawnTimer = 0;
  state.waveRunning = true;
  setMessage(s.boss ? 'Boss très puissant en approche !' : 'Les zombies arrivent !');
  log(s.boss ? 'Boss lancé.' : 'Vague lancée.');
}

function spawnZombie() {
  const s = waveStats();
  const boss = s.boss;
  state.zombies.push({
    x: path[0].x,
    y: path[0].y,
    hp: s.hp,
    maxHp: s.hp,
    speed: s.speed,
    pathIndex: 1,
    radius: boss ? 28 : 15,
    boss,
    slowTimer: 0,
    reward: boss ? 400 + state.wave * 8 : 18 + state.wave,
  });
}

function placeTower(x, y) {
  const def = towerDefs[state.selectedTower];
  if (!def || state.money < def.cost) {
    setMessage('Pas assez d’argent.');
    return;
  }
  if (x > 840 && y > 185 && y < 335) {
    setMessage('Tu ne peux pas placer sur la base.');
    return;
  }
  if (isNearPath(x, y)) {
    setMessage('Ne bloque pas le chemin des zombies.');
    return;
  }
  state.money -= def.cost;
  state.towers.push({x, y, type: state.selectedTower, cooldown: 0, level: 1});
  setMessage(`${def.name} placée.`);
}

function isNearPath(x, y) {
  for (let i = 1; i < path.length; i++) {
    const a = path[i - 1], b = path[i];
    const d = distanceToSegment(x, y, a.x, a.y, b.x, b.y);
    if (d < 34) return true;
  }
  return false;
}

function distanceToSegment(px, py, x1, y1, x2, y2) {
  const dx = x2 - x1, dy = y2 - y1;
  const len = dx * dx + dy * dy;
  let t = ((px - x1) * dx + (py - y1) * dy) / len;
  t = Math.max(0, Math.min(1, t));
  const x = x1 + t * dx, y = y1 + t * dy;
  return Math.hypot(px - x, py - y);
}

function findTarget(tower, def) {
  let best = null;
  let bestDist = Infinity;
  for (const z of state.zombies) {
    const d = Math.hypot(z.x - tower.x, z.y - tower.y);
    if (d <= def.range && d < bestDist) {
      best = z;
      bestDist = d;
    }
  }
  return best;
}

function update(dt) {
  if (state.paused) return;
  dt *= state.speed;

  if (state.waveRunning) {
    state.spawnTimer -= dt;
    if (state.spawnLeft > 0 && state.spawnTimer <= 0) {
      spawnZombie();
      state.spawnLeft--;
      state.spawnTimer = waveStats().boss ? 999 : 0.55;
    }
  }

  for (const z of state.zombies) {
    const target = path[z.pathIndex];
    const slowFactor = z.slowTimer > 0 ? 0.45 : 1;
    const step = z.speed * slowFactor * dt;
    const dx = target.x - z.x;
    const dy = target.y - z.y;
    const dist = Math.hypot(dx, dy);
    if (dist <= step) {
      z.x = target.x;
      z.y = target.y;
      z.pathIndex++;
      if (z.pathIndex >= path.length) {
        state.baseHp -= z.boss ? 35 : 8;
        z.dead = true;
        setMessage('La base prend des dégâts !');
      }
    } else {
      z.x += dx / dist * step;
      z.y += dy / dist * step;
    }
    z.slowTimer = Math.max(0, z.slowTimer - dt);
  }

  for (const t of state.towers) {
    const def = towerDefs[t.type];
    t.cooldown -= dt;
    if (t.cooldown <= 0) {
      const target = findTarget(t, def);
      if (target) {
        state.bullets.push({x: t.x, y: t.y, target, speed: 420, damage: def.damage * t.level, color: def.bullet, splash: def.splash || 0, slow: def.slow || 0});
        t.cooldown = def.fireRate;
      }
    }
  }

  for (const b of state.bullets) {
    if (!b.target || b.target.dead) { b.dead = true; continue; }
    const dx = b.target.x - b.x;
    const dy = b.target.y - b.y;
    const dist = Math.hypot(dx, dy);
    const step = b.speed * dt;
    if (dist <= step) {
      hitZombie(b.target, b);
      b.dead = true;
    } else {
      b.x += dx / dist * step;
      b.y += dy / dist * step;
    }
  }

  state.zombies = state.zombies.filter(z => !z.dead);
  state.bullets = state.bullets.filter(b => !b.dead);
  state.particles = state.particles.filter(p => (p.life -= dt) > 0);

  if (state.waveRunning && state.spawnLeft <= 0 && state.zombies.length === 0) {
    state.waveRunning = false;
    state.wave++;
    state.money += 65 + state.wave * 4;
    addXp(30 + state.wave);
    setMessage('Vague terminée. Prépare la suite.');
    log('Vague terminée.');
    if (state.autoWave && state.baseHp > 0) setTimeout(startWave, 900);
  }

  if (state.baseHp <= 0) {
    setMessage('Base détruite. Recharge la page pour recommencer.');
    state.paused = true;
    log('Partie terminée.');
  }
}

function hitZombie(z, b) {
  if (b.splash > 0) {
    for (const other of state.zombies) {
      const d = Math.hypot(other.x - z.x, other.y - z.y);
      if (d <= b.splash) other.hp -= b.damage * (1 - d / (b.splash * 1.5));
    }
    particle(z.x, z.y, '#f77f00', 14);
  } else {
    z.hp -= b.damage;
    particle(z.x, z.y, state.effects ? '#c1121f' : '#ffffff', state.effects ? 8 : 4);
  }
  if (b.slow) z.slowTimer = 1.4;
  for (const dead of state.zombies) {
    if (dead.hp <= 0 && !dead.dead) {
      dead.dead = true;
      state.money += dead.reward;
      addXp(dead.boss ? 160 : 12);
      if (dead.boss) log('Boss vaincu. Niveau global des zombies augmenté.');
    }
  }
}

function particle(x, y, color, n) {
  for (let i = 0; i < n; i++) {
    state.particles.push({x, y, vx: (Math.random() - .5) * 90, vy: (Math.random() - .5) * 90, life: .35, color});
  }
}

function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawMap();
  drawBase();
  drawTowers();
  drawZombies();
  drawBullets();
  drawParticles();
  updateUi();
}

function drawMap() {
  ctx.fillStyle = '#95d85f';
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.strokeStyle = '#d9a441';
  ctx.lineWidth = 42;
  ctx.lineCap = 'round';
  ctx.lineJoin = 'round';
  ctx.beginPath();
  ctx.moveTo(path[0].x, path[0].y);
  for (const p of path.slice(1)) ctx.lineTo(p.x, p.y);
  ctx.stroke();
  ctx.strokeStyle = 'rgba(255,255,255,.35)';
  ctx.lineWidth = 4;
  ctx.stroke();
}

function drawBase() {
  ctx.fillStyle = '#7b2cbf';
  ctx.fillRect(base.x, base.y, base.w, base.h);
  ctx.fillStyle = '#ffdd57';
  ctx.fillRect(base.x + 8, base.y + 14, 34, 18);
  ctx.fillRect(base.x + 8, base.y + 68, 34, 18);
}

function drawTowers() {
  for (const t of state.towers) {
    const def = towerDefs[t.type];
    ctx.fillStyle = def.color;
    ctx.strokeStyle = '#173b16';
    ctx.lineWidth = 3;
    ctx.beginPath();
    if (t.type === 'sniper') ctx.rect(t.x - 13, t.y - 13, 26, 26);
    else if (t.type === 'grenade') ctx.roundRect(t.x - 15, t.y - 12, 30, 24, 8);
    else ctx.arc(t.x, t.y, 15, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
  }
}

function drawZombies() {
  for (const z of state.zombies) {
    ctx.fillStyle = z.boss ? '#386641' : '#6a994e';
    ctx.strokeStyle = z.slowTimer > 0 ? '#48cae4' : '#263a29';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(z.x, z.y, z.radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(z.x - z.radius, z.y - z.radius - 12, z.radius * 2, 5);
    ctx.fillStyle = z.boss ? '#ffba08' : '#d00000';
    ctx.fillRect(z.x - z.radius, z.y - z.radius - 12, z.radius * 2 * Math.max(0, z.hp / z.maxHp), 5);
  }
}

function drawBullets() {
  for (const b of state.bullets) {
    ctx.fillStyle = b.color;
    ctx.beginPath();
    ctx.arc(b.x, b.y, 5, 0, Math.PI * 2);
    ctx.fill();
  }
}

function drawParticles() {
  for (const p of state.particles) {
    p.x += p.vx * 0.016;
    p.y += p.vy * 0.016;
    ctx.fillStyle = p.color;
    ctx.fillRect(p.x, p.y, 4, 4);
  }
}

function loop(now) {
  const dt = Math.min(0.05, (now - state.lastTime) / 1000);
  state.lastTime = now;
  update(dt);
  draw();
  requestAnimationFrame(loop);
}

canvas.addEventListener('click', (event) => {
  const rect = canvas.getBoundingClientRect();
  const x = (event.clientX - rect.left) * canvas.width / rect.width;
  const y = (event.clientY - rect.top) * canvas.height / rect.height;
  placeTower(x, y);
});

document.querySelectorAll('.tower-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tower-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    state.selectedTower = btn.dataset.tower;
  });
});

document.getElementById('startWave').addEventListener('click', startWave);
document.getElementById('speedBtn').addEventListener('click', () => {
  state.speed = state.speed === 1 ? 2 : state.speed === 2 ? 3 : 1;
  document.getElementById('speedBtn').textContent = `Vitesse x${state.speed}`;
});
document.getElementById('bloodToggle').addEventListener('change', e => state.effects = e.target.checked);
document.getElementById('autoWaveToggle').addEventListener('change', e => state.autoWave = e.target.checked);

document.getElementById('dailyBtn').addEventListener('click', () => {
  const today = new Date().toISOString().slice(0, 10);
  const last = localStorage.getItem('zbd_daily');
  if (last === today) {
    setMessage('Récompense déjà récupérée aujourd’hui.');
    return;
  }
  localStorage.setItem('zbd_daily', today);
  state.money += 300;
  log('Connexion quotidienne : potion x2 argent 15 min simulée + 300 argent.');
});

document.getElementById('donateBtn').addEventListener('click', () => {
  log('Zone dons : à connecter plus tard aux Developer Products Roblox ou paiement web officiel.');
  setMessage('Merci de soutenir le jeu. Récompense cosmétique uniquement.');
});

document.getElementById('pvpBtn').addEventListener('click', () => {
  const name = document.getElementById('pvpName').value || 'Joueur';
  const reward = document.getElementById('pvpReward').value || 'récompense interne';
  log(`Défi PvP envoyé à ${name} pour ${reward}. Prototype sans argent réel.`);
});

document.getElementById('keysBtn').addEventListener('click', () => document.getElementById('modal').classList.remove('hidden'));
document.getElementById('closeModal').addEventListener('click', () => document.getElementById('modal').classList.add('hidden'));
document.getElementById('saveKeys').addEventListener('click', () => {
  localStorage.setItem('zbd_keys', JSON.stringify({
    pause: document.getElementById('keyPause').value.toUpperCase() || 'P',
    wave: document.getElementById('keyWave').value.toUpperCase() || 'V',
    sell: document.getElementById('keySell').value.toUpperCase() || 'S',
  }));
  document.getElementById('modal').classList.add('hidden');
  log('Touches sauvegardées.');
});

window.addEventListener('keydown', (e) => {
  const keys = JSON.parse(localStorage.getItem('zbd_keys') || '{"pause":"P","wave":"V","sell":"S"}');
  const k = e.key.toUpperCase();
  if (k === keys.pause) state.paused = !state.paused;
  if (k === keys.wave) startWave();
});

if (!CanvasRenderingContext2D.prototype.roundRect) {
  CanvasRenderingContext2D.prototype.roundRect = function(x, y, w, h, r) {
    this.beginPath();
    this.moveTo(x + r, y);
    this.arcTo(x + w, y, x + w, y + h, r);
    this.arcTo(x + w, y + h, x, y + h, r);
    this.arcTo(x, y + h, x, y, r);
    this.arcTo(x, y, x + w, y, r);
    return this;
  };
}

log('Prototype web chargé.');
requestAnimationFrame(loop);
