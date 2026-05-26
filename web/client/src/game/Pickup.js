// Pickup.js
// 5 types de pickups visibles qui drop des zombies tués :
//   - heal   (vert)   : +25 HP
//   - ammo   (bleu)   : buff dégâts ×1.5 pendant 8s
//   - speed  (violet) : buff vitesse ×1.3 pendant 6s
//   - bomb   (rouge)  : détruit tous les zombies dans un rayon 120px
//   - magnet (or)     : attire pickups < 200px pendant 8s
//
// Ramassage par contact (distance < player.r + pickup.r + 6).

import { PICKUP_TYPE } from "../../../shared/constants.js";

const TYPE_DATA = {
  [PICKUP_TYPE.HEAL]:   { color: "#6ed87a", glow: "#a8f0b3", icon: "♥", label: "+25 HP" },
  [PICKUP_TYPE.AMMO]:   { color: "#5da8e8", glow: "#8fcbff", icon: "⚡", label: "DÉGÂTS x1.5" },
  [PICKUP_TYPE.SPEED]:  { color: "#c45ee8", glow: "#e0a0f0", icon: "»", label: "VITESSE x1.3" },
  [PICKUP_TYPE.BOMB]:   { color: "#ff3a3a", glow: "#ff8080", icon: "✸", label: "BOMBE" },
  [PICKUP_TYPE.MAGNET]: { color: "#f4b942", glow: "#ffe6a0", icon: "U", label: "AIMANT" }
};

// Probabilités de drop par tué : 18% chance globale, distribution interne
const DROP_TABLE = [
  { type: PICKUP_TYPE.HEAL,   weight: 35 },
  { type: PICKUP_TYPE.AMMO,   weight: 25 },
  { type: PICKUP_TYPE.SPEED,  weight: 15 },
  { type: PICKUP_TYPE.BOMB,   weight: 5  },   // rare
  { type: PICKUP_TYPE.MAGNET, weight: 5  }    // rare
];
const TOTAL_WEIGHT = DROP_TABLE.reduce((s, d) => s + d.weight, 0);

export class Pickup {
  constructor(x, y, type) {
    this.x = x;
    this.y = y;
    this.type = type;
    this.r = 11;
    this.life = 14;            // disparait après 14s
    this.born = 0;             // temps écoulé pour animation
    this.alive = true;
  }

  /** Tire un type au sort selon DROP_TABLE. Retourne null si pas de drop. */
  static maybeDropFor(zombie) {
    // 18% chance par zombie standard. Heavy = 26%, Boss = 100%.
    const chance = zombie.type === "boss" ? 1.0
                 : zombie.type === "miniBoss" ? 0.7
                 : zombie.type === "heavy" ? 0.26
                 : 0.18;
    if (Math.random() >= chance) return null;
    let roll = Math.random() * TOTAL_WEIGHT;
    for (const d of DROP_TABLE) {
      roll -= d.weight;
      if (roll <= 0) return d.type;
    }
    return DROP_TABLE[0].type;
  }

  update(dt, player, magnetActive) {
    if (!this.alive) return;
    this.born += dt;
    this.life -= dt;
    if (this.life <= 0) this.alive = false;

    // Aimant : se rapproche du joueur si actif et dans la portée
    if (magnetActive) {
      const dx = player.x - this.x;
      const dy = player.y - this.y;
      const d = Math.hypot(dx, dy);
      if (d < 200 && d > 1) {
        const speed = 280;
        this.x += (dx / d) * speed * dt;
        this.y += (dy / d) * speed * dt;
      }
    }
  }

  /** Test collision joueur. Retourne true si ramassé. */
  tryPickup(player) {
    if (!this.alive) return false;
    const dx = this.x - player.x;
    const dy = this.y - player.y;
    if (dx * dx + dy * dy <= (player.r + this.r + 6) ** 2) {
      this.alive = false;
      return true;
    }
    return false;
  }

  draw(ctx) {
    if (!this.alive) return;
    const data = TYPE_DATA[this.type];
    if (!data) return;

    // Animation : pulse + bobbing
    const t = this.born;
    const pulse = 1 + Math.sin(t * 4) * 0.08;
    const bobY = Math.sin(t * 3) * 2;

    // Halo extérieur (glow radial)
    const grad = ctx.createRadialGradient(this.x, this.y + bobY, 4, this.x, this.y + bobY, this.r * 3);
    grad.addColorStop(0, data.glow);
    grad.addColorStop(0.4, data.color);
    grad.addColorStop(1, "rgba(0,0,0,0)");
    ctx.save();
    ctx.globalAlpha = 0.6 + Math.sin(t * 4) * 0.2;
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(this.x, this.y + bobY, this.r * 3, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();

    // Disque central
    ctx.fillStyle = data.color;
    ctx.beginPath();
    ctx.arc(this.x, this.y + bobY, this.r * pulse, 0, Math.PI * 2);
    ctx.fill();

    // Bord blanc fin
    ctx.strokeStyle = data.glow;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // Icône au centre
    ctx.fillStyle = "#1a0d0a";
    ctx.font = "bold 14px Segoe UI, sans-serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText(data.icon, this.x, this.y + bobY + 1);

    // Clignote rouge quand la vie restante < 3s
    if (this.life < 3) {
      const blink = Math.floor(this.life * 5) % 2 === 0;
      if (blink) {
        ctx.strokeStyle = "#ff3030";
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(this.x, this.y + bobY, this.r + 2, 0, Math.PI * 2);
        ctx.stroke();
      }
    }
  }
}

export const PICKUP_TYPE_DATA = TYPE_DATA;
