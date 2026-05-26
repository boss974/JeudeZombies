const NOTE = {
  c2: 65.41, d2: 73.42, e2: 82.41, f2: 87.31, g2: 98.00, a2: 110.00, b2: 123.47,
  c3: 130.81, d3: 146.83, e3: 164.81, f3: 174.61, g3: 196.00, a3: 220.00, b3: 246.94,
  c4: 261.63, d4: 293.66, e4: 329.63, f4: 349.23, g4: 392.00, a4: 440.00
};

const SAMPLE_BASE = "assets/audio/kenney/";
const SAMPLES = {
  click: ["ui_click.ogg"],
  select: ["ui_select.ogg"],
  error: ["ui_error.ogg"],
  pistol: ["shot_pistol_1.ogg", "shot_pistol_2.ogg"],
  shotgun: ["shot_heavy_1.ogg", "shot_heavy_2.ogg"],
  volcano: ["shot_volcano_1.ogg", "shot_volcano_2.ogg"],
  hit: ["hit_1.ogg", "hit_2.ogg"],
  kill: ["kill_1.ogg"],
  boss: ["boss_1.ogg"],
  combo: ["combo_1.ogg", "combo_2.ogg"],
  weapon: ["weapon_change.ogg"],
  turret: ["defense_turret.ogg"],
  barricade: ["defense_barricade.ogg"]
};

export class AudioManager {
  constructor() {
    this.ctx = null;
    this.master = null;
    this.music = null;
    this.sfx = null;
    this.bed = null;
    this.delay = null;
    this.bedNodes = [];
    this.sampleBuffers = new Map();
    this.sampleLoading = null;
    this.musicElement = null;
    this.enabled = localStorage.getItem("zombies.audioEnabled") !== "0";
    const musicVol = parseInt(localStorage.getItem("zombies.audioMusic") || "70", 10);
    const sfxVol = parseInt(localStorage.getItem("zombies.audioSfx") || "85", 10);
    this.musicVolume = Math.max(0, Math.min(1, (Number.isFinite(musicVol) ? musicVol : 70) / 100));
    this.sfxVolume = Math.max(0, Math.min(1, (Number.isFinite(sfxVol) ? sfxVol : 85) / 100));
    this.started = false;
    this.mode = "menu";
    this.weapon = "pistol";
    this.nextBeat = 0;
    this.beat = 0;
    this._timer = null;
  }

  async start() {
    if (!this.enabled) return;
    this._ensure();
    if (this.ctx.state === "suspended") await this.ctx.resume();
    this._startMusicElement();
    this._loadSamples();
    if (this.started) return;
    this.started = true;
    this._timer = setInterval(() => this._tick(), 80);
  }

  setEnabled(enabled) {
    this.enabled = !!enabled;
    localStorage.setItem("zombies.audioEnabled", this.enabled ? "1" : "0");
    if (!this.master) return;
    this.master.gain.setTargetAtTime(this.enabled ? 0.85 : 0.0001, this.ctx.currentTime, 0.03);
    if (this.musicElement) this.musicElement.volume = this.enabled ? this._musicVolumeForMode() : 0;
    if (this.enabled) this.start();
  }

  setMusicVolume(v) {
    this.musicVolume = Math.max(0, Math.min(1, Number(v) || 0));
    if (this.music && this.ctx) {
      const base = this.mode === "boss" ? 0.38 : this.mode === "combat" ? 0.34 : this.mode === "ambient" ? 0.28 : 0.22;
      this.music.gain.setTargetAtTime(base * this.musicVolume, this.ctx.currentTime, 0.05);
    }
    if (this.musicElement) this.musicElement.volume = this.enabled ? this._musicVolumeForMode() : 0;
  }

  setSfxVolume(v) {
    this.sfxVolume = Math.max(0, Math.min(1, Number(v) || 0));
    if (this.sfx && this.ctx) {
      this.sfx.gain.setTargetAtTime(0.72 * this.sfxVolume, this.ctx.currentTime, 0.05);
    }
  }

