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
    "splitModeLbl"
  ]

  connect() {
    this.splitMode = "equal"
    this.updateCalculations()
    
    // Setup date display
    if (this.hasDateInputTarget && this.dateInputTarget.value) {
      this.updateDateLabel()
    }
    
    // Setup paid by sync
    if (this.hasPaidBySelectTarget && this.hasPaidByDisplayTarget) {
      this.syncPaidBy()
    }
  }

  // ── calculations ──────────────────────────────────────────
  updateCalculations() {
    if (!this.hasTotalDisplayTarget) return;
    
    const totalRaw = parseFloat(this.totalDisplayTarget.value) || 0;
    const totalCents = Math.round(totalRaw * 100);

    if (this.splitMode === "equal") {
      const activeChecks = this.equalCheckTargets.filter(el => el.classList.contains("active"));
      const active = activeChecks.length || 1;
      
      if (this.hasPerPersonLblTarget) {
        this.perPersonLblTarget.textContent = "PKR " + (totalRaw / active).toFixed(2) + "/person (" + active + " people)";
      }
      
      if (activeChecks.length > 0) {
        const activeIndexes = activeChecks.map(el => el.closest("[data-index]").dataset.index);
        const share = Math.floor(totalCents / activeIndexes.length);
        const remainder = totalCents - (share * activeIndexes.length);

        this.splitCentsTargets.forEach((hiddenInput) => {
          const row = hiddenInput.closest("[data-index]");
          const idx = row.dataset.index;
          const isActive = activeIndexes.includes(idx);
          const amt = isActive ? share + (idx === activeIndexes[0] ? remainder : 0) : 0;
          hiddenInput.value = amt;
        });
      }
    } else {
      if (this.hasPerPersonLblTarget) {
        this.perPersonLblTarget.textContent = "Total: PKR " + totalRaw.toFixed(2);
      }
      
      this.exactInputTargets.forEach((input) => {
        const row = input.closest("[data-index]");
        const idx = row.dataset.index;
        let val = parseFloat(input.value) || 0;
        if (this.splitMode === "percentage") val = totalRaw * val / 100;
        
        const hiddenInput = this.splitCentsTargets.find(el => el.closest("[data-index]").dataset.index === idx);
        if (hiddenInput) {
          hiddenInput.value = Math.round(val * 100);
        }
      });
    }
  }

  // ── split mode tabs ──────────────────────────────────────────
  switchMode(e) {
    const tab = e.currentTarget;
    this.splitMode = tab.dataset.mode;
    
    this.splitModeTabTargets.forEach(t => t.classList.remove("ef-split-tab--active"));
    tab.classList.add("ef-split-tab--active");

    if (this.splitMode === "equal") {
      this.equalCheckTargets.forEach(el => el.style.display = "flex");
      this.exactInputTargets.forEach(el => el.style.display = "none");
      if (this.hasModeTextTarget) this.modeTextTarget.innerHTML = "<strong>Split equally</strong><span>Select which people owe an equal share.</span>";
      if (this.hasFooterAllTarget) this.footerAllTarget.style.display = "flex";
    } else {
      this.equalCheckTargets.forEach(el => el.style.display = "none");
      this.exactInputTargets.forEach(el => el.style.display = "block");
      const label = this.splitMode === "exact" ? "Split by exact amounts" : "Split by percentages";
      if (this.hasModeTextTarget) this.modeTextTarget.innerHTML = `<strong>${label}</strong><span>Enter the amount for each person.</span>`;
      if (this.hasFooterAllTarget) this.footerAllTarget.style.display = "none";
    }
    this.updateCalculations();
  }

  // ── members toggle ──────────────────────────────────────────
  toggleMember(e) {
    e.currentTarget.classList.toggle("active");
    this.updateCalculations();
  }

  toggleAll() {
    const allActive = this.equalCheckTargets.every(c => c.classList.contains("active"));
    this.equalCheckTargets.forEach(c => allActive ? c.classList.remove("active") : c.classList.add("active"));
    this.updateCalculations();
  }

  // ── form submit intercept ──────────────────────────────────────────
  submit(e) {
    const totalRaw = parseFloat(this.totalDisplayTarget.value) || 0;
    const totalCents = Math.round(totalRaw * 100);
    
    if (totalRaw <= 0) {
      e.preventDefault();
      alert("Please enter a valid amount.");
      return;
    }

    if (this.splitMode !== "equal") {
      let sumCents = 0;
      this.splitCentsTargets.forEach((hiddenInput) => {
        sumCents += parseInt(hiddenInput.value) || 0;
      });

      if (sumCents !== totalCents) {
        e.preventDefault();
        const label = this.splitMode === "percentage"
          ? "Percentages must add up to 100%. Currently: " + ((sumCents / totalCents) * 100).toFixed(1) + "%"
          : "Amounts (" + (sumCents/100).toFixed(2) + ") don't match the total (" + totalRaw.toFixed(2) + ")";
        alert(label);
        return;
      }
    }
  }

  // ── UI popups ──────────────────────────────────────────
  openSplitModal() {
    this.updateCalculations();
    if (this.hasSplitModalTarget) this.splitModalTarget.style.display = "flex";
  }
  closeSplitModal() {
    if (this.hasSplitModalTarget) this.splitModalTarget.style.display = "none";
  }
  doneSplitModal() {
    this.closeSplitModal();
    if (this.hasSplitModeLblTarget) {
      this.splitModeLblTarget.textContent = this.splitMode === "equal" ? "equally" : (this.splitMode === "exact" ? "by amount" : "by %");
    }
  }

  openCategoryModal() {
    if (this.hasCategoryModalTarget) this.categoryModalTarget.style.display = "flex";
  }
  closeCategoryModal() {
    if (this.hasCategoryModalTarget) this.categoryModalTarget.style.display = "none";
  }
  selectCategory(e) {
    const opt = e.currentTarget;
    if (this.hasCategoryInputTarget) this.categoryInputTarget.value = opt.dataset.value;
    if (this.hasCategoryIconDispTarget) this.categoryIconDispTarget.textContent = opt.dataset.icon;
    this.closeCategoryModal();
  }

  toggleNote() {
    if (this.hasNotePanelTarget) {
      this.notePanelTarget.style.display = this.notePanelTarget.style.display === "none" ? "block" : "none";
    }
  }
  
  openDatePicker() {
    if (this.hasDateInputTarget) {
      this.dateInputTarget.showPicker ? this.dateInputTarget.showPicker() : this.dateInputTarget.click();
    }
  }
  
  updateDateLabel() {
    if (!this.hasDateInputTarget || !this.hasDateLblTarget) return;
    const val = this.dateInputTarget.value;
    if (!val) return;
    const d = new Date(val + "T00:00:00");
    const today = new Date(); today.setHours(0,0,0,0);
    this.dateLblTarget.textContent = d.getTime() === today.getTime()
      ? "Today"
      : d.toLocaleDateString("en-US", { month:"short", day:"numeric" });
  }

  syncPaidBy() {
    if (this.hasPaidBySelectTarget && this.hasPaidByDisplayTarget) {
      const select = this.paidBySelectTarget;
      this.paidByDisplayTarget.textContent = select.options[select.selectedIndex].text;
    }
  }
}
