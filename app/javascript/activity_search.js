const DEBOUNCE_MS = 300;

function initActivitySearch() {
  const form = document.getElementById("activity-search-form");
  const input = document.getElementById("activity-search-input");
  const frame = document.getElementById("activity_results");
  const clearBtn = document.getElementById("activity-search-clear");

  if (!form || !input || !frame) return;
  if (input.dataset.liveSearchReady === "true") return;
  input.dataset.liveSearchReady = "true";

  let timeout = null;

  function buildUrl() {
    const url = new URL(form.action, window.location.origin);
    const query = input.value.trim();
    if (query) url.searchParams.set("q", query);
    else url.searchParams.delete("q");
    return url.toString();
  }

  function updateClearButton() {
    if (!clearBtn) return;
    clearBtn.hidden = input.value.trim().length === 0;
  }

  async function fetchResults(pushState = true) {
    const url = buildUrl();
    frame.setAttribute("aria-busy", "true");

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "text/html",
          "X-Requested-With": "XMLHttpRequest"
        },
        credentials: "same-origin"
      });

      if (!response.ok) return;

      const html = await response.text();
      const doc = new DOMParser().parseFromString(html, "text/html");
      const fresh = doc.getElementById("activity_results");

      if (fresh) {
        frame.innerHTML = fresh.innerHTML;
        if (pushState) window.history.replaceState({}, "", url);
      }
    } catch (error) {
      console.error("[activity-search]", error);
    } finally {
      frame.removeAttribute("aria-busy");
    }
  }

  function scheduleSearch() {
    clearTimeout(timeout);
    updateClearButton();
    timeout = setTimeout(() => fetchResults(true), DEBOUNCE_MS);
  }

  input.addEventListener("input", scheduleSearch);
  input.addEventListener("keyup", scheduleSearch);

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    clearTimeout(timeout);
    fetchResults(true);
  });

  if (clearBtn) {
    clearBtn.addEventListener("click", () => {
      clearTimeout(timeout);
      input.value = "";
      updateClearButton();
      fetchResults(true);
    });
  }

  updateClearButton();
}

document.addEventListener("turbo:load", initActivitySearch);
document.addEventListener("DOMContentLoaded", initActivitySearch);