  getMusicVolume() { return this.musicVolume; }
  getSfxVolume() { return this.sfxVolume; }

  setMode(mode) {
    this.mode = mode;
    if (this.music && this.ctx) {
      const target = mode === "boss" ? 0.38 : mode === "combat" ? 0.34 : mode === "ambient" ? 0.28 : 0.22;
      this.music.gain.setTargetAtTime(target * this.musicVolume, this.ctx.currentTime, 0.08);
      this._updateBed();
      if (this.musicElement) {
        this.musicElement.volume = this.enabled ? this._musicVolumeForMode() : 0;
        this.musicElement.playbackRate = mode === "boss" ? 0.86 : mode === "combat" ? 1.04 : mode === "menu" ? 0.94 : 1;
      }
    }
  }

  cycleWeapon() {
    const order = ["pistol", "shotgun", "volcano"];
    this.weapon = order[(order.indexOf(this.weapon) + 1) % order.length];
    this.weaponChange(this.weapon);
    return this.weapon;
  }

  click() { if (!this._playSample("click", 0.45)) this._blip(520, 0.045, 0.05, "triangle"); }
  startGame() { this._rise([NOTE.c3, NOTE.g3, NOTE.c4], 0.09); }
  waveStart() { this._rise([NOTE.d2, NOTE.a2, NOTE.d3, NOTE.a3], 0.08); }
  bossWarning(kind = "boss") {
    this._ensure();
    const t = this.ctx.currentTime;
    if (kind === "miniBoss") {
      if (this._playSample("boss", 0.55, 1.18)) return;
      this._fall([NOTE.a2, NOTE.f2, NOTE.d2], 0.12);
      this._noise(t + 0.05, 0.16, 0.08, 520, "bandpass");
      return;
    }
    this._playSample("boss", 0.85, 0.78);
    this._fall([NOTE.c3, NOTE.g2, NOTE.d2, NOTE.c2], 0.14);
    this._tone(44, t, 0.75, 0.16, "sawtooth", 0.04, 31);
    this._noise(t + 0.04, 0.45, 0.13, 260, "lowpass");
  }
  waveClear() { this._rise([NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4], 0.11); }
  gameOver() { this._fall([NOTE.c3, NOTE.g2, NOTE.e2, NOTE.c2], 0.16); }
  victory() { this._rise([NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4, NOTE.e4], 0.12); }
  combo(value) {
    if (value <= 1) return;
    if (this._playSample("combo", 0.42 + value * 0.08, 0.88 + value * 0.05)) return;
    const notes = [NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4, NOTE.e4];
    this._rise(notes.slice(0, Math.min(value, notes.length)), 0.035);
  }

  shoot() {
    this._ensure();
    const t = this.ctx.currentTime;
    const variance = 0.92 + Math.random() * 0.16;
    if (this._playSample(this.weapon, this.weapon === "shotgun" ? 0.9 : 0.72, variance)) return;
    if (this.weapon === "shotgun") {
      this._noise(t, 0.03, 0.26, 1900 + Math.random() * 700, "highpass");
      this._noise(t + 0.006, 0.12, 0.2, 520, "bandpass");
      this._tone(72 * variance, t, 0.11, 0.17, "square", 0.001, 38 * variance);
      this._tone(620 * variance, t + 0.02, 0.08, 0.05, "sawtooth", 0.004, 260);
      return;
    }
    if (this.weapon === "volcano") {
      this._noise(t, 0.028, 0.2, 3200, "highpass");
      this._tone(155 * variance, t, 0.1, 0.13, "sawtooth", 0.002, 78 * variance);
      this._tone(930 * variance, t + 0.018, 0.11, 0.06, "triangle", 0.005, 420);
      this._noise(t + 0.04, 0.16, 0.09, 300, "lowpass");
      return;
    }

    // Claquement sec du départ de coup.
    this._noise(t, 0.018, 0.18, 2600 + Math.random() * 900, "highpass");
    // Souffle de poudre, plus large et plus grave.
    this._noise(t + 0.006, 0.075, 0.13, 820 + Math.random() * 180, "bandpass");
    // Kick grave du recul.
    this._tone(92 * variance, t, 0.07, 0.12, "square", 0.001, 48 * variance);
    // Résonance métallique courte du canon.
    this._tone(1180 * variance, t + 0.012, 0.035, 0.035, "triangle", 0.002, 720 * variance);
    // Petit souffle de queue pour donner une sensation d'espace.
    this._noise(t + 0.035, 0.055, 0.035, 420, "lowpass");
  }

