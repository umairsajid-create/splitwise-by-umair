(function() {
  const form = document.getElementById("expense-form");
  if (!form) return;

  const totalInput   = document.getElementById("expense_total_amount_display");
  const currencyBadge = document.getElementById("ef-currency-badge");
  const paidBySelect  = document.getElementById("expense_paid_by_id");
  const paidByDisplay = document.getElementById("ef-paidby-display");
  const splitModal    = document.getElementById("ef-split-modal");
  const splitPill     = document.getElementById("ef-split-pill");
  const splitModeLbl  = document.getElementById("ef-split-mode-label");
  const modeText      = document.getElementById("ef-mode-label-text");
  const perPersonLbl  = document.getElementById("ef-per-person-label");
  const dateInput     = document.getElementById("expense_expense_date");
  const dateLbl       = document.getElementById("ef-date-label");
  const noteBtn       = document.getElementById("ef-toolbar-note");
  const notePanel     = document.getElementById("ef-note-panel");
  const footerAll     = document.getElementById("ef-footer-all");

  const categoryModal    = document.getElementById("ef-category-modal");
  const categoryTrigger  = document.getElementById("ef-category-trigger");
  const categoryBack     = document.getElementById("ef-category-back");
  const categoryInput    = document.getElementById("expense_category");
  const categoryIconDisp = document.getElementById("ef-category-icon-display");

  let splitMode = "equal";
  const memberCount = document.querySelectorAll(".ef-split-member").length;

  if (paidBySelect) {
    paidBySelect.addEventListener("change", function() {
      paidByDisplay.textContent = this.options[this.selectedIndex].text;
    });
  }

  document.getElementById("ef-toolbar-date").addEventListener("click", function() {
    dateInput.showPicker ? dateInput.showPicker() : dateInput.click();
  });
  dateInput.addEventListener("change", function() {
    if (!this.value) return;
    const d = new Date(this.value + "T00:00:00");
    const today = new Date(); today.setHours(0,0,0,0);
    dateLbl.textContent = d.getTime() === today.getTime()
      ? "Today"
      : d.toLocaleDateString("en-US", { month:"short", day:"numeric" });
  });

  noteBtn.addEventListener("click", function() {
    notePanel.style.display = notePanel.style.display === "none" ? "block" : "none";
  });

  categoryTrigger.addEventListener("click", function() {
    categoryModal.style.display = "flex";
  });
  categoryBack.addEventListener("click", function() {
    categoryModal.style.display = "none";
  });
  document.querySelectorAll(".category-option").forEach(function(opt) {
    opt.addEventListener("click", function() {
      categoryInput.value = this.dataset.value;
      categoryIconDisp.textContent = this.dataset.icon;
      categoryModal.style.display = "none";
    });
  });

  splitPill.addEventListener("click", function() {
    updatePerPerson();
    splitModal.style.display = "flex";
  });
  document.getElementById("ef-split-cancel").addEventListener("click", function() {
    splitModal.style.display = "none";
  });
  document.getElementById("ef-split-done").addEventListener("click", function() {
    splitModal.style.display = "none";
    splitModeLbl.textContent = splitMode === "equal" ? "equally" : (splitMode === "exact" ? "by amount" : "by %");
  });

  document.querySelectorAll(".ef-split-tab").forEach(function(tab) {
    tab.addEventListener("click", function() {
      splitMode = this.dataset.mode;
      document.querySelectorAll(".ef-split-tab").forEach(t => t.classList.remove("ef-split-tab--active"));
      this.classList.add("ef-split-tab--active");

      const equalChecks  = document.querySelectorAll(".equal-check");
      const exactInputs  = document.querySelectorAll(".exact-input");

      if (splitMode === "equal") {
        equalChecks.forEach(el => el.style.display = "flex");
        exactInputs.forEach(el => el.style.display = "none");
        modeText.innerHTML = "<strong>Split equally</strong><span>Select which people owe an equal share.</span>";
        footerAll.style.display = "flex";
      } else {
        equalChecks.forEach(el => el.style.display = "none");
        exactInputs.forEach(el => el.style.display = "block");
        const label = splitMode === "exact" ? "Split by exact amounts" : "Split by percentages";
        modeText.innerHTML = "<strong>" + label + "</strong><span>Enter the amount for each person.</span>";
        footerAll.style.display = "none";
      }
      updatePerPerson();
    });
  });

  document.querySelectorAll(".ef-split-member").forEach(function(row) {
    row.querySelector(".equal-check").addEventListener("click", function() {
      this.classList.toggle("active");
      updatePerPerson();
    });
  });

  footerAll.addEventListener("click", function() {
    const allChecks = document.querySelectorAll(".equal-check");
    const allActive = [...allChecks].every(c => c.classList.contains("active"));
    allChecks.forEach(c => allActive ? c.classList.remove("active") : c.classList.add("active"));
    updatePerPerson();
  });

  function updatePerPerson() {
    const total  = parseFloat(totalInput.value) || 0;
    if (splitMode === "equal") {
      const active = document.querySelectorAll(".equal-check.active").length || 1;
      perPersonLbl.textContent = "PKR " + (total / active).toFixed(2) + "/person (" + active + " people)";
    } else {
      perPersonLbl.textContent = "Total: PKR " + total.toFixed(2);
    }
  }

  totalInput.addEventListener("input", updatePerPerson);

  form.addEventListener("submit", function(e) {
    e.preventDefault();

    const displayInput = document.getElementById("expense_total_amount_display");
    const centsField   = document.getElementById("expense_total_amount_cents");
    const totalRaw     = parseFloat(displayInput.value) || 0;

    if (totalRaw <= 0) {
      alert("Please enter a valid amount.");
      return;
    }

    const totalCents = Math.round(totalRaw * 100);
    centsField.value = totalCents;

    if (splitMode === "equal") {
      const activeChecks  = document.querySelectorAll(".equal-check.active");
      const activeIndexes = [...activeChecks].map(el => el.closest(".ef-split-member").dataset.index);
      const count = activeIndexes.length;

      if (count === 0) {
        alert("Please select at least one person to split with.");
        return;
      }

      const share     = Math.floor(totalCents / count);
      const remainder = totalCents - (share * count);

      document.querySelectorAll(".ef-split-member").forEach(function(row, i) {
        const idx      = row.dataset.index;
        const isActive = activeIndexes.includes(idx);
        const amt      = isActive ? share + (idx === activeIndexes[0] ? remainder : 0) : 0;
        document.getElementById("split_cents_" + idx).value = amt;
      });

    } else {
      let sumCents = 0;
      document.querySelectorAll(".ef-split-member").forEach(function(row) {
        const idx   = row.dataset.index;
        const input = row.querySelector(".exact-input");
        let val     = parseFloat(input.value) || 0;
        if (splitMode === "percentage") val = totalRaw * val / 100;
        const cents = Math.round(val * 100);
        document.getElementById("split_cents_" + idx).value = cents;
        sumCents += cents;
      });

      if (sumCents !== totalCents) {
        const label = splitMode === "percentage"
          ? "Percentages must add up to 100%. Currently: " + (sumCents / totalRaw).toFixed(1) + "%"
          : "Amounts (" + (sumCents/100).toFixed(2) + ") don't match the total (" + totalRaw.toFixed(2) + ")";
        alert(label);
        return;
      }
    }

    form.submit();
  });
})();
