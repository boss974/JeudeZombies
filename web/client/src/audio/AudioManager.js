const NOTE = {
  c2: 65.41, d2: 73.42, e2: 82.41, f2: 87.31, g2: 98.00, a2: 110.00, b2: 123.47,
  c3: 130.81, d3: 146.83, e3: 164.81, f3: 174.61, g3: 196.00, a3: 220.00, b3: 246.94,
  c4: 261.63, d4: 293.66, e4: 329.63, f4: 349.23, g4: 392.00, a4: 440.00
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
    this.enabled = localStorage.getItem("zombies.audioEnabled") !== "0";
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
    if (this.started) return;
    this.started = true;
    this._timer = setInterval(() => this._tick(), 80);
  }

  setEnabled(enabled) {
    this.enabled = !!enabled;
    localStorage.setItem("zombies.audioEnabled", this.enabled ? "1" : "0");
    if (!this.master) return;
    this.master.gain.setTargetAtTime(this.enabled ? 0.85 : 0.0001, this.ctx.currentTime, 0.03);
    if (this.enabled) this.start();
  }

  setMode(mode) {
    this.mode = mode;
    if (this.music && this.ctx) {
      const target = mode === "boss" ? 0.38 : mode === "combat" ? 0.34 : mode === "ambient" ? 0.28 : 0.22;
      this.music.gain.setTargetAtTime(target, this.ctx.currentTime, 0.08);
      this._updateBed();
    }
  }

  cycleWeapon() {
    const order = ["pistol", "shotgun", "volcano"];
    this.weapon = order[(order.indexOf(this.weapon) + 1) % order.length];
    this.weaponChange(this.weapon);
    return this.weapon;
  }

  click() { this._blip(520, 0.045, 0.05, "triangle"); }
  startGame() { this._rise([NOTE.c3, NOTE.g3, NOTE.c4], 0.09); }
  waveStart() { this._rise([NOTE.d2, NOTE.a2, NOTE.d3, NOTE.a3], 0.08); }
  bossWarning(kind = "boss") {
    this._ensure();
    const t = this.ctx.currentTime;
    if (kind === "miniBoss") {
      this._fall([NOTE.a2, NOTE.f2, NOTE.d2], 0.12);
      this._noise(t + 0.05, 0.16, 0.08, 520, "bandpass");
      return;
    }
    this._fall([NOTE.c3, NOTE.g2, NOTE.d2, NOTE.c2], 0.14);
    this._tone(44, t, 0.75, 0.16, "sawtooth", 0.04, 31);
    this._noise(t + 0.04, 0.45, 0.13, 260, "lowpass");
  }
  waveClear() { this._rise([NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4], 0.11); }
  gameOver() { this._fall([NOTE.c3, NOTE.g2, NOTE.e2, NOTE.c2], 0.16); }
  victory() { this._rise([NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4, NOTE.e4], 0.12); }
  combo(value) {
    if (value <= 1) return;
    const notes = [NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4, NOTE.e4];
    this._rise(notes.slice(0, Math.min(value, notes.length)), 0.035);
  }

  shoot() {
    this._ensure();
    const t = this.ctx.currentTime;
    const variance = 0.92 + Math.random() * 0.16;
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
    const t = this.ctx.currentTime;
    this._noise(t, 0.06, 0.08, 650, "bandpass");
    this._tone(82, t, 0.08, 0.08, "sawtooth", 0.004);
  }

  zombieDown(type = "normal") {
    this._ensure();
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
    this._fall([NOTE.g3, NOTE.d3], 0.055);
  }

  placeDefense(type = "turret") {
    if (type === "barricade") {
      this._ensure();
      const t = this.ctx.currentTime;
      this._tone(92, t, 0.08, 0.12, "triangle", 0.003, 55);
      this._noise(t + 0.01, 0.08, 0.08, 380, "lowpass");
      return;
    }
    this._rise([NOTE.g2, NOTE.d3, NOTE.g3], 0.045);
  }

  selectDefense(type = "turret") {
    if (type === "barricade") this._fall([NOTE.e3, NOTE.c3], 0.045);
    else this._rise([NOTE.c3, NOTE.g3], 0.04);
  }

  weaponChange(weapon = this.weapon) {
    this._ensure();
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
    this.music.gain.value = 0.3;
    this.sfx = this.ctx.createGain();
    this.sfx.gain.value = 0.72;
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
    make(49, "sine", 0.35);
    make(98, "triangle", 0.12);
    make(196, "sine", 0.035);
    this._updateBed();
  }

  _updateBed() {
    if (!this.bed || !this.ctx) return;
    const gain = this.mode === "boss" ? 0.22 : this.mode === "combat" ? 0.16 : this.mode === "ambient" ? 0.12 : 0.08;
    this.bed.gain.setTargetAtTime(gain, this.ctx.currentTime, 0.25);
    const root = this.mode === "boss" ? 41.2 : this.mode === "combat" ? 55 : this.mode === "menu" ? 65.4 : 49;
    this.bedNodes.forEach((node, index) => {
      node.osc.frequency.setTargetAtTime(root * (index + 1), this.ctx.currentTime, 0.4);
    });
  }

  _tick() {
    if (!this.enabled || !this.ctx || this.ctx.state !== "running") return;
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
