import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "step", "progress", "nextBtn", "submitBtn", "backBtn" ]
  
  connect() {
    this.currentStep = 0
    this.updateUI()
  }
  
  next(e) {
    e.preventDefault()
    // Optional: add basic validation here before moving to next step
    if (this.currentStep < this.stepTargets.length - 1) {
      this.currentStep++
      this.updateUI()
    }
  }
  
  back(e) {
    e.preventDefault()
    if (this.currentStep > 0) {
      this.currentStep--
      this.updateUI()
    }
  }
  
  updateUI() {
    // Show/hide step containers
    this.stepTargets.forEach((el, index) => {
      if (index === this.currentStep) {
        el.style.display = "block"
        // add animation class for smooth transition
        el.classList.add("animate-fade-in") 
      } else {
        el.style.display = "none"
        el.classList.remove("animate-fade-in")
      }
    })
    
    // Update progress bar width
    if (this.hasProgressTarget) {
      const progressPercent = ((this.currentStep + 1) / this.stepTargets.length) * 100
      this.progressTarget.style.width = `${progressPercent}%`
    }
    
    // Show/hide buttons based on current step
    const isFirstStep = this.currentStep === 0
    const isLastStep = this.currentStep === this.stepTargets.length - 1
    
    if (this.hasBackBtnTarget) {
      this.backBtnTarget.style.display = isFirstStep ? "none" : "flex"
    }
    
    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.style.display = isLastStep ? "none" : "flex"
    }
    
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.style.display = isLastStep ? "flex" : "none"
    }
  }
}
