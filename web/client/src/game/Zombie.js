import { CONFIG } from "../../../shared/config.js";

// Zombie générique paramétré par type. Rendu cartoon non-gore par type
// (silhouette humanoïde, yeux rouges, bras tendus, balancement de marche).
//
// Types : normal / fast / heavy / miniBoss / boss
// Tous gardent l'API : update, draw, damage_take.
export class Zombie {
  constructor(x, y, type) {
    const stats = CONFIG.zombie[type];
    this.type = type;
    this.x = x;
    this.y = y;
    this.r = stats.radius;
    this.speed = stats.speed;
    this.hp = stats.hp;
    this.maxHp = stats.hp;
    this.damage = stats.damage;
    this.score = stats.score;
    this.coins = stats.coins;
    this.color = stats.color;
    this.touchCooldown = 0;
    this.alive = true;
    // Animation : on stocke la phase (0..2π) qui avance avec le temps.
    // Plus le zombie est rapide, plus l'oscillation est rapide.
    this._walkPhase = Math.random() * Math.PI * 2;
    this._facing = 0;        // angle calculé dans update vers la cible
  }

  update(dt, target) {
    if (!this.alive) return;
    const dx = target.x - this.x;
    const dy = target.y - this.y;
    const d = Math.hypot(dx, dy) || 1;
    this.x += (dx / d) * this.speed * dt;
    this.y += (dy / d) * this.speed * dt;
    this._facing = Math.atan2(dy, dx);
    this.touchCooldown = Math.max(0, this.touchCooldown - dt);
    // Vitesse d'oscillation proportionnelle à la vitesse de déplacement.
    // Fast oscille vite, heavy oscille lentement.
    this._walkPhase = (this._walkPhase + dt * (this.speed / 14)) % (Math.PI * 2);
  }

  damage_take(amount) {
    this.hp -= amount;
    if (this.hp <= 0) this.alive = false;
  }

