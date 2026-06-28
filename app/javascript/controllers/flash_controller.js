// Flash message Stimulus controller
// Auto-dismisses flash toasts after a delay, also supports manual close

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Value: how many ms before auto-dismiss (default 4000ms)
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    // Start auto-dismiss timer when the flash appears
    this.timer = setTimeout(() => {
      this.dismiss()
    }, this.delayValue)
  }

  disconnect() {
    // Clear timer if element is removed before timeout
    clearTimeout(this.timer)
  }

  dismiss() {
    // Slide back up quickly and fade out
    this.element.style.transition = "opacity 0.35s cubic-bezier(0.47, 0, 0.745, 0.715), transform 0.35s cubic-bezier(0.47, 0, 0.745, 0.715)"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-60px)"

    setTimeout(() => {
      this.element.remove()
    }, 350)
  }
}