  hit() {
    this._ensure();
    if (this._playSample("hit", 0.6, 0.95 + Math.random() * 0.1)) return;
    const t = this.ctx.currentTime;
    this._noise(t, 0.06, 0.08, 650, "bandpass");
    this._tone(82, t, 0.08, 0.08, "sawtooth", 0.004);
  }

  zombieDown(type = "normal") {
    this._ensure();
    if (this._playSample("kill", type === "boss" ? 0.85 : 0.55, type === "fast" ? 1.2 : 1)) return;
    const t = this.ctx.currentTime;
    const base = type === "boss" ? 58 : type === "miniBoss" ? 72 : 95;
    this._tone(base, t, 0.1, 0.07, "sawtooth", 0.003, base * 0.55);
    this._noise(t, 0.09, 0.04, 420, "lowpass");
  }

  playerHurt() {
    this._ensure();
    const t = this.ctx.currentTime;
    this._tone(110, t, 0.12, 0.09, "triangle", 0.004, 68);
  }

  noCoins() {
    if (!this._playSample("error", 0.55)) this._fall([NOTE.g3, NOTE.d3], 0.055);
  }

  placeDefense(type = "turret") {
    if (type === "barricade") {
      if (this._playSample("barricade", 0.65)) return;
      this._ensure();
      const t = this.ctx.currentTime;
      this._tone(92, t, 0.08, 0.12, "triangle", 0.003, 55);
      this._noise(t + 0.01, 0.08, 0.08, 380, "lowpass");
      return;
    }
    if (!this._playSample("turret", 0.6)) this._rise([NOTE.g2, NOTE.d3, NOTE.g3], 0.045);
  }

  selectDefense(type = "turret") {
    if (this._playSample("select", 0.48, type === "barricade" ? 0.82 : 1.08)) return;
    if (type === "barricade") this._fall([NOTE.e3, NOTE.c3], 0.045);
    else this._rise([NOTE.c3, NOTE.g3], 0.04);
  }

  // Explosion d'un exploder : boom grave + souffle large + ping métallique
  exploderBoom() {
    this._ensure();
    const t = this.ctx.currentTime;
    // Boom grave
    this._tone(58, t, 0.32, 0.32, "sawtooth", 0.002, 28);
    // Souffle moyen
    this._noise(t, 0.18, 0.16, 420, "bandpass");
    // Crackle haute fréquence
    this._noise(t + 0.05, 0.22, 0.08, 2400, "highpass");
    // Ping métallique du shrapnel
    this._tone(820, t + 0.04, 0.08, 0.05, "triangle", 0.003, 320);
  }

  // Tir qui ricoche sur un bouclier : ping métallique aigu
  shieldBlock() {
    this._ensure();
    const t = this.ctx.currentTime;
    this._tone(1280, t, 0.08, 0.12, "triangle", 0.002, 880);
    this._noise(t, 0.04, 0.06, 1800, "bandpass");
  }

