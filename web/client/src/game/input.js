// Gestion clavier + souris. Reste passive : le jeu lit l'état chaque frame.

export class Input {
  constructor(canvas) {
    this.canvas = canvas;
    this.keys = new Set();
    this.mouse = { x: 0, y: 0, down: false };

    addEventListener("keydown", (e) => {
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
    canvas.addEventListener("mousedown", () => { this.mouse.down = true; });
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
}
