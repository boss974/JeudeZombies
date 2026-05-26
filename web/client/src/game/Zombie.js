import { CONFIG } from "../../../shared/config.js";

// Zombie générique paramétré par type. Rendu cartoon non-gore par type
// (silhouette humanoïde, yeux rouges, bras tendus, balancement de marche).
//
// Types : normal / fast / heavy / exploder / shielded / miniBoss / boss
// Tous gardent l'API : update, draw, damage_take.
//
// Comportements spéciaux :
// - exploder : explose au contact ET à la mort (AOE 80px / 30 dmg, géré par
//   GameScene via le flag _shouldExplode).
// - shielded : porte un bouclier frontal qui absorbe 55% des dégâts si le tir
//   arrive de face (arc de 0.65π autour du facing). On contourne ou on tir
//   depuis une tourelle latérale.
// - boss : 3 phases déclenchées par le ratio HP. Dash périodique, spawn de
//   minions en phase 2, roar AOE + flaques de lave en phase 3. Les callbacks
//   onSpawnMinion / onLavaTrail / onRoar sont câblés par GameScene.
export class Zombie {
  constructor(x, y, type) {
    const stats = CONFIG.zombie[type];
    this.type = type;
    this.x = x;
    this.y = y;
    this.r = stats.radius;
    this.speed = stats.speed;
    this.baseSpeed = stats.speed;     // référence pour les multiplicateurs (slow, dash)
    this.hp = stats.hp;
    this.maxHp = stats.hp;
    this.damage = stats.damage;
    this.score = stats.score;
    this.coins = stats.coins;
    this.color = stats.color;
    this.touchCooldown = 0;
    this.alive = true;
    // Animation : phase 0..2π qui avance avec le temps.
    this._walkPhase = Math.random() * Math.PI * 2;
    this._facing = 0;                 // angle calculé dans update vers la cible

    // Exploder
    this.aoeRadius = stats.aoeRadius || 0;
    this.aoeDamage = stats.aoeDamage || 0;
    this._shouldExplode = false;      // flag lu par GameScene pour AOE
    this._pulsePhase = Math.random() * Math.PI * 2;

    // Shielded
    this.shieldReduction = stats.shieldReduction || 0;
    this.shieldArc = stats.shieldArc || 0;

    // Boss (état des patterns, ignoré pour les autres types)
    this.phase = 1;
    this._dashCooldown = 0;           // décrément ; quand <=0 et phase>=1 → dash
    this._dashActive = 0;             // durée restante du dash en cours
    this._spawnCooldown = 0;          // phase>=2 : spawn minions
    this._roarCooldown = 0;           // phase 3 : AOE slow
    this._lavaTimer = 0;              // phase 3 : flaques sous le boss
    this._bossInitTime = 0;           // pour décaler les premiers triggers
    if (type === "boss") this._initBoss();
  }

  _initBoss() {
    const c = CONFIG.boss;
    this._dashCooldown = c.dash.cooldown * 0.5;     // premier dash plus rapide
    this._spawnCooldown = c.spawn.cooldown * 0.7;
    this._roarCooldown = c.roar.cooldown * 0.6;
    this._lavaTimer = c.lavaTrail.interval;
  }