  // Cri du boss en phase 3 : grondement long descendant
  bossRoar() {
    if (this._playSample("boss", 1.0, 0.62)) return;
    this._ensure();
    const t = this.ctx.currentTime;
    this._tone(72, t, 0.6, 0.28, "sawtooth", 0.05, 32);
    this._noise(t + 0.06, 0.5, 0.18, 260, "lowpass");
    this._tone(220, t + 0.1, 0.4, 0.1, "square", 0.04, 90);
  }

  // Dash du boss : whoosh court de déplacement rapide
  bossDash() {
    this._ensure();
    const t = this.ctx.currentTime;
    this._noise(t, 0.12, 0.1, 380, "bandpass");
    this._tone(140, t + 0.02, 0.1, 0.08, "sawtooth", 0.005, 60);
  }

  // Popup score : petit tintement court qui accompagne le +XX
  scorePopup() {
    this._ensure();
    const t = this.ctx.currentTime;
    this._tone(NOTE.a4, t, 0.08, 0.04, "triangle", 0.002, NOTE.c4);
  }

  weaponChange(weapon = this.weapon) {
    this._ensure();
    if (this._playSample("weapon", 0.62, weapon === "volcano" ? 0.72 : weapon === "shotgun" ? 0.88 : 1.1)) return;
    const t = this.ctx.currentTime;
    if (weapon === "shotgun") {
      this._noise(t, 0.05, 0.08, 900, "bandpass");
      this._tone(180, t + 0.03, 0.05, 0.07, "square", 0.002, 120);
    } else if (weapon === "volcano") {
      this._tone(120, t, 0.08, 0.08, "sawtooth", 0.004, 220);
      this._noise(t + 0.025, 0.11, 0.06, 460, "lowpass");
    } else {
      this._rise([NOTE.e3, NOTE.g3], 0.04);
    }
  }

  _ensure() {
    if (this.ctx) return;
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    this.ctx = new AudioContext();
    this.master = this.ctx.createGain();
    this.master.gain.value = this.enabled ? 0.95 : 0.0001;
    this.music = this.ctx.createGain();
    this.music.gain.value = 0.22 * this.musicVolume;
    this.sfx = this.ctx.createGain();
    this.sfx.gain.value = 0.72 * this.sfxVolume;
    this.bed = this.ctx.createGain();
    this.bed.gain.value = 0.12;
    this.delay = this.ctx.createDelay(0.35);
    this.delay.delayTime.value = 0.12;
    const delayGain = this.ctx.createGain();
    delayGain.gain.value = 0.18;
    const compressor = this.ctx.createDynamicsCompressor();
    compressor.threshold.value = -18;
    compressor.knee.value = 18;
    compressor.ratio.value = 5;
    compressor.attack.value = 0.004;
    compressor.release.value = 0.18;

    this.music.connect(this.delay);
    this.delay.connect(delayGain);
    delayGain.connect(this.music);
    this.music.connect(compressor);
    this.bed.connect(compressor);
    this.sfx.connect(compressor);
    compressor.connect(this.master);
    this.master.connect(this.ctx.destination);
    this._startBed();
    this.nextBeat = this.ctx.currentTime + 0.08;
  }

  _startMusicElement() {
    if (this.musicElement) {
      this.musicElement.volume = this.enabled ? this._musicVolumeForMode() : 0;
      this.musicElement.play().catch(() => {});
      return;
    }
    this.musicElement = new Audio(`${SAMPLE_BASE}music_digital_preview.ogg`);
    this.musicElement.loop = true;
    this.musicElement.preload = "auto";
    this.musicElement.volume = this.enabled ? this._musicVolumeForMode() : 0;
    this.musicElement.playbackRate = this.mode === "boss" ? 0.86 : this.mode === "combat" ? 1.04 : 1;
    this.musicElement.play().catch(() => {});
  }

  _musicVolumeForMode() {
    let base;
    if (this.mode === "boss") base = 0.34;
    else if (this.mode === "combat") base = 0.28;
    else if (this.mode === "ambient") base = 0.22;
    else base = 0.16;
    return base * this.musicVolume;
  }

