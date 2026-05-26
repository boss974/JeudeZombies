// CityScene.js
// Dessine le background dynamique selon la mission courante.
// Chaque acte (mission.id) a son propre décor cartoon stylisé "Réunion".
// Tout est dessiné en code Canvas2D (gradients, paths, formes) — aucune image.
//
// Usage :
//   const cityScene = new CityScene();
//   cityScene.draw(ctx, mission, arena, performance.now() / 1000);

// Palette officielle Réunion (cf. GAME_KNOWLEDGE.md)
const PALETTE = {
  orangeFournaise: "#ff6b35",
  rougeFlamboyant: "#e94e1b",
  jauneCannelle:   "#f4b942",
  bleuLagon:       "#0099b8",
  vertEmeraude:    "#1c8b3e",
  sableNoir:       "#2d2d2d",
  bleuPluie:       "#5d8fa8",
  roseHibiscus:    "#e91e63",
  orLampions:      "#ffe6a0",
  neonAlerte:      "#ff3030"
};

export class CityScene {
  constructor() {
    // Cache de particules ambiantes (cendre, pluie, brume) — initialisées paresseusement
    // pour rester déterministe par mission et éviter de recréer à chaque frame.
    this._ambient = null;
    this._ambientMissionId = null;
  }

  // Initialise/recalcule les particules d'ambiance selon la mission.
  // On limite leur nombre pour rester fluide à 60 FPS sur 50 zombies.
  _initAmbient(mission, arena) {
    const id = mission?.id || "stdenis";
    if (this._ambientMissionId === id && this._ambient) return;
    this._ambientMissionId = id;
    const w = arena.width, h = arena.height;
    const list = [];

    // Pluie en biais (Acte IV Saint-Benoît)
    if (id === "stbenoit") {
      for (let i = 0; i < 80; i++) {
        list.push({
          kind: "rain",
          x: Math.random() * w,
          y: Math.random() * h,
          len: 8 + Math.random() * 8,
          speed: 280 + Math.random() * 120
        });
      }
    }

    // Brume basse (Acte V Cilaos)
    if (id === "cilaos") {
      for (let i = 0; i < 12; i++) {
        list.push({
          kind: "fog",
          x: Math.random() * w,
          y: h - 60 - Math.random() * 120,
          r: 60 + Math.random() * 80,
          speed: 12 + Math.random() * 18,
          phase: Math.random() * Math.PI * 2
        });
      }
    }

    // Vapeur de soufre (Acte VI Plaine-des-Cafres)
    if (id === "plaine") {
      for (let i = 0; i < 14; i++) {
        list.push({
          kind: "steam",
          x: Math.random() * w,
          y: 100 + Math.random() * 80,
          r: 30 + Math.random() * 40,
          speed: 8 + Math.random() * 14,
          phase: Math.random() * Math.PI * 2
        });
      }
    }

    // Cendre orange dense (Acte VII Piton-de-la-Fournaise)
    if (id === "fournaise") {
      for (let i = 0; i < 120; i++) {
        list.push({
          kind: "ash",
          x: Math.random() * w,
          y: Math.random() * h,
          size: 1.4 + Math.random() * 2.2,
          speed: 50 + Math.random() * 80,
          drift: (Math.random() - 0.5) * 18
        });
      }
    }

    this._ambient = list;
  }

  // Point d'entrée public.
  // mission : objet STORY.missions[i] ({ id, city, ... })
  // arena   : { width, height }
  // time    : seconds (float) — utilisé pour animer pluie/brume/cendre
  draw(ctx, mission, arena, time) {
    const id = (mission && mission.id) || "stdenis";
    this._initAmbient(mission || { id }, arena);

    switch (id) {
      case "stdenis":   this._drawSaintDenis(ctx, arena, time); break;
      case "stpaul":    this._drawSaintPaul(ctx, arena, time); break;
      case "stpierre":  this._drawSaintPierre(ctx, arena, time); break;
      case "stbenoit":  this._drawSaintBenoit(ctx, arena, time); break;
      case "cilaos":    this._drawCilaos(ctx, arena, time); break;
      case "plaine":    this._drawPlaine(ctx, arena, time); break;
      case "fournaise": this._drawFournaise(ctx, arena, time); break;
      default:          this._drawSaintDenis(ctx, arena, time);
    }

    // Vignette finale pour rentrer le joueur dans la scène
    this._drawVignette(ctx, arena);
  }

