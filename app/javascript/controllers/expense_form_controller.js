import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalDisplay",
    "splitModeTab", "equalCheck", "exactInput", "splitCents",
    "perPersonLbl", "modeText", "footerAll",
    "splitModal", "categoryModal",
    "categoryInput", "categoryIconDisp",
    "dateInput", "dateLbl", "notePanel",
    "paidBySelect", "paidByDisplay",
    "splitModeLbl", "splitTypeField"
  ]

  connect() {
    this.splitMode = "equal"
    this.updateCalculations()
    this.updateDateLabel()
    this.syncPaidBy()
  }

  // ── Amount calculations (real-time) ──────────────────────
  updateCalculations() {
    if (!this.hasTotalDisplayTarget) return

    const totalRaw   = parseFloat(this.totalDisplayTarget.value) || 0
    const totalCents = Math.round(totalRaw * 100)

    if (this.splitMode === "equal") {
      const active = this.equalCheckTargets.filter(el => el.classList.contains("active"))
      const count  = active.length || 1

      if (this.hasPerPersonLblTarget) {
        this.perPersonLblTarget.textContent =
          "PKR " + (totalRaw / count).toFixed(2) + "/person (" + count + " people)"
      }

      if (active.length > 0) {
        const activeIndexes = active.map(el => el.closest("[data-index]").dataset.index)
        const share     = Math.floor(totalCents / active.length)
        const remainder = totalCents - share * active.length

        this.splitCentsTargets.forEach(input => {
          const idx      = input.closest("[data-index]").dataset.index
          const isActive = activeIndexes.includes(idx)
          input.value    = isActive ? share + (idx === activeIndexes[0] ? remainder : 0) : 0
        })
      }
    } else {
      if (this.hasPerPersonLblTarget) {
        this.perPersonLblTarget.textContent = "Total: PKR " + totalRaw.toFixed(2)
      }

      this.exactInputTargets.forEach(input => {
        const idx  = input.closest("[data-index]").dataset.index
        let   val  = parseFloat(input.value) || 0
        if (this.splitMode === "percentage") val = totalRaw * val / 100

        const hidden = this.splitCentsTargets.find(
          el => el.closest("[data-index]").dataset.index === idx
        )
        if (hidden) hidden.value = Math.round(val * 100)
      })
    }
  }

  // ── Split mode tabs ──────────────────────────────────────
  switchMode(e) {
    const tab      = e.currentTarget
    this.splitMode = tab.dataset.mode

    // Update hidden split_type field so the server knows the split type
    if (this.hasSplitTypeFieldTarget) {
      this.splitTypeFieldTarget.value = this.splitMode
    }

    this.splitModeTabTargets.forEach(t => t.classList.remove("ef-split-tab--active"))
    tab.classList.add("ef-split-tab--active")

    if (this.splitMode === "equal") {
      this.equalCheckTargets.forEach(el => el.style.display = "flex")
      this.exactInputTargets.forEach(el => el.style.display = "none")
      if (this.hasModeTextTarget)
        this.modeTextTarget.innerHTML = "<strong>Split equally</strong><span>Select which people owe an equal share.</span>"
      if (this.hasFooterAllTarget)
        this.footerAllTarget.style.display = "flex"
    } else {
      this.equalCheckTargets.forEach(el => el.style.display = "none")
      this.exactInputTargets.forEach(el => el.style.display = "block")
      const label = this.splitMode === "exact" ? "Split by exact amounts" : "Split by percentages"
      if (this.hasModeTextTarget)
        this.modeTextTarget.innerHTML = `<strong>${label}</strong><span>Enter the amount for each person.</span>`
      if (this.hasFooterAllTarget)
        this.footerAllTarget.style.display = "none"
    }
    this.updateCalculations()
  }

  // ── Member toggles ──────────────────────────────────────
  toggleMember(e) {
    e.currentTarget.classList.toggle("active")
    this.updateCalculations()
  }

  toggleAll() {
    const allActive = this.equalCheckTargets.every(c => c.classList.contains("active"))
    this.equalCheckTargets.forEach(c =>
      allActive ? c.classList.remove("active") : c.classList.add("active")
    )
    this.updateCalculations()
  }

  // ── Form submit validation ──────────────────────────────
  submit(e) {
    const totalRaw   = parseFloat(this.totalDisplayTarget.value) || 0
    const totalCents = Math.round(totalRaw * 100)

    if (totalRaw <= 0) {
      e.preventDefault()
      alert("Please enter an amount greater than 0.")
      return
    }

    if (this.splitMode !== "equal") {
      let sumCents = 0
      this.splitCentsTargets.forEach(input => { sumCents += parseInt(input.value) || 0 })

      if (Math.abs(sumCents - totalCents) > 1) {  // allow 1 cent rounding tolerance
        e.preventDefault()
        const label = this.splitMode === "percentage"
          ? "Percentages must add up to 100%. Currently: " + ((sumCents / totalCents) * 100).toFixed(1) + "%"
          : "Amounts (" + (sumCents / 100).toFixed(2) + ") don't match total (" + totalRaw.toFixed(2) + ")"
        alert(label)
        return
      }
    }
    // All good — let the form submit normally
  }

  // ── Split Modal ─────────────────────────────────────────
  openSplitModal() {
    this.updateCalculations()
    if (this.hasSplitModalTarget) this.splitModalTarget.style.display = "flex"
  }
  closeSplitModal() {
    if (this.hasSplitModalTarget) this.splitModalTarget.style.display = "none"
  }
  doneSplitModal() {
    this.closeSplitModal()
    if (this.hasSplitModeLblTarget) {
      const labels = { equal: "equally", exact: "by amount", percentage: "by %" }
      this.splitModeLblTarget.textContent = labels[this.splitMode] || "equally"
    }
  }

  // ── Category Modal ──────────────────────────────────────
  openCategoryModal() {
    if (this.hasCategoryModalTarget) this.categoryModalTarget.style.display = "flex"
  }
  closeCategoryModal() {
    if (this.hasCategoryModalTarget) this.categoryModalTarget.style.display = "none"
  }
  selectCategory(e) {
    const opt = e.currentTarget
    if (this.hasCategoryInputTarget)   this.categoryInputTarget.value       = opt.dataset.value
    if (this.hasCategoryIconDispTarget) this.categoryIconDispTarget.textContent = opt.dataset.icon
    this.closeCategoryModal()
  }

  // ── Note toggle ─────────────────────────────────────────
  toggleNote() {
    if (!this.hasNotePanelTarget) return
    const panel = this.notePanelTarget
    panel.style.display = panel.style.display === "none" ? "block" : "none"
    if (panel.style.display === "block") {
      panel.querySelector("textarea")?.focus()
    }
  }

  // ── Date picker ─────────────────────────────────────────
  updateDateLabel() {
    if (!this.hasDateInputTarget || !this.hasDateLblTarget) return
    const val = this.dateInputTarget.value
    if (!val) return
    const d     = new Date(val + "T00:00:00")
    const today = new Date(); today.setHours(0, 0, 0, 0)
    this.dateLblTarget.textContent = d.getTime() === today.getTime()
      ? "Today"
      : d.toLocaleDateString("en-US", { month: "short", day: "numeric" })
  }

  // ── Paid by ─────────────────────────────────────────────
  syncPaidBy() {
    if (!this.hasPaidBySelectTarget || !this.hasPaidByDisplayTarget) return
    const select = this.paidBySelectTarget
    if (select.options.length > 0) {
      this.paidByDisplayTarget.textContent = select.options[select.selectedIndex].text
    }
  }
}