  async _loadSamples() {
    if (this.sampleLoading) return this.sampleLoading;
    this.sampleLoading = (async () => {
      const files = [...new Set(Object.values(SAMPLES).flat())];
      await Promise.all(files.map(async (file) => {
        try {
          const res = await fetch(`${SAMPLE_BASE}${file}`);
          if (!res.ok) return;
          const arr = await res.arrayBuffer();
          const buffer = await this.ctx.decodeAudioData(arr);
          this.sampleBuffers.set(file, buffer);
        } catch (_) {}
      }));
    })();
    return this.sampleLoading;
  }

  _playSample(group, gainValue = 0.7, rate = 1) {
    if (!this.enabled || !this.ctx) return false;
    const list = SAMPLES[group];
    if (!list || !list.length) return false;
    const ready = list.filter((file) => this.sampleBuffers.has(file));
    if (!ready.length) {
      this._loadSamples();
      return false;
    }
    const file = ready[Math.floor(Math.random() * ready.length)];
    const src = this.ctx.createBufferSource();
    const gain = this.ctx.createGain();
    src.buffer = this.sampleBuffers.get(file);
    src.playbackRate.value = Math.max(0.45, Math.min(1.7, rate));
    gain.gain.value = gainValue;
    src.connect(gain);
    gain.connect(this.sfx);
    src.start();
    return true;
  }