  update(dt, target) {
    if (!this.alive) return;
    const dx = target.x - this.x;
    const dy = target.y - this.y;
    const d = Math.hypot(dx, dy) || 1;

    // Vitesse effective = baseSpeed (avec wave scaling déjà appliqué dans WaveManager)
    // multipliée par dash pour boss + ralenti slow (non implémenté ici, mais réservé).
    let effSpeed = this.speed;
    if (this.type === "boss") {
      const c = CONFIG.boss;
      // Dash actif → bonus de vitesse
      if (this._dashActive > 0) {
        effSpeed *= c.dash.speedMultiplier;
        this._dashActive -= dt;
      }
      // Décompte des cooldowns
      this._dashCooldown -= dt;
      this._spawnCooldown -= dt;
      this._roarCooldown -= dt;
      this._lavaTimer -= dt;

      // Détermine la phase via HP ratio
      const ratio = this.hp / this.maxHp;
      const newPhase = ratio < c.phaseThresholds.phase3 ? 3
                     : ratio < c.phaseThresholds.phase2 ? 2
                     : 1;
      if (newPhase !== this.phase) {
        this.phase = newPhase;
        this.onPhaseChange?.(newPhase);
      }

      // Trigger DASH (toutes phases)
      if (this._dashCooldown <= 0 && this._dashActive <= 0) {
        this._dashActive = c.dash.duration;
        this._dashCooldown = c.dash.cooldown;
        this.onDash?.();
      }
      // Trigger SPAWN MINIONS (phase 2+)
      if (this.phase >= 2 && this._spawnCooldown <= 0) {
        const count = this.phase === 3 ? 1 : 2;
        const interval = this.phase === 3 ? c.spawn.cooldownPhase3 : c.spawn.cooldown;
        this._spawnCooldown = interval;
        for (let i = 0; i < count; i++) {
          const a = Math.random() * Math.PI * 2;
          const sx = this.x + Math.cos(a) * (this.r + 20);
          const sy = this.y + Math.sin(a) * (this.r + 20);
          this.onSpawnMinion?.(sx, sy, c.spawn.minionType);
        }
      }
      // Trigger ROAR (phase 3 uniquement)
      if (this.phase === 3 && this._roarCooldown <= 0) {
        this._roarCooldown = c.roar.cooldown;
        this.onRoar?.(this.x, this.y, c.roar.radius, c.roar.slowDuration, c.roar.slowMultiplier);
      }
      // Trigger LAVA TRAIL (phase 3 uniquement, fréquent)
      if (this.phase === 3 && this._lavaTimer <= 0) {
        this._lavaTimer = c.lavaTrail.interval;
        this.onLavaTrail?.(this.x, this.y, c.lavaTrail.radius, c.lavaTrail.life, c.lavaTrail.damagePerSec);
      }
    }

    this.x += (dx / d) * effSpeed * dt;
    this.y += (dy / d) * effSpeed * dt;
    this._facing = Math.atan2(dy, dx);
    this.touchCooldown = Math.max(0, this.touchCooldown - dt);
    this._walkPhase = (this._walkPhase + dt * (this.speed / 14)) % (Math.PI * 2);
    this._pulsePhase = (this._pulsePhase + dt * 6) % (Math.PI * 2);

    // Exploder qui touche le joueur → explosion au contact (set flag, GameScene gère l'AOE)
    if (this.type === "exploder" && this.touchCooldown === 0) {
      const ddx = target.x - this.x;
      const ddy = target.y - this.y;
      const dist = Math.hypot(ddx, ddy);
      if (dist < this.r + (target.r || 14)) {
        this._shouldExplode = true;
        this.hp = 0;
        this.alive = false;
        // GameScene détectera _shouldExplode et appliquera l'AOE
      }
    }
  }

  /** Inflige des dégâts. fromX/fromY permettent au shield de vérifier l'angle. */
  damage_take(amount, fromX, fromY) {
    if (!this.alive || amount <= 0) return amount;

    // Shielded : vérifie si le tir vient du cône frontal (arc devant le facing)
    let applied = amount;
    if (this.type === "shielded" && fromX !== undefined && fromY !== undefined) {
      const angToShooter = Math.atan2(fromY - this.y, fromX - this.x);
      let delta = Math.abs(angToShooter - this._facing);
      // normaliser à [-π, π]
      if (delta > Math.PI) delta = Math.PI * 2 - delta;
      // Si la balle vient depuis le cône frontal → réduction
      if (delta < this.shieldArc * 0.5) {
        applied = amount * (1 - this.shieldReduction);
      }
    }

    this.hp -= applied;
    if (this.hp <= 0) {
      this.alive = false;
      // Exploder mort → AOE à sa position
      if (this.type === "exploder") this._shouldExplode = true;
    }
    return applied;
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

    // Glow par type
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
    } else if (this.type === "exploder") {
      // Pulse orange instable = signal "danger AOE"
      const pulse = 0.5 + Math.sin(this._pulsePhase) * 0.5;
      const glow = ctx.createRadialGradient(0, 0, this.r * 0.4,
                                            0, 0, this.r * (1.6 + pulse * 0.5));
      glow.addColorStop(0, `rgba(255,140,40,${0.5 + pulse * 0.35})`);
      glow.addColorStop(1, "rgba(255,80,20,0)");
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(0, 0, this.r * 1.8, 0, Math.PI * 2);
      ctx.fill();
    }

