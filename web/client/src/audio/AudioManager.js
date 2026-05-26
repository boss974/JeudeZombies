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
    this.enabled = localStorage.getItem("zombies.audioEnabled") !== "0";
    this.started = false;
    this.mode = "menu";
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
  }

  click() { this._blip(520, 0.045, 0.05, "triangle"); }
  startGame() { this._rise([NOTE.c3, NOTE.g3, NOTE.c4], 0.09); }
  waveStart() { this._rise([NOTE.d2, NOTE.a2, NOTE.d3, NOTE.a3], 0.08); }
  waveClear() { this._rise([NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4], 0.11); }
  gameOver() { this._fall([NOTE.c3, NOTE.g2, NOTE.e2, NOTE.c2], 0.16); }
  victory() { this._rise([NOTE.c3, NOTE.e3, NOTE.g3, NOTE.c4, NOTE.e4], 0.12); }

  shoot() {
    this._ensure();
    const t = this.ctx.currentTime;
    this._noise(t, 0.045, 0.06, 900, "highpass");
    this._tone(145, t, 0.035, 0.05, "square", 0.002);
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

  placeDefense() {
    this._rise([NOTE.g2, NOTE.d3, NOTE.g3], 0.045);
  }

  _ensure() {
    if (this.ctx) return;
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    this.ctx = new AudioContext();
    this.master = this.ctx.createGain();
    this.master.gain.value = this.enabled ? 0.85 : 0.0001;
    this.music = this.ctx.createGain();
    this.music.gain.value = 0.22;
    this.sfx = this.ctx.createGain();
    this.sfx.gain.value = 0.55;
    this.music.connect(this.master);
    this.sfx.connect(this.master);
    this.master.connect(this.ctx.destination);
    this.nextBeat = this.ctx.currentTime + 0.08;
  }

  _tick() {
    if (!this.enabled || !this.ctx || this.ctx.state !== "running") return;
    const now = this.ctx.currentTime;
    while (this.nextBeat < now + 0.28) {
      this._musicBeat(this.nextBeat, this.beat++);
      this.nextBeat += this.mode === "combat" ? 0.31 : 0.42;
    }
  }

  _musicBeat(t, beat) {
    const combat = this.mode === "combat";
    const scale = combat
      ? [NOTE.c2, NOTE.d2, NOTE.f2, NOTE.g2, NOTE.a2]
      : [NOTE.c2, NOTE.e2, NOTE.g2, NOTE.a2, NOTE.c3];
    const bass = scale[Math.floor(beat / 2) % scale.length];
    const lead = combat
      ? [NOTE.c3, NOTE.d3, NOTE.f3, NOTE.g3, NOTE.a3, NOTE.g3, NOTE.f3, NOTE.d3][beat % 8]
      : [NOTE.e3, NOTE.g3, NOTE.a3, NOTE.g3, NOTE.c4, NOTE.a3, NOTE.g3, NOTE.e3][beat % 8];

    if (beat % 2 === 0) this._tone(bass, t, combat ? 0.22 : 0.28, combat ? 0.055 : 0.04, "sine", 0.02, null, this.music);
    if (beat % (combat ? 1 : 2) === 0) this._tone(lead, t + 0.03, 0.12, combat ? 0.035 : 0.026, "triangle", 0.01, null, this.music);
    if (beat % 4 === 0) this._drum(t, combat);
    if (!combat && beat % 8 === 4) this._marimba(t + 0.08);
    if (combat && beat % 3 === 0) this._noise(t + 0.03, 0.035, 0.025, 1800, "highpass", this.music);
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