  _startBed() {
    const make = (freq, type, gainValue) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = type;
      osc.frequency.value = freq;
      gain.gain.value = gainValue;
      osc.connect(gain);
      gain.connect(this.bed);
      osc.start();
      this.bedNodes.push({ osc, gain, base: freq });
    };
    make(49, "sine", 0.14);
    make(98, "triangle", 0.045);
    make(196, "sine", 0.015);
    this._updateBed();
  }

  _updateBed() {
    if (!this.bed || !this.ctx) return;
    const gain = this.mode === "boss" ? 0.08 : this.mode === "combat" ? 0.045 : this.mode === "ambient" ? 0.025 : 0.018;
    this.bed.gain.setTargetAtTime(gain, this.ctx.currentTime, 0.25);
    const root = this.mode === "boss" ? 41.2 : this.mode === "combat" ? 55 : this.mode === "menu" ? 65.4 : 49;
    this.bedNodes.forEach((node, index) => {
      node.osc.frequency.setTargetAtTime(root * (index + 1), this.ctx.currentTime, 0.4);
    });
  }

  _tick() {
    if (!this.enabled || !this.ctx || this.ctx.state !== "running") return;
    if (this.musicElement) return;
    const now = this.ctx.currentTime;
    while (this.nextBeat < now + 0.28) {
      this._musicBeat(this.nextBeat, this.beat++);
      this.nextBeat += this.mode === "boss" ? 0.24 : this.mode === "combat" ? 0.31 : this.mode === "menu" ? 0.52 : 0.42;
    }
  }

  _musicBeat(t, beat) {
    const boss = this.mode === "boss";
    const combat = this.mode === "combat" || boss;
    const menu = this.mode === "menu";
    const scale = boss
      ? [NOTE.c2, NOTE.d2, NOTE.f2, NOTE.g2]
      : combat
      ? [NOTE.c2, NOTE.d2, NOTE.f2, NOTE.g2, NOTE.a2]
      : menu
      ? [NOTE.c2, NOTE.g2, NOTE.c3]
      : [NOTE.c2, NOTE.e2, NOTE.g2, NOTE.a2, NOTE.c3];
    const bass = scale[Math.floor(beat / 2) % scale.length];
    const lead = boss
      ? [NOTE.c3, NOTE.d3, NOTE.f3, NOTE.d3, NOTE.g2, NOTE.f2, NOTE.d2, NOTE.c2][beat % 8]
      : combat
      ? [NOTE.c3, NOTE.d3, NOTE.f3, NOTE.g3, NOTE.a3, NOTE.g3, NOTE.f3, NOTE.d3][beat % 8]
      : menu
      ? [NOTE.g2, NOTE.c3, NOTE.g2, NOTE.d3, NOTE.c3, NOTE.g2, NOTE.e3, NOTE.d3][beat % 8]
      : [NOTE.e3, NOTE.g3, NOTE.a3, NOTE.g3, NOTE.c4, NOTE.a3, NOTE.g3, NOTE.e3][beat % 8];

    if (beat % 2 === 0) this._tone(bass, t, boss ? 0.32 : combat ? 0.22 : 0.28, boss ? 0.08 : combat ? 0.055 : 0.04, boss ? "sawtooth" : "sine", 0.02, null, this.music);
    if (beat % (combat ? 1 : 2) === 0) this._tone(lead, t + 0.03, 0.12, boss ? 0.05 : combat ? 0.035 : 0.026, boss ? "square" : "triangle", 0.01, null, this.music);
    if (beat % 4 === 0) this._drum(t, combat);
    if (!combat && beat % 8 === 4) this._marimba(t + 0.08);
    if (combat && beat % 3 === 0) this._noise(t + 0.03, 0.035, 0.025, 1800, "highpass", this.music);
    if (boss && beat % 2 === 1) this._noise(t + 0.02, 0.06, 0.04, 320, "lowpass", this.music);
  }

  _drum(t, combat) {
    this._tone(combat ? 72 : 86, t, 0.08, combat ? 0.1 : 0.065, "sine", 0.003, 42, this.music);
    this._noise(t + 0.015, 0.035, combat ? 0.045 : 0.025, combat ? 1200 : 900, "lowpass", this.music);
  }

  _marimba(t) {
    this._tone(NOTE.c4, t, 0.09, 0.026, "triangle", 0.004, null, this.music);
    this._tone(NOTE.g3, t + 0.08, 0.09, 0.026, "triangle", 0.004, null, this.music);
  }

  _rise(notes, step) {
    this._ensure();
    notes.forEach((n, i) => this._tone(n, this.ctx.currentTime + i * step, step * 0.9, 0.065, "triangle", 0.006));
  }

  _fall(notes, step) {
    this._ensure();
    notes.forEach((n, i) => this._tone(n, this.ctx.currentTime + i * step, step * 1.2, 0.07, "sawtooth", 0.008));
  }

  _blip(freq, dur, gain, type) {
    this._ensure();
    this._tone(freq, this.ctx.currentTime, dur, gain, type, 0.003);
  }

  _tone(freq, t, dur, gainValue, type = "sine", attack = 0.004, slideTo = null, output = this.sfx) {
    if (!this.enabled || !this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(freq, t);
    if (slideTo) osc.frequency.exponentialRampToValueAtTime(Math.max(20, slideTo), t + dur);
    gain.gain.setValueAtTime(0.0001, t);
    gain.gain.exponentialRampToValueAtTime(Math.max(0.0002, gainValue), t + attack);
    gain.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    osc.connect(gain);
    gain.connect(output);
    osc.start(t);
    osc.stop(t + dur + 0.02);
  }

  _noise(t, dur, gainValue, freq, filterType, output = this.sfx) {
    if (!this.enabled || !this.ctx) return;
    const len = Math.max(1, Math.floor(this.ctx.sampleRate * dur));
    const buffer = this.ctx.createBuffer(1, len, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < len; i++) data[i] = Math.random() * 2 - 1;
    const src = this.ctx.createBufferSource();
    const filter = this.ctx.createBiquadFilter();
    const gain = this.ctx.createGain();
    filter.type = filterType;
    filter.frequency.value = freq;
    gain.gain.setValueAtTime(gainValue, t);
    gain.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    src.buffer = buffer;
    src.connect(filter);
    filter.connect(gain);
    gain.connect(output);
    src.start(t);
  }
}