  // ---------------------------------------------------------------------------
  // ACTE I — Saint-Denis : front de mer, baie du Barachois, palmiers,
  // sable noir, route côtière, hibiscus, façades en arrière-plan.
  // ---------------------------------------------------------------------------
  _drawSaintDenis(ctx, arena, time) {
    const w = arena.width, h = arena.height;

    // Ciel aube apocalyptique (orange → bleu)
    const sky = ctx.createLinearGradient(0, 0, 0, h * 0.45);
    sky.addColorStop(0, "#3a2a3e");
    sky.addColorStop(0.5, "#7a4a55");
    sky.addColorStop(1, "#c66a4a");
    ctx.fillStyle = sky;
    ctx.fillRect(0, 0, w, h * 0.45);

    // Soleil pâle
    ctx.fillStyle = "rgba(255,230,160,0.5)";
    ctx.beginPath();
    ctx.arc(w * 0.78, h * 0.18, 28, 0, Math.PI * 2);
    ctx.fill();

    // Silhouettes façades préfecture (créole colonial)
    this._drawCreoleFacades(ctx, 0, h * 0.30, w, h * 0.12);

    // Océan / baie du Barachois
    const sea = ctx.createLinearGradient(0, h * 0.42, 0, h * 0.62);
    sea.addColorStop(0, "#0a6a85");
    sea.addColorStop(1, "#053e52");
    ctx.fillStyle = sea;
    ctx.fillRect(0, h * 0.42, w, h * 0.20);

    // Vagues stylisées (3 lignes blanches)
    ctx.strokeStyle = "rgba(255,255,255,0.35)";
    ctx.lineWidth = 1.6;
    for (let i = 0; i < 3; i++) {
      const yy = h * 0.46 + i * 18;
      ctx.beginPath();
      for (let x = 0; x <= w; x += 18) {
        const o = Math.sin((x + time * 60 + i * 30) * 0.04) * 3;
        if (x === 0) ctx.moveTo(x, yy + o);
        else ctx.lineTo(x, yy + o);
      }
      ctx.stroke();
    }

    // Sable noir (sol jouable)
    const sand = ctx.createLinearGradient(0, h * 0.58, 0, h);
    sand.addColorStop(0, "#3a3a3a");
    sand.addColorStop(1, "#1e1e1e");
    ctx.fillStyle = sand;
    ctx.fillRect(0, h * 0.58, w, h * 0.42);

    // Route côtière (bande gris foncé en bas)
    ctx.fillStyle = "#2a2a2e";
    ctx.fillRect(0, h * 0.62, w, 18);
    // Lignes blanches pointillées
    ctx.strokeStyle = "rgba(255,230,160,0.6)";
    ctx.lineWidth = 2;
    ctx.setLineDash([14, 12]);
    ctx.beginPath();
    ctx.moveTo(0, h * 0.62 + 9); ctx.lineTo(w, h * 0.62 + 9);
    ctx.stroke();
    ctx.setLineDash([]);

    // Palmiers en silhouette (3 sur la gauche, 2 sur la droite)
    this._drawPalm(ctx, 80, h * 0.62, 0.9, time);
    this._drawPalm(ctx, 180, h * 0.65, 1.1, time + 0.5);
    this._drawPalm(ctx, w - 220, h * 0.64, 1.0, time + 1.2);
    this._drawPalm(ctx, w - 90, h * 0.62, 0.85, time + 1.8);

    // Hibiscus rose au sol (touches de couleur)
    this._scatterFlowers(ctx, [
      [40, h * 0.78], [220, h * 0.86], [380, h * 0.74],
      [520, h * 0.82], [680, h * 0.78], [820, h * 0.88]
    ], PALETTE.roseHibiscus);
  }

  // ---------------------------------------------------------------------------
  // ACTE II — Saint-Paul : plage de sable doré, cocotiers, lagon turquoise,
  // montagne basse au fond.
  // ---------------------------------------------------------------------------
  _drawSaintPaul(ctx, arena, time) {
    const w = arena.width, h = arena.height;

    // Ciel doré aube
    const sky = ctx.createLinearGradient(0, 0, 0, h * 0.40);
    sky.addColorStop(0, "#6a5a8a");
    sky.addColorStop(0.5, "#d68a5a");
    sky.addColorStop(1, "#f4b942");
    ctx.fillStyle = sky;
    ctx.fillRect(0, 0, w, h * 0.40);

    // Soleil
    const glow = ctx.createRadialGradient(w * 0.72, h * 0.20, 8, w * 0.72, h * 0.20, 50);
    glow.addColorStop(0, "#fff3c8");
    glow.addColorStop(1, "rgba(255,230,160,0)");
    ctx.fillStyle = glow;
    ctx.fillRect(w * 0.55, h * 0.05, w * 0.35, h * 0.30);

    // Montagne basse (silhouette bezier vert sombre)
    ctx.fillStyle = "#1a3a26";
    ctx.beginPath();
    ctx.moveTo(0, h * 0.40);
    ctx.bezierCurveTo(w * 0.15, h * 0.20, w * 0.30, h * 0.32, w * 0.45, h * 0.28);
    ctx.bezierCurveTo(w * 0.60, h * 0.24, w * 0.78, h * 0.34, w, h * 0.30);
    ctx.lineTo(w, h * 0.42);
    ctx.lineTo(0, h * 0.42);
    ctx.closePath();
    ctx.fill();
    // Reflet ciel sur la montagne
    ctx.fillStyle = "rgba(244,185,66,0.15)";
    ctx.fill();

    // Lagon turquoise (large bande)
    const lagoon = ctx.createLinearGradient(0, h * 0.42, 0, h * 0.62);
    lagoon.addColorStop(0, "#1abfd1");
    lagoon.addColorStop(0.6, "#0099b8");
    lagoon.addColorStop(1, "#066e85");
    ctx.fillStyle = lagoon;
    ctx.fillRect(0, h * 0.42, w, h * 0.20);

    // Vaguelettes claires
    ctx.strokeStyle = "rgba(255,255,255,0.45)";
    ctx.lineWidth = 1.4;
    for (let i = 0; i < 4; i++) {
      const yy = h * 0.45 + i * 14;
      ctx.beginPath();
      for (let x = 0; x <= w; x += 22) {
        const o = Math.sin((x + time * 50 + i * 25) * 0.05) * 2.5;
        if (x === 0) ctx.moveTo(x, yy + o);
        else ctx.lineTo(x, yy + o);
      }
      ctx.stroke();
    }

    // Plage de sable doré
    const sand = ctx.createLinearGradient(0, h * 0.58, 0, h);
    sand.addColorStop(0, "#e8c074");
    sand.addColorStop(1, "#a78048");
    ctx.fillStyle = sand;
    ctx.fillRect(0, h * 0.58, w, h * 0.42);

    // Coquillages / cailloux blancs dispersés
    ctx.fillStyle = "rgba(255,255,255,0.55)";
    for (const [px, py] of [[60, h*0.82],[140, h*0.92],[300, h*0.76],
                            [480, h*0.86],[620, h*0.78],[760, h*0.90],[860, h*0.80]]) {
      ctx.beginPath();
      ctx.arc(px, py, 2.2, 0, Math.PI * 2);
      ctx.fill();
    }

    // Cocotiers (4 en bord de plage)
    this._drawPalm(ctx, 90, h * 0.62, 1.2, time);
    this._drawPalm(ctx, 320, h * 0.64, 1.0, time + 0.6);
    this._drawPalm(ctx, w - 280, h * 0.63, 1.1, time + 1.1);
    this._drawPalm(ctx, w - 70, h * 0.62, 0.95, time + 1.7);
  }