    const palette = this._getPalette();

    const armSwing = Math.sin(this._walkPhase) * 3;
    const legSwing = Math.sin(this._walkPhase) * 4;

    // Jambes
    ctx.strokeStyle = palette.dark;
    ctx.lineWidth = Math.max(2, this.r * 0.16);
    ctx.lineCap = "round";
    ctx.beginPath();
    ctx.moveTo(-this.r * 0.3, this.r * 0.7);
    ctx.lineTo(-this.r * 0.3 + legSwing * 0.4, this.r * 1.2);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(this.r * 0.3, this.r * 0.7);
    ctx.lineTo(this.r * 0.3 - legSwing * 0.4, this.r * 1.2);
    ctx.stroke();

    // Corps (largeur dépend du type)
    const bodyW = this.type === "fast"     ? this.r * 0.9
                : this.type === "exploder" ? this.r * 1.0
                : this.type === "heavy"    ? this.r * 1.5
                : this.type === "shielded" ? this.r * 1.3
                : this.type === "miniBoss" ? this.r * 1.2
                : this.type === "boss"     ? this.r * 1.3
                : this.r * 1.1;
    const bodyH = this.r * 1.3;
    ctx.fillStyle = palette.body;
    ctx.beginPath();
    if (ctx.roundRect) ctx.roundRect(-bodyW / 2, -bodyH * 0.3, bodyW, bodyH, 4);
    else ctx.rect(-bodyW / 2, -bodyH * 0.3, bodyW, bodyH);
    ctx.fill();
    ctx.strokeStyle = palette.dark;
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // Décoration : rayures heavy, bande boss, mèche exploder, motif shielded
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
    if (this.type === "exploder") {
      // Mèche allumée en haut de la tête
      ctx.strokeStyle = "#3a1a08";
      ctx.lineWidth = 1.6;
      ctx.beginPath();
      ctx.moveTo(0, -bodyH * 0.5 - this.r * 0.55);
      ctx.quadraticCurveTo(2, -bodyH * 0.5 - this.r * 0.85, 4, -bodyH * 0.5 - this.r * 1.0);
      ctx.stroke();
      // Étincelle au bout de la mèche
      const sparkPulse = 0.6 + Math.sin(this._pulsePhase * 1.5) * 0.4;
      ctx.fillStyle = `rgba(255,230,120,${sparkPulse})`;
      ctx.beginPath();
      ctx.arc(4, -bodyH * 0.5 - this.r * 1.0, 2.5 + sparkPulse * 1.5, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = "#ff6b35";
      ctx.beginPath();
      ctx.arc(4, -bodyH * 0.5 - this.r * 1.0, 1.4, 0, Math.PI * 2);
      ctx.fill();
    }

    // Tête
    ctx.fillStyle = palette.body;
    ctx.beginPath();
    ctx.arc(0, -bodyH * 0.5, this.r * 0.55, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = palette.dark;
    ctx.lineWidth = 1.4;
    ctx.stroke();

    // Yeux rouges
    const eyeR = Math.max(1.2, this.r * 0.13);
    const eyeOff = this.r * 0.20;
    ctx.fillStyle = "#ff3030";
    ctx.beginPath();
    ctx.arc(-eyeOff, -bodyH * 0.55, eyeR, 0, Math.PI * 2);
    ctx.arc(eyeOff, -bodyH * 0.55, eyeR, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "rgba(255,48,48,0.40)";
    ctx.beginPath();
    ctx.arc(-eyeOff, -bodyH * 0.55, eyeR * 2, 0, Math.PI * 2);
    ctx.arc(eyeOff, -bodyH * 0.55, eyeR * 2, 0, Math.PI * 2);
    ctx.fill();

    // Bouche mini-boss / boss
    if (this.type === "miniBoss" || this.type === "boss") {
      ctx.strokeStyle = "#1a0a0a";
      ctx.lineWidth = 1.6;
      ctx.beginPath();
      ctx.moveTo(-this.r * 0.18, -bodyH * 0.42);
      ctx.lineTo(this.r * 0.18, -bodyH * 0.42);
      ctx.stroke();
    }

    // Bras
    ctx.strokeStyle = palette.body;
    ctx.lineWidth = Math.max(2.5, this.r * 0.18);
    ctx.lineCap = "round";
    ctx.beginPath();
    ctx.moveTo(-bodyW * 0.4, 0);
    ctx.lineTo(-bodyW * 0.4 + this.r * 0.7, this.r * 0.2 + armSwing * 0.3);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(bodyW * 0.4, 0);
    ctx.lineTo(bodyW * 0.4 + this.r * 0.7, this.r * 0.2 - armSwing * 0.3);
    ctx.stroke();
    ctx.fillStyle = palette.dark;
    ctx.beginPath();
    ctx.arc(-bodyW * 0.4 + this.r * 0.7, this.r * 0.2 + armSwing * 0.3, this.r * 0.10, 0, Math.PI * 2);
    ctx.arc(bodyW * 0.4 + this.r * 0.7, this.r * 0.2 - armSwing * 0.3, this.r * 0.10, 0, Math.PI * 2);
    ctx.fill();

    // BOUCLIER (shielded) : dessine l'arc face au facing
    if (this.type === "shielded") {
      ctx.save();
      ctx.rotate(this._facing);
      // Le bouclier est devant (vers la cible) à droite du référentiel rotaté
      const shieldR = this.r * 1.35;
      const arc = this.shieldArc;
      // Fond du bouclier
      ctx.fillStyle = "rgba(180,200,220,0.85)";
      ctx.strokeStyle = "#1a3a55";
      ctx.lineWidth = 2.4;
      ctx.beginPath();
      ctx.arc(0, 0, shieldR, -arc * 0.5, arc * 0.5);
      ctx.lineTo(0, 0);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();
      // Croix bleu sur le bouclier
      ctx.strokeStyle = "#0099b8";
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(this.r * 0.6, -this.r * 0.5);
      ctx.lineTo(this.r * 0.6, this.r * 0.5);
      ctx.moveTo(this.r * 0.35, 0);
      ctx.lineTo(this.r * 0.85, 0);
      ctx.stroke();
      ctx.restore();
    }

    // Couronne d'épines (mini-boss)
    if (this.type === "miniBoss") {
      ctx.fillStyle = "#a82020";
      ctx.strokeStyle = "#5a0a0a";
      ctx.lineWidth = 1;
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

    // Aura boss + indicateur de dash
    if (this.type === "boss") {
      const pulse = 0.5 + Math.sin(time * 4) * 0.5;
      // Aura plus intense en phase 3
      const phaseGlow = this.phase === 3 ? 0.7 : this.phase === 2 ? 0.55 : 0.4;
      ctx.strokeStyle = `rgba(255,107,53,${phaseGlow + pulse * 0.25})`;
      ctx.lineWidth = 2 + (this.phase === 3 ? 1.5 : 0);
      ctx.beginPath();
      ctx.arc(0, 0, this.r + 4 + pulse * 3, 0, Math.PI * 2);
      ctx.stroke();
      // Si dash actif, traînée orange marquée
      if (this._dashActive > 0) {
        ctx.strokeStyle = "rgba(255,200,40,0.85)";
        ctx.lineWidth = 4;
        ctx.beginPath();
        ctx.arc(0, 0, this.r + 8, 0, Math.PI * 2);
        ctx.stroke();
      }
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
      const ratio = this.hp / this.maxHp;
      const hpColor = ratio > 0.5 ? "#6ed87a" : ratio > 0.25 ? "#f4b942" : "#ff3030";
      ctx.fillStyle = hpColor;
      ctx.fillRect(x, y, w * ratio, h);
    }
  }

  // Palette de couleurs par type (body principal + dark contour/détails).
  _getPalette() {
    switch (this.type) {
      case "fast":
        return { body: "#a8db7a", dark: "#3a6a28" };
      case "heavy":
        return { body: "#2a5a2a", dark: "#0e2a14" };
      case "exploder":
        return { body: "#ff7a2a", dark: "#7a2a08" };
      case "shielded":
        return { body: "#5a7a9a", dark: "#1a3a55" };
      case "miniBoss":
        return { body: "#a82828", dark: "#4a0a0a" };
      case "boss":
        return { body: "#d92020", dark: "#6a0a0a" };
      case "normal":
      default:
        return { body: "#5a8a4a", dark: "#1a3a14" };
    }
  }
}