  // time : timestamp seconds (optionnel, pour des effets globaux).
  draw(ctx, time = 0) {
    if (!this.alive) return;

    ctx.save();
    ctx.translate(this.x, this.y);

    // Ombre au sol
    ctx.fillStyle = "rgba(0,0,0,0.40)";
    ctx.beginPath();
    ctx.ellipse(0, this.r + 2, this.r * 0.9, this.r * 0.3, 0, 0, Math.PI * 2);
    ctx.fill();

    // Glow orange autour des boss
    if (this.type === "boss") {
      const glow = ctx.createRadialGradient(0, 0, this.r * 0.5,
                                            0, 0, this.r * 2.0);
      glow.addColorStop(0, "rgba(255,107,53,0.50)");
      glow.addColorStop(0.6, "rgba(255,80,30,0.20)");
      glow.addColorStop(1, "rgba(255,80,30,0)");
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(0, 0, this.r * 2.0, 0, Math.PI * 2);
      ctx.fill();
    }

    // Couleurs par type (palette stylisée non-gore : verts pour zombies, rouges pour bosses)
    const palette = this._getPalette();

    // Oscillation des bras (tendus devant)
    const armSwing = Math.sin(this._walkPhase) * 3;
    // Oscillation des jambes
    const legSwing = Math.sin(this._walkPhase) * 4;

    // Jambes (deux barres sous le corps)
    ctx.strokeStyle = palette.dark;
    ctx.lineWidth = Math.max(2, this.r * 0.16);
    ctx.lineCap = "round";
    // Jambe gauche
    ctx.beginPath();
    ctx.moveTo(-this.r * 0.3, this.r * 0.7);
    ctx.lineTo(-this.r * 0.3 + legSwing * 0.4, this.r * 1.2);
    ctx.stroke();
    // Jambe droite
    ctx.beginPath();
    ctx.moveTo(this.r * 0.3, this.r * 0.7);
    ctx.lineTo(this.r * 0.3 - legSwing * 0.4, this.r * 1.2);
    ctx.stroke();

    // Corps (forme adaptée au type : Heavy = plus large, Fast = plus mince)
    const bodyW = this.type === "fast" ? this.r * 0.9
                : this.type === "heavy" ? this.r * 1.5
                : this.type === "miniBoss" ? this.r * 1.2
                : this.type === "boss" ? this.r * 1.3
                : this.r * 1.1;
    const bodyH = this.r * 1.3;
    ctx.fillStyle = palette.body;
    ctx.beginPath();
    if (ctx.roundRect) ctx.roundRect(-bodyW / 2, -bodyH * 0.3, bodyW, bodyH, 4);
    else ctx.rect(-bodyW / 2, -bodyH * 0.3, bodyW, bodyH);
    ctx.fill();
    // Contour plus sombre
    ctx.strokeStyle = palette.dark;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // Décoration : marques pour heavy (rayures sombres), bandes pour boss
    if (this.type === "heavy") {
      ctx.strokeStyle = palette.dark;
      ctx.lineWidth = 1.2;
      for (let i = -1; i <= 1; i++) {
        ctx.beginPath();
        ctx.moveTo(-bodyW * 0.4, i * 6 + bodyH * 0.2);
        ctx.lineTo(bodyW * 0.4, i * 6 + bodyH * 0.2);
        ctx.stroke();
      }
    }

    // Tête (cercle de la couleur principale)
    ctx.fillStyle = palette.body;
    ctx.beginPath();
    ctx.arc(0, -bodyH * 0.5, this.r * 0.55, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = palette.dark;
    ctx.lineWidth = 1.4;
    ctx.stroke();

    // Yeux rouges (deux billes brillantes)
    const eyeR = Math.max(1.2, this.r * 0.13);
    const eyeOff = this.r * 0.20;
    ctx.fillStyle = "#ff3030";
    ctx.beginPath();
    ctx.arc(-eyeOff, -bodyH * 0.55, eyeR, 0, Math.PI * 2);
    ctx.arc(eyeOff, -bodyH * 0.55, eyeR, 0, Math.PI * 2);
    ctx.fill();
    // Lueur des yeux (cercle plus grand semi-transparent)
    ctx.fillStyle = "rgba(255,48,48,0.40)";
    ctx.beginPath();
    ctx.arc(-eyeOff, -bodyH * 0.55, eyeR * 2, 0, Math.PI * 2);
    ctx.arc(eyeOff, -bodyH * 0.55, eyeR * 2, 0, Math.PI * 2);
    ctx.fill();

    // Bouche stylisée (trait sombre pour mini-boss/boss)
    if (this.type === "miniBoss" || this.type === "boss") {
      ctx.strokeStyle = "#1a0a0a";
      ctx.lineWidth = 1.6;
      ctx.beginPath();
      ctx.moveTo(-this.r * 0.18, -bodyH * 0.42);
      ctx.lineTo(this.r * 0.18, -bodyH * 0.42);
      ctx.stroke();
    }

    // Bras tendus devant (deux lignes vers l'avant + oscillation)
    ctx.strokeStyle = palette.body;
    ctx.lineWidth = Math.max(2.5, this.r * 0.18);
    ctx.lineCap = "round";
    // Bras gauche
    ctx.beginPath();
    ctx.moveTo(-bodyW * 0.4, 0);
    ctx.lineTo(-bodyW * 0.4 + this.r * 0.7, this.r * 0.2 + armSwing * 0.3);
    ctx.stroke();
    // Bras droit
    ctx.beginPath();
    ctx.moveTo(bodyW * 0.4, 0);
    ctx.lineTo(bodyW * 0.4 + this.r * 0.7, this.r * 0.2 - armSwing * 0.3);
    ctx.stroke();
    // Mains (petites griffes sombres)
    ctx.fillStyle = palette.dark;
    ctx.beginPath();
    ctx.arc(-bodyW * 0.4 + this.r * 0.7, this.r * 0.2 + armSwing * 0.3, this.r * 0.10, 0, Math.PI * 2);
    ctx.arc(bodyW * 0.4 + this.r * 0.7, this.r * 0.2 - armSwing * 0.3, this.r * 0.10, 0, Math.PI * 2);
    ctx.fill();

    // Couronne d'épines rouge (mini-boss)
    if (this.type === "miniBoss") {
      ctx.fillStyle = "#a82020";
      ctx.strokeStyle = "#5a0a0a";
      ctx.lineWidth = 1;
      const headTop = -bodyH * 0.5 - this.r * 0.55;
      for (let i = 0; i < 7; i++) {
        const ang = -Math.PI + (i / 6) * Math.PI;
        const sx = Math.cos(ang) * this.r * 0.55;
        const sy = -bodyH * 0.5 + Math.sin(ang) * this.r * 0.55;
        const tipX = Math.cos(ang) * this.r * 0.85;
        const tipY = -bodyH * 0.5 + Math.sin(ang) * this.r * 0.85;
        ctx.beginPath();
        ctx.moveTo(sx - 2, sy);
        ctx.lineTo(tipX, tipY);
        ctx.lineTo(sx + 2, sy);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
      }
    }

    // Aura orange pulse pour le boss (cercle clignotant)
    if (this.type === "boss") {
      const pulse = 0.5 + Math.sin(time * 4) * 0.5;
      ctx.strokeStyle = `rgba(255,107,53,${0.4 + pulse * 0.3})`;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(0, 0, this.r + 4 + pulse * 3, 0, Math.PI * 2);
      ctx.stroke();
    }

    ctx.restore();

    // Barre de vie au-dessus (gros mobs uniquement)
    if (this.maxHp > 60 && this.hp < this.maxHp) {
      const w = this.r * 2.4;
      const h = 4;
      const x = this.x - w / 2;
      const y = this.y - this.r - bodyH * 0.5 - 12;
      ctx.fillStyle = "rgba(0,0,0,0.6)";
      ctx.fillRect(x - 1, y - 1, w + 2, h + 2);
      // Couleur change selon HP
      const ratio = this.hp / this.maxHp;
      const hpColor = ratio > 0.5 ? "#6ed87a" : ratio > 0.25 ? "#f4b942" : "#ff3030";
      ctx.fillStyle = hpColor;
      ctx.fillRect(x, y, w * ratio, h);
    }
  }

  // Palette de couleurs par type. Renvoie body (couleur principale) et dark (contour/détails).
  _getPalette() {
    switch (this.type) {
      case "fast":
        // Plus pâle, plus vif (style sprinter)
        return { body: "#a8db7a", dark: "#3a6a28" };
      case "heavy":
        // Vert sombre épaules larges
        return { body: "#2a5a2a", dark: "#0e2a14" };
      case "miniBoss":
        // Rouge sombre
        return { body: "#a82828", dark: "#4a0a0a" };
      case "boss":
        // Rouge vif éclatant
        return { body: "#d92020", dark: "#6a0a0a" };
      case "normal":
      default:
        // Vert moyen classique
        return { body: "#5a8a4a", dark: "#1a3a14" };
    }
  }
}
