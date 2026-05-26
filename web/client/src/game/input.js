// Gestion clavier + souris (P1) ET gamepad (P2 quand branché). Reste passive :
// le jeu lit l'état chaque frame. Pour le P2 gamepad, on simule mouse.x/y autour
// de la position de son personnage en fonction du stick droit.

/** Lit le premier gamepad branché (ou null). Wrapper pour navigateurs récents. */
export function pollFirstGamepad() {
  if (typeof navigator === "undefined" || !navigator.getGamepads) return null;
  const pads = navigator.getGamepads();
  for (const p of pads) {
    if (p && p.connected) return p;
  }
  return null;
}

/** Source d'entrée pour le P2 (gamepad). Même API que Input : axis(), mouse,
 * consumeKey(), consumeRightClick(). Mis à jour chaque frame via `updateFromGamepad`.
 * Si aucun gamepad n'est branché, axis() renvoie {0,0} → P2 reste immobile (donc
 * invisible si pas activé dans GameScene).
 */
export class GamepadInput {
  constructor() {
    this._pad = null;
    this._prevButtons = [];
    this._justPressedButtons = new Set();
    this._aimVec = { x: 1, y: 0 };       // direction de visée stable même stick au repos
    // Mock d'objet "mouse" pour la rétro-compat avec Player.update
    this.mouse = { x: 0, y: 0, down: false, rightPressed: false };
    this.connected = false;
  }

  /** Appelé chaque frame par GameScene, AVANT player.update. ownerPos = {x,y} du P2. */
  updateFromGamepad(ownerPos) {
    this._pad = pollFirstGamepad();
    this.connected = !!this._pad;
    if (!this._pad) {
      this.mouse.down = false;
      return;
    }
    // Sticks : axes[0..3] = LX, LY, RX, RY
    const DZ = 0.18;          // deadzone
    const rx = Math.abs(this._pad.axes[2]) > DZ ? this._pad.axes[2] : 0;
    const ry = Math.abs(this._pad.axes[3]) > DZ ? this._pad.axes[3] : 0;
    if (rx !== 0 || ry !== 0) {
      const len = Math.hypot(rx, ry) || 1;
      this._aimVec.x = rx / len;
      this._aimVec.y = ry / len;
    }
    // Projette la "souris virtuelle" devant le joueur (200px) pour aim
    this.mouse.x = ownerPos.x + this._aimVec.x * 220;
    this.mouse.y = ownerPos.y + this._aimVec.y * 220;
    // RT (right trigger) ou A pour tirer : buttons[7] = RT, buttons[0] = A
    const rt = this._pad.buttons[7]?.value || 0;
    const a  = this._pad.buttons[0]?.pressed || false;
    this.mouse.down = rt > 0.45 || a;

    // Bouton X (2) ou Y (3) = consumeKey pour "switch arme" / "poser défense"
    const buttons = this._pad.buttons.map(b => b.pressed);
    this._justPressedButtons.clear();
    for (let i = 0; i < buttons.length; i++) {
      if (buttons[i] && !this._prevButtons[i]) this._justPressedButtons.add(i);
    }
    this._prevButtons = buttons;
    // Mappe le clic droit "poser défense" sur LB (4)
    this.mouse.rightPressed = this._justPressedButtons.has(4);
  }

  axis() {
    if (!this._pad) return { x: 0, y: 0 };
    const DZ = 0.18;
    const lx = Math.abs(this._pad.axes[0]) > DZ ? this._pad.axes[0] : 0;
    const ly = Math.abs(this._pad.axes[1]) > DZ ? this._pad.axes[1] : 0;
    const len = Math.hypot(lx, ly);
    if (len > 1) return { x: lx / len, y: ly / len };
    return { x: lx, y: ly };
  }

  consumeRightClick() {
    const pressed = this.mouse.rightPressed;
    this.mouse.rightPressed = false;
    return pressed;
  }

  consumeKey(code) {
    // Mappings synthétiques pour P2 :
    //  - "KeyE" (poser défense) → bouton B (1) du pad
    //  - "KeyQ" (cycle arme)    → bouton Y (3)
    if (code === "KeyE") return this._consumeButton(1);
    if (code === "KeyQ") return this._consumeButton(3);
    return false;
  }

  _consumeButton(idx) {
    if (this._justPressedButtons.has(idx)) {
      this._justPressedButtons.delete(idx);
      return true;
    }
    return false;
  }
}

export class Input {
  constructor(canvas) {
    this.canvas = canvas;
    this.keys = new Set();
    this.justPressed = new Set();
    this.mouse = { x: 0, y: 0, down: false, rightPressed: false };

    addEventListener("keydown", (e) => {
      if (!this.keys.has(e.code)) this.justPressed.add(e.code);
      this.keys.add(e.code);
      // Empêche le scroll avec les flèches
      if (["ArrowUp","ArrowDown","ArrowLeft","ArrowRight","Space"].includes(e.code)) {
        e.preventDefault();
      }
    });
    addEventListener("keyup", (e) => this.keys.delete(e.code));

    canvas.addEventListener("mousemove", (e) => {
      const rect = canvas.getBoundingClientRect();
      // Le canvas peut être redimensionné en CSS : remapper en coords logiques
      this.mouse.x = (e.clientX - rect.left) * (canvas.width / rect.width);
      this.mouse.y = (e.clientY - rect.top)  * (canvas.height / rect.height);
    });
    canvas.addEventListener("contextmenu", (e) => e.preventDefault());
    canvas.addEventListener("mousedown", (e) => {
      if (e.button === 2) this.mouse.rightPressed = true;
      else this.mouse.down = true;
    });
    addEventListener("mouseup", () => { this.mouse.down = false; });
    // Au cas où le curseur quitte la fenêtre
    addEventListener("blur", () => { this.keys.clear(); this.mouse.down = false; });
  }

  axis() {
    let dx = 0, dy = 0;
    if (this.keys.has("KeyW") || this.keys.has("ArrowUp") || this.keys.has("KeyZ")) dy -= 1;
    if (this.keys.has("KeyS") || this.keys.has("ArrowDown")) dy += 1;
    if (this.keys.has("KeyA") || this.keys.has("ArrowLeft") || this.keys.has("KeyQ")) dx -= 1;
    if (this.keys.has("KeyD") || this.keys.has("ArrowRight")) dx += 1;
    const len = Math.hypot(dx, dy);
    if (len > 0) { dx /= len; dy /= len; }
    return { x: dx, y: dy };
  }

  consumeRightClick() {
    const pressed = this.mouse.rightPressed;
    this.mouse.rightPressed = false;
    return pressed;
  }

  consumeKey(code) {
    const pressed = this.justPressed.has(code);
    this.justPressed.delete(code);
    return pressed;
  }
}