  // ---------------------------------------------------------------------------
  // ACTE III — Saint-Pierre : place du marché créole, étals colorés,
  // fontaines, terrasses.
  // ---------------------------------------------------------------------------
  _drawSaintPierre(ctx, arena, time) {
    const w = arena.width, h = arena.height;

    // Ciel chaud après-midi
    const sky = ctx.createLinearGradient(0, 0, 0, h * 0.35);
    sky.addColorStop(0, "#5a3a4a");
    sky.addColorStop(1, "#d6886a");
    ctx.fillStyle = sky;
    ctx.fillRect(0, 0, w, h * 0.35);

    // Façades commerçantes colorées (terrasses du marché)
    const facadeColors = ["#e94e1b", "#f4b942", "#0099b8", "#1c8b3e", "#e91e63",
                          "#ff6b35", "#f4b942", "#0099b8"];
    const facadeW = w / facadeColors.length;
    for (let i = 0; i < facadeColors.length; i++) {
      const x = i * facadeW;
      const fh = 80 + (i % 3) * 14;
      ctx.fillStyle = facadeColors[i];
      ctx.fillRect(x, h * 0.35 - fh, facadeW, fh);
      // Toit triangulaire
      ctx.fillStyle = "#2a1a14";
      ctx.beginPath();
      ctx.moveTo(x, h * 0.35 - fh);
      ctx.lineTo(x + facadeW / 2, h * 0.35 - fh - 18);
      ctx.lineTo(x + facadeW, h * 0.35 - fh);
      ctx.closePath();
      ctx.fill();
      // Fenêtre
      ctx.fillStyle = "rgba(255,230,160,0.7)";
      ctx.fillRect(x + facadeW * 0.30, h * 0.35 - fh + 18, facadeW * 0.40, 16);
    }

    // Pavés de la place
    const ground = ctx.createLinearGradient(0, h * 0.35, 0, h);
    ground.addColorStop(0, "#8a6e54");
    ground.addColorStop(1, "#4a3a28");
    ctx.fillStyle = ground;
    ctx.fillRect(0, h * 0.35, w, h * 0.65);

    // Motif de pavés (lignes croisées légères)
    ctx.strokeStyle = "rgba(0,0,0,0.18)";
    ctx.lineWidth = 1;
    for (let y = h * 0.40; y < h; y += 36) {
      ctx.beginPath();
      ctx.moveTo(0, y); ctx.lineTo(w, y);
      ctx.stroke();
    }
    for (let x = 0; x <= w; x += 48) {
      ctx.beginPath();
      ctx.moveTo(x, h * 0.35); ctx.lineTo(x, h);
      ctx.stroke();
    }

    // Étals du marché (4 cabanes colorées en bordure haute)
    const stalls = [
      { x: 60,  c: "#e94e1b" },
      { x: 260, c: "#f4b942" },
      { x: 480, c: "#1c8b3e" },
      { x: 700, c: "#e91e63" }
    ];
    for (const s of stalls) {
      // Toit rayé
      ctx.fillStyle = s.c;
      ctx.fillRect(s.x, h * 0.40, 110, 14);
      ctx.fillStyle = "#fff";
      for (let i = 0; i < 5; i++) {
        ctx.fillRect(s.x + i * 22, h * 0.40, 11, 14);
      }
      // Piliers
      ctx.fillStyle = "#3a2a1a";
      ctx.fillRect(s.x + 4, h * 0.40 + 14, 4, 22);
      ctx.fillRect(s.x + 102, h * 0.40 + 14, 4, 22);
      // Comptoir (fruits)
      ctx.fillStyle = "#6a4a32";
      ctx.fillRect(s.x, h * 0.40 + 36, 110, 8);
      // Fruits colorés
      const fruitColors = [s.c, "#ffe6a0", "#1c8b3e"];
      for (let i = 0; i < 6; i++) {
        ctx.fillStyle = fruitColors[i % 3];
        ctx.beginPath();
        ctx.arc(s.x + 12 + i * 17, h * 0.40 + 34, 4, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    // Fontaine centrale (rond bleu)
    const fx = w / 2, fy = h * 0.72;
    ctx.fillStyle = "#3a2a1a";
    ctx.beginPath();
    ctx.arc(fx, fy, 44, 0, Math.PI * 2);
    ctx.fill();
    const fountain = ctx.createRadialGradient(fx, fy, 6, fx, fy, 36);
    fountain.addColorStop(0, "#7fd9e8");
    fountain.addColorStop(1, "#0099b8");
    ctx.fillStyle = fountain;
    ctx.beginPath();
    ctx.arc(fx, fy, 36, 0, Math.PI * 2);
    ctx.fill();
    // Jet d'eau animé
    ctx.strokeStyle = "rgba(255,255,255,0.6)";
    ctx.lineWidth = 2;
    for (let i = 0; i < 6; i++) {
      const a = (i / 6) * Math.PI * 2;
      const dx = Math.cos(a) * 12;
      const dy = Math.sin(a) * 12;
      const len = 10 + Math.sin(time * 4 + i) * 4;
      ctx.beginPath();
      ctx.moveTo(fx + dx, fy + dy);
      ctx.lineTo(fx + dx * (1 + len / 20), fy + dy * (1 + len / 20) - 8);
      ctx.stroke();
    }
  }

  // ---------------------------------------------------------------------------
  // ACTE IV — Saint-Benoît : forêt humide vert sombre, pluie en biais,
  // brume, bambous, embouchure.
  // ---------------------------------------------------------------------------
  _drawSaintBenoit(ctx, arena, time) {
    const w = arena.width, h = arena.height;

    // Ciel pluvieux gris-bleu
    const sky = ctx.createLinearGradient(0, 0, 0, h * 0.50);
    sky.addColorStop(0, "#2a3540");
    sky.addColorStop(1, "#5d8fa8");
    ctx.fillStyle = sky;
    ctx.fillRect(0, 0, w, h * 0.50);

    // Forêt sombre derrière (silhouettes d'arbres)
    ctx.fillStyle = "#0e2a1a";
    ctx.beginPath();
    ctx.moveTo(0, h * 0.50);
    for (let x = 0; x <= w; x += 28) {
      const ty = h * 0.32 + Math.sin(x * 0.07) * 14 + (x % 56 === 0 ? -10 : 0);
      ctx.lineTo(x, ty);
    }
    ctx.lineTo(w, h * 0.50);
    ctx.closePath();
    ctx.fill();

    // Bambous (verticales fines vert tendre)
    ctx.strokeStyle = "#3a8a4a";
    ctx.lineWidth = 3;
    for (let i = 0; i < 12; i++) {
      const bx = 20 + i * 80 + Math.sin(i) * 12;
      const baseY = h * 0.50;
      const topY  = h * 0.18 + Math.sin(i * 1.7) * 30;
      ctx.beginPath();
      ctx.moveTo(bx, baseY);
      ctx.lineTo(bx, topY);
      ctx.stroke();
      // Nodules du bambou
      ctx.fillStyle = "#2a6a3a";
      for (let y = baseY - 20; y > topY; y -= 28) {
        ctx.fillRect(bx - 3, y, 6, 2);
      }
      // Feuilles
      ctx.fillStyle = "#5aa840";
      ctx.beginPath();
      ctx.moveTo(bx, topY);
      ctx.lineTo(bx + 8, topY - 14);
      ctx.lineTo(bx - 2, topY - 4);
      ctx.closePath();
      ctx.fill();
    }

    // Embouchure / rivière (bande sombre brillante)
    const river = ctx.createLinearGradient(0, h * 0.50, 0, h * 0.62);
    river.addColorStop(0, "#1a3540");
    river.addColorStop(1, "#0a1a22");
    ctx.fillStyle = river;
    ctx.fillRect(0, h * 0.50, w, h * 0.12);
    // Reflets
    ctx.strokeStyle = "rgba(150,200,220,0.20)";
    ctx.lineWidth = 1;
    for (let i = 0; i < 6; i++) {
      const yy = h * 0.52 + i * 8;
      ctx.beginPath();
      ctx.moveTo(0, yy); ctx.lineTo(w, yy);
      ctx.stroke();
    }

    // Sol humide vert sombre
    const ground = ctx.createLinearGradient(0, h * 0.62, 0, h);
    ground.addColorStop(0, "#1c4a2a");
    ground.addColorStop(1, "#0a2614");
    ctx.fillStyle = ground;
    ctx.fillRect(0, h * 0.62, w, h * 0.38);

    // Flaques (taches sombres brillantes)
    ctx.fillStyle = "rgba(100,140,160,0.30)";
    for (const [px, py, pr] of [[120, h*0.78, 22], [340, h*0.86, 28],
                                 [560, h*0.74, 18], [780, h*0.84, 24]]) {
      ctx.beginPath();
      ctx.ellipse(px, py, pr, pr * 0.45, 0, 0, Math.PI * 2);
      ctx.fill();
    }

    // Brume basse (semi-transparente blanche)
    ctx.fillStyle = "rgba(180,200,210,0.12)";
    for (let i = 0; i < 4; i++) {
      const yy = h * 0.55 + i * 28 + Math.sin(time * 0.5 + i) * 3;
      ctx.fillRect(0, yy, w, 16);
    }

    // Pluie en biais (particules animées)
    ctx.strokeStyle = "rgba(180,200,220,0.55)";
    ctx.lineWidth = 1.2;
    for (const p of this._ambient) {
      if (p.kind !== "rain") continue;
      p.x += p.speed * 0.016 * 0.6;   // dérive horizontale
      p.y += p.speed * 0.016;
      if (p.y > h) { p.y = -10; p.x = Math.random() * w; }
      if (p.x > w) { p.x = 0; }
      ctx.beginPath();
      ctx.moveTo(p.x, p.y);
      ctx.lineTo(p.x - p.len * 0.4, p.y + p.len);
      ctx.stroke();
    }
  }

  // ---------------------------------------------------------------------------
  // ACTE V — Cilaos : cirque montagneux, falaises grises, plancher vert,
  // cascade sur le côté, brume basse.
  // ---------------------------------------------------------------------------
  _drawCilaos(ctx, arena, time) {
    const w = arena.width, h = arena.height;

    // Ciel d'altitude (bleu pâle vers gris)
    const sky = ctx.createLinearGradient(0, 0, 0, h * 0.50);
    sky.addColorStop(0, "#4a5a6e");
    sky.addColorStop(1, "#8aa0b4");
    ctx.fillStyle = sky;
    ctx.fillRect(0, 0, w, h * 0.50);

    // Remparts (falaises grises crénelées)
    ctx.fillStyle = "#3a3a40";
    ctx.beginPath();
    ctx.moveTo(0, h * 0.50);
    ctx.lineTo(0, h * 0.40);
    // Profil gauche
    ctx.bezierCurveTo(w * 0.05, h * 0.10, w * 0.15, h * 0.05, w * 0.25, h * 0.15);
    ctx.bezierCurveTo(w * 0.35, h * 0.05, w * 0.42, h * 0.08, w * 0.50, h * 0.20);
    // Sommet central
    ctx.bezierCurveTo(w * 0.58, h * 0.05, w * 0.70, h * 0.08, w * 0.78, h * 0.18);
    // Profil droit
    ctx.bezierCurveTo(w * 0.88, h * 0.10, w * 0.95, h * 0.12, w, h * 0.30);
    ctx.lineTo(w, h * 0.50);
    ctx.closePath();
    ctx.fill();

    // Stries plus claires sur les falaises
    ctx.strokeStyle = "rgba(110,120,130,0.45)";
    ctx.lineWidth = 1.4;
    for (let i = 0; i < 8; i++) {
      const x = 50 + i * (w - 100) / 7;
      ctx.beginPath();
      ctx.moveTo(x, h * 0.15);
      ctx.bezierCurveTo(x + 6, h * 0.25, x - 4, h * 0.35, x + 2, h * 0.48);
      ctx.stroke();
    }

    // Ombrage des falaises
    ctx.fillStyle = "rgba(20,20,28,0.30)";
    ctx.beginPath();
    ctx.moveTo(0, h * 0.50);
    ctx.lineTo(w, h * 0.50);
    ctx.lineTo(w, h * 0.42);
    ctx.lineTo(0, h * 0.46);
    ctx.closePath();
    ctx.fill();

    // Cascade sur le côté droit (bande blanche verticale)
    const cx = w * 0.86;
    const cascade = ctx.createLinearGradient(cx, h * 0.15, cx, h * 0.65);
    cascade.addColorStop(0, "rgba(255,255,255,0.85)");
    cascade.addColorStop(0.5, "rgba(220,235,245,0.70)");
    cascade.addColorStop(1, "rgba(200,220,235,0.35)");
    ctx.fillStyle = cascade;
    ctx.fillRect(cx - 6, h * 0.15, 12, h * 0.50);
    // Bulles / écume au pied
    ctx.fillStyle = "rgba(255,255,255,0.65)";
    for (let i = 0; i < 8; i++) {
      const bx = cx + (Math.sin(time * 3 + i) * 10);
      const by = h * 0.63 + Math.cos(time * 2 + i) * 3;
      ctx.beginPath();
      ctx.arc(bx, by, 3 + Math.sin(time * 4 + i) * 1.2, 0, Math.PI * 2);
      ctx.fill();
    }

    // Plancher vert (herbe du cirque)
    const ground = ctx.createLinearGradient(0, h * 0.50, 0, h);
    ground.addColorStop(0, "#2a6a3a");
    ground.addColorStop(1, "#1a4a26");
    ctx.fillStyle = ground;
    ctx.fillRect(0, h * 0.50, w, h * 0.50);

    // Touffes d'herbe / arbres
    ctx.fillStyle = "#1c8b3e";
    for (const [tx, ty, tr] of [[80, h*0.62, 12], [220, h*0.70, 10],
                                 [380, h*0.66, 14], [520, h*0.74, 11],
                                 [620, h*0.68, 12], [760, h*0.72, 10]]) {
      ctx.beginPath();
      ctx.arc(tx, ty, tr, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = "#3a2a1a";
      ctx.fillRect(tx - 1, ty + tr - 2, 2, 6);
      ctx.fillStyle = "#1c8b3e";
    }

    // Brume basse (nuages cotonneux animés)
    for (const p of this._ambient) {
      if (p.kind !== "fog") continue;
      p.x += p.speed * 0.016;
      if (p.x - p.r > w) p.x = -p.r;
      const grad = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.r);
      grad.addColorStop(0, "rgba(220,228,235,0.40)");
      grad.addColorStop(1, "rgba(220,228,235,0)");
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  // ---------------------------------------------------------------------------
  // ACTE VI — Plaine-des-Cafres : prairie haute, vache stylisée silhouette,
  // route N3 qui monte, soufre/vapeur orange à l'horizon.
  // ---------------------------------------------------------------------------
  _drawPlaine(ctx, arena, time) {
    const w = arena.width, h = arena.height;

    // Ciel pré-volcan (rouge sourd à l'horizon)
    const sky = ctx.createLinearGradient(0, 0, 0, h * 0.45);
    sky.addColorStop(0, "#3a2a3a");
    sky.addColorStop(0.5, "#7a4a3a");
    sky.addColorStop(1, "#c66a4a");
    ctx.fillStyle = sky;
    ctx.fillRect(0, 0, w, h * 0.45);

    // Volcan à l'horizon (silhouette orange)
    ctx.fillStyle = "#5a2a1a";
    ctx.beginPath();
    ctx.moveTo(w * 0.55, h * 0.45);
    ctx.lineTo(w * 0.72, h * 0.22);
    ctx.lineTo(w * 0.85, h * 0.28);
    ctx.lineTo(w * 0.95, h * 0.45);
    ctx.closePath();
    ctx.fill();
    // Glow orange au cratère
    const cglow = ctx.createRadialGradient(w * 0.75, h * 0.24, 4, w * 0.75, h * 0.24, 40);
    cglow.addColorStop(0, "rgba(255,107,53,0.85)");
    cglow.addColorStop(1, "rgba(255,107,53,0)");
    ctx.fillStyle = cglow;
    ctx.fillRect(w * 0.62, h * 0.10, w * 0.30, h * 0.25);

    // Collines vertes intermédiaires
    ctx.fillStyle = "#2a5a3a";
    ctx.beginPath();
    ctx.moveTo(0, h * 0.45);
    ctx.bezierCurveTo(w * 0.20, h * 0.38, w * 0.40, h * 0.42, w * 0.55, h * 0.40);
    ctx.bezierCurveTo(w * 0.70, h * 0.38, w * 0.85, h * 0.42, w, h * 0.40);
    ctx.lineTo(w, h * 0.50);
    ctx.lineTo(0, h * 0.50);
    ctx.closePath();
    ctx.fill();

    // Prairie verte (haute herbe)
    const ground = ctx.createLinearGradient(0, h * 0.48, 0, h);
    ground.addColorStop(0, "#3a8a4a");
    ground.addColorStop(1, "#1a5a26");
    ctx.fillStyle = ground;
    ctx.fillRect(0, h * 0.48, w, h * 0.52);

    // Brins d'herbe (lignes verticales fines)
    ctx.strokeStyle = "rgba(80,140,90,0.55)";
    ctx.lineWidth = 1;
    for (let i = 0; i < 120; i++) {
      const gx = (i * 17 + Math.sin(i) * 8) % w;
      const gy = h * 0.55 + (i % 10) * 40;
      if (gy >= h) continue;
      ctx.beginPath();
      ctx.moveTo(gx, gy);
      ctx.lineTo(gx + Math.sin(i) * 2, gy - 6 - (i % 4));
      ctx.stroke();
    }

    // Route N3 qui monte (perspective vers le volcan)
    ctx.fillStyle = "#2a2a2e";
    ctx.beginPath();
    ctx.moveTo(w * 0.35, h);
    ctx.lineTo(w * 0.65, h);
    ctx.lineTo(w * 0.72, h * 0.50);
    ctx.lineTo(w * 0.68, h * 0.50);
    ctx.closePath();
    ctx.fill();
    // Marquage central
    ctx.strokeStyle = "rgba(255,230,160,0.75)";
    ctx.lineWidth = 2;
    ctx.setLineDash([10, 14]);
    ctx.beginPath();
    ctx.moveTo(w * 0.50, h);
    ctx.lineTo(w * 0.70, h * 0.50);
    ctx.stroke();
    ctx.setLineDash([]);

    // Vache silhouette (forme cartoon noire/blanche)
    this._drawCow(ctx, w * 0.18, h * 0.78);
    this._drawCow(ctx, w * 0.82, h * 0.72);

    // Vapeur soufre orange (volutes animées)
    for (const p of this._ambient) {
      if (p.kind !== "steam") continue;
      p.x += p.speed * 0.016;
      if (p.x > w) p.x = -p.r;
      const grad = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.r);
      grad.addColorStop(0, "rgba(255,140,70,0.30)");
      grad.addColorStop(1, "rgba(255,140,70,0)");
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  // ---------------------------------------------------------------------------
  // ACTE VII — Piton-de-la-Fournaise : cratère, lave qui coule, cendre dense,
  // ciel rouge profond, fumée.
  // ---------------------------------------------------------------------------
  _drawFournaise(ctx, arena, time) {
    const w = arena.width, h = arena.height;

    // Ciel rouge profond / fumée
    const sky = ctx.createLinearGradient(0, 0, 0, h * 0.50);
    sky.addColorStop(0, "#1a0a0a");
    sky.addColorStop(0.4, "#5a1a14");
    sky.addColorStop(1, "#a8341a");
    ctx.fillStyle = sky;
    ctx.fillRect(0, 0, w, h * 0.50);

    // Fumée volcanique (volutes noires animées en arrière-plan)
    ctx.fillStyle = "rgba(20,10,10,0.45)";
    for (let i = 0; i < 6; i++) {
      const sx = (i * 180 + time * 14) % (w + 200) - 100;
      const sy = h * 0.10 + Math.sin(time * 0.5 + i) * 20;
      const sr = 60 + Math.sin(time + i) * 15;
      const grad = ctx.createRadialGradient(sx, sy, 0, sx, sy, sr);
      grad.addColorStop(0, "rgba(40,20,20,0.65)");
      grad.addColorStop(1, "rgba(40,20,20,0)");
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.arc(sx, sy, sr, 0, Math.PI * 2);
      ctx.fill();
    }

    // Cratère central (montagne sombre avec sommet ouvert)
    ctx.fillStyle = "#1a0e0e";
    ctx.beginPath();
    ctx.moveTo(0, h * 0.50);
    ctx.lineTo(w * 0.20, h * 0.42);
    ctx.lineTo(w * 0.38, h * 0.30);
    ctx.lineTo(w * 0.46, h * 0.26);
    ctx.lineTo(w * 0.54, h * 0.26);
    ctx.lineTo(w * 0.62, h * 0.30);
    ctx.lineTo(w * 0.80, h * 0.42);
    ctx.lineTo(w, h * 0.50);
    ctx.lineTo(w, h * 0.50);
    ctx.lineTo(0, h * 0.50);
    ctx.closePath();
    ctx.fill();

    // Cratère intérieur orange éclatant
    const crater = ctx.createRadialGradient(w * 0.50, h * 0.28, 4, w * 0.50, h * 0.28, 50);
    crater.addColorStop(0, "#fff39c");
    crater.addColorStop(0.4, "#ff6b35");
    crater.addColorStop(1, "rgba(233,78,27,0)");
    ctx.fillStyle = crater;
    ctx.beginPath();
    ctx.ellipse(w * 0.50, h * 0.28, 50, 12, 0, 0, Math.PI * 2);
    ctx.fill();

    // Lave qui coule (2 coulées en cascade depuis le cratère)
    const lavaPaths = [
      [w * 0.48, w * 0.40, w * 0.34, w * 0.30],   // coulée gauche
      [w * 0.52, w * 0.60, w * 0.68, w * 0.74]    // coulée droite
    ];
    for (const path of lavaPaths) {
      const grad = ctx.createLinearGradient(0, h * 0.28, 0, h * 0.60);
      grad.addColorStop(0, "#fff39c");
      grad.addColorStop(0.3, "#ff6b35");
      grad.addColorStop(1, "#e94e1b");
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.moveTo(path[0], h * 0.28);
      ctx.bezierCurveTo(path[1], h * 0.35, path[2], h * 0.45, path[3], h * 0.55);
      ctx.lineTo(path[3] + 8, h * 0.55);
      ctx.bezierCurveTo(path[2] + 6, h * 0.45, path[1] + 4, h * 0.35, path[0] + 4, h * 0.28);
      ctx.closePath();
      ctx.fill();
      // Glow lumineux sur la coulée
      ctx.strokeStyle = "rgba(255,255,200,0.5)";
      ctx.lineWidth = 1.5;
      ctx.stroke();
    }

    // Sol de cendre noire
    const ash = ctx.createLinearGradient(0, h * 0.50, 0, h);
    ash.addColorStop(0, "#2a1a14");
    ash.addColorStop(1, "#0e0a0a");
    ctx.fillStyle = ash;
    ctx.fillRect(0, h * 0.50, w, h * 0.50);

    // Fissures de lave dans le sol (pulsation)
    const pulse = 0.6 + Math.sin(time * 3) * 0.2;
    ctx.strokeStyle = `rgba(255,107,53,${pulse})`;
    ctx.lineWidth = 2;
    for (const [x1, y1, x2, y2] of [
      [60, h*0.62, 200, h*0.78],
      [280, h*0.70, 420, h*0.92],
      [480, h*0.60, 620, h*0.82],
      [680, h*0.66, 820, h*0.90],
      [120, h*0.86, 300, h*0.96]
    ]) {
      ctx.beginPath();
      ctx.moveTo(x1, y1);
      ctx.bezierCurveTo((x1+x2)/2 + 10, (y1+y2)/2 - 8, (x1+x2)/2 - 6, (y1+y2)/2 + 6, x2, y2);
      ctx.stroke();
    }

    // Cendre orange qui tombe en pluie dense (particules animées)
    for (const p of this._ambient) {
      if (p.kind !== "ash") continue;
      p.y += p.speed * 0.016;
      p.x += p.drift * 0.016;
      if (p.y > h) { p.y = -5; p.x = Math.random() * w; }
      ctx.fillStyle = `rgba(255,${100 + Math.floor(Math.random() * 50)},50,0.75)`;
      ctx.fillRect(p.x, p.y, p.size, p.size);
    }

    // Glow rouge global subtil
    ctx.fillStyle = "rgba(255,80,30,0.06)";
    ctx.fillRect(0, 0, w, h);
  }

  // ===========================================================================
  // Primitives partagées
  // ===========================================================================

  // Palmier en silhouette cartoon (tronc courbe + 5 palmes)
  _drawPalm(ctx, baseX, baseY, scale = 1, time = 0) {
    ctx.save();
    ctx.translate(baseX, baseY);
    ctx.scale(scale, scale);

    // Tronc courbe
    ctx.strokeStyle = "#3a2418";
    ctx.lineWidth = 8;
    ctx.lineCap = "round";
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.bezierCurveTo(8, -28, -6, -60, 4, -90);
    ctx.stroke();
    // Texture du tronc
    ctx.strokeStyle = "#1a0e08";
    ctx.lineWidth = 1.4;
    for (let i = 0; i < 6; i++) {
      ctx.beginPath();
      ctx.moveTo(-3, -15 - i * 13);
      ctx.lineTo(5, -15 - i * 13);
      ctx.stroke();
    }

    // Palmes (5 grandes feuilles)
    ctx.fillStyle = "#1c5a2a";
    const sway = Math.sin(time * 1.4) * 0.15;
    const angles = [-1.4, -0.8, -0.2, 0.4, 1.0];
    for (const baseA of angles) {
      const a = baseA + sway;
      const tx = 4 + Math.cos(a) * 30;
      const ty = -90 + Math.sin(a) * 18;
      ctx.beginPath();
      ctx.moveTo(4, -90);
      ctx.quadraticCurveTo(tx * 0.5 + 4, ty - 18, tx, ty);
      ctx.quadraticCurveTo(tx * 0.6 + 4, ty + 4, 4, -88);
      ctx.closePath();
      ctx.fill();
    }
    // Coloration plus claire sur le dessus
    ctx.fillStyle = "rgba(80,160,80,0.35)";
    for (const baseA of angles) {
      const a = baseA + sway;
      const tx = 4 + Math.cos(a) * 28;
      const ty = -88 + Math.sin(a) * 16;
      ctx.beginPath();
      ctx.moveTo(4, -88);
      ctx.quadraticCurveTo(tx * 0.5 + 4, ty - 12, tx, ty);
      ctx.quadraticCurveTo(tx * 0.6 + 4, ty + 2, 4, -86);
      ctx.closePath();
      ctx.fill();
    }

    // Cocos (petits cercles bruns)
    ctx.fillStyle = "#2a1a08";
    ctx.beginPath();
    ctx.arc(-2, -86, 3, 0, Math.PI * 2);
    ctx.arc(6, -84, 3, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }

  // Façades créoles colorées en arrière-plan
  _drawCreoleFacades(ctx, x, y, w, h) {
    const colors = [PALETTE.jauneCannelle, PALETTE.bleuLagon, PALETTE.rougeFlamboyant,
                    PALETTE.vertEmeraude, PALETTE.roseHibiscus];
    const facadeW = 80;
    const count = Math.ceil(w / facadeW);
    for (let i = 0; i < count; i++) {
      const fx = x + i * facadeW;
      const fh = h * (0.7 + (i % 3) * 0.1);
      ctx.fillStyle = colors[i % colors.length];
      ctx.fillRect(fx, y + h - fh, facadeW - 2, fh);
      // Toit
      ctx.fillStyle = "#3a2418";
      ctx.fillRect(fx, y + h - fh - 6, facadeW - 2, 6);
      // Volets (rectangles plus sombres)
      ctx.fillStyle = "rgba(0,0,0,0.30)";
      ctx.fillRect(fx + 14, y + h - fh + 14, 14, fh * 0.40);
      ctx.fillRect(fx + facadeW - 30, y + h - fh + 14, 14, fh * 0.40);
      // Porte
      ctx.fillRect(fx + facadeW * 0.40, y + h - fh * 0.50, 14, fh * 0.50);
    }
  }

  // Hibiscus colorés au sol
  _scatterFlowers(ctx, positions, color) {
    for (const [x, y] of positions) {
      // 5 pétales en rosace
      ctx.fillStyle = color;
      for (let i = 0; i < 5; i++) {
        const a = (i / 5) * Math.PI * 2;
        ctx.beginPath();
        ctx.ellipse(x + Math.cos(a) * 3, y + Math.sin(a) * 3, 4, 2.5, a, 0, Math.PI * 2);
        ctx.fill();
      }
      // Cœur jaune
      ctx.fillStyle = PALETTE.orLampions;
      ctx.beginPath();
      ctx.arc(x, y, 1.6, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  // Vache cartoon (silhouette noire avec taches blanches)
  _drawCow(ctx, x, y) {
    ctx.save();
    ctx.translate(x, y);
    // Corps
    ctx.fillStyle = "#1a1a1a";
    ctx.fillRect(-18, -10, 36, 18);
    // Tête
    ctx.fillRect(-26, -6, 10, 12);
    // Pattes
    ctx.fillRect(-14, 8, 4, 8);
    ctx.fillRect(-4, 8, 4, 8);
    ctx.fillRect(6, 8, 4, 8);
    ctx.fillRect(14, 8, 4, 8);
    // Taches blanches
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(-12, -8, 8, 6);
    ctx.fillRect(2, -2, 10, 8);
    ctx.fillRect(-22, -4, 4, 4);
    // Oreille rose
    ctx.fillStyle = PALETTE.roseHibiscus;
    ctx.fillRect(-22, -8, 3, 3);
    ctx.restore();
  }

  // Vignette : assombrit les coins pour mieux faire ressortir le joueur
  _drawVignette(ctx, arena) {
    const w = arena.width, h = arena.height;
    const grad = ctx.createRadialGradient(w / 2, h / 2, h * 0.30,
                                          w / 2, h / 2, h * 0.75);
    grad.addColorStop(0, "rgba(0,0,0,0)");
    grad.addColorStop(1, "rgba(0,0,0,0.42)");
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, w, h);
  }
}
