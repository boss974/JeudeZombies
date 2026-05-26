// Minimap.js
// Mini-carte 180x180px en haut à droite du canvas. Centrée sur le joueur,
// affiche une zone de RANGE pixels autour de lui. Joueur au centre,
// zombies en rouge, défenses en jaune/marron.

const SIZE = 180;
const MARGIN = 12;
const RANGE = 200;   // demi-côté de la zone affichée (donc 400x400 px monde)

export class Minimap {
  constructor() {
    this.size = SIZE;
  }

  // arena : { width, height } pour positionner la minimap dans le canvas
  // player : { x, y }
  // zombies : array d'objets { x, y, type, alive }
  // defenses : array d'objets { x, y, type, alive }
  // bullets  : array d'objets { x, y } (facultatif, en jaune)
  draw(ctx, arena, player, zombies, defenses, bullets) {
    const x0 = arena.width - SIZE - MARGIN;
    const y0 = MARGIN;

    ctx.save();

    // Fond sombre semi-transparent
    ctx.fillStyle = "rgba(20,14,14,0.78)";
    ctx.fillRect(x0, y0, SIZE, SIZE);

    // Bordure or Lampions
    ctx.strokeStyle = "#ffe6a0";
    ctx.lineWidth = 2;
    ctx.strokeRect(x0 + 0.5, y0 + 0.5, SIZE - 1, SIZE - 1);

    // Coins décoratifs (style boussole créole)
    ctx.fillStyle = "#ff6b35";
    const cornerSize = 6;
    ctx.fillRect(x0, y0, cornerSize, 2);
    ctx.fillRect(x0, y0, 2, cornerSize);
    ctx.fillRect(x0 + SIZE - cornerSize, y0, cornerSize, 2);
    ctx.fillRect(x0 + SIZE - 2, y0, 2, cornerSize);
    ctx.fillRect(x0, y0 + SIZE - 2, cornerSize, 2);
    ctx.fillRect(x0, y0 + SIZE - cornerSize, 2, cornerSize);
    ctx.fillRect(x0 + SIZE - cornerSize, y0 + SIZE - 2, cornerSize, 2);
    ctx.fillRect(x0 + SIZE - 2, y0 + SIZE - cornerSize, 2, cornerSize);

    // Titre "RADAR" en haut
    ctx.fillStyle = "#ffe6a0";
    ctx.font = "bold 9px Segoe UI, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("RADAR", x0 + SIZE / 2, y0 - 2);

    // Clip pour confiner les points à l'intérieur du cadre
    ctx.beginPath();
    ctx.rect(x0 + 2, y0 + 2, SIZE - 4, SIZE - 4);
    ctx.clip();

    // Helper : convertit coord monde → coord minimap
    const scale = (SIZE / 2) / RANGE;
    const cx = x0 + SIZE / 2;
    const cy = y0 + SIZE / 2;
    const mapPoint = (wx, wy) => ({
      x: cx + (wx - player.x) * scale,
      y: cy + (wy - player.y) * scale
    });

    // Lignes de croix légères (boussole)
    ctx.strokeStyle = "rgba(255,230,160,0.18)";
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(x0, cy); ctx.lineTo(x0 + SIZE, cy);
    ctx.moveTo(cx, y0); ctx.lineTo(cx, y0 + SIZE);
    ctx.stroke();
    // Cercle de portée
    ctx.beginPath();
    ctx.arc(cx, cy, SIZE * 0.30, 0, Math.PI * 2);
    ctx.stroke();

    // Défenses (carrés jaunes/marron)
    if (defenses) {
      for (const d of defenses) {
        if (!d.alive) continue;
        const p = mapPoint(d.x, d.y);
        if (this._outside(p, x0, y0)) continue;
        ctx.fillStyle = d.type === "turret" ? "#f4b942" : "#8a5a2b";
        ctx.fillRect(p.x - 2, p.y - 2, 4, 4);
      }
    }

    // Balles (petits points or)
    if (bullets) {
      ctx.fillStyle = "rgba(255,230,160,0.85)";
      for (const b of bullets) {
        if (b.life <= 0) continue;
        const p = mapPoint(b.x, b.y);
        if (this._outside(p, x0, y0)) continue;
        ctx.fillRect(p.x - 1, p.y - 1, 2, 2);
      }
    }

    // Zombies (cercles rouges, taille selon type)
    if (zombies) {
      for (const z of zombies) {
        if (!z.alive) continue;
        const p = mapPoint(z.x, z.y);
        // Si hors de la zone radar, on dessine un indicateur sur le bord
        if (this._outside(p, x0, y0)) {
          this._drawEdgeArrow(ctx, x0, y0, cx, cy, z.x - player.x, z.y - player.y);
          continue;
        }
        const r = z.type === "boss" ? 4
                : z.type === "miniBoss" ? 3.5
                : z.type === "heavy" ? 3
                : z.type === "fast" ? 2
                : 2.5;
        ctx.fillStyle = z.type === "boss" ? "#ff3030"
                     : z.type === "miniBoss" ? "#e94e1b"
                     : z.type === "heavy" ? "#3a5a2a"
                     : z.type === "fast" ? "#8acb6a"
                     : "#5a8a4a";
        ctx.beginPath();
        ctx.arc(p.x, p.y, r, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    // Joueur au centre (point bleu lagon + halo)
    ctx.fillStyle = "rgba(0,153,184,0.30)";
    ctx.beginPath();
    ctx.arc(cx, cy, 8, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "#0099b8";
    ctx.beginPath();
    ctx.arc(cx, cy, 4, 0, Math.PI * 2);
    ctx.fill();
    // Point central blanc
    ctx.fillStyle = "#ffe6a0";
    ctx.beginPath();
    ctx.arc(cx, cy, 1.5, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }

  // True si le point est hors du rectangle de la minimap
  _outside(p, x0, y0) {
    return p.x < x0 + 4 || p.x > x0 + SIZE - 4
        || p.y < y0 + 4 || p.y > y0 + SIZE - 4;
  }

  // Petite flèche rouge au bord indiquant un zombie hors-radar
  _drawEdgeArrow(ctx, x0, y0, cx, cy, dx, dy) {
    const ang = Math.atan2(dy, dx);
    const radius = SIZE / 2 - 6;
    const ex = cx + Math.cos(ang) * radius;
    const ey = cy + Math.sin(ang) * radius;
    ctx.save();
    ctx.translate(ex, ey);
    ctx.rotate(ang);
    ctx.fillStyle = "rgba(255,48,48,0.75)";
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(-4, -3);
    ctx.lineTo(-4, 3);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
  }
}
