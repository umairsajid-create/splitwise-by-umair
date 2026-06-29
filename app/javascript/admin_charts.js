const CHART_COLORS = {
  users:      { border: "#1cb58a", background: "rgba(28, 181, 138, 0.75)" },
  groups:     { border: "#3b82f6", background: "rgba(59, 130, 246, 0.75)" },
  activities: { border: "#f59e0b", background: "rgba(245, 158, 11, 0.75)" }
};

let adminChartInstances = [];

function destroyAdminCharts() {
  adminChartInstances.forEach((chart) => chart.destroy());
  adminChartInstances = [];
}

function maxValue(data) {
  const peak = Math.max(...data, 0);
  return peak === 0 ? 5 : Math.ceil(peak * 1.2);
}

function buildChart(canvasId, datasetLabel, data, colors) {
  const canvas = document.getElementById(canvasId);
  const root = document.querySelector(".admin-charts");
  if (!canvas || !root || !window.Chart) return null;

  const labels = JSON.parse(root.dataset.labels || "[]");

  const chart = new window.Chart(canvas, {
    type: "bar",
    data: {
      labels: labels,
      datasets: [{
        label: datasetLabel,
        data: data,
        backgroundColor: colors.background,
        borderColor: colors.border,
        borderWidth: 1,
        borderRadius: 6,
        maxBarThickness: 48
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: "#1f2937",
          padding: 10,
          cornerRadius: 8
        }
      },
      scales: {
        x: {
          grid: { display: false },
          ticks: {
            maxRotation: 45,
            minRotation: 0,
            autoSkip: true,
            maxTicksLimit: 10
          }
        },
        y: {
          beginAtZero: true,
          suggestedMax: maxValue(data),
          ticks: { precision: 0, stepSize: 1 },
          grid: { color: "rgba(0,0,0,0.06)" }
        }
      }
    }
  });

  adminChartInstances.push(chart);
  return chart;
}

function initAdminCharts() {
  const root = document.querySelector(".admin-charts");
  if (!root || !window.Chart) return;

  destroyAdminCharts();

  const users = JSON.parse(root.dataset.users || "[]");
  const groups = JSON.parse(root.dataset.groups || "[]");
  const activities = JSON.parse(root.dataset.activities || "[]");

  buildChart("admin-users-chart", "New users", users, CHART_COLORS.users);
  buildChart("admin-groups-chart", "Groups", groups, CHART_COLORS.groups);
  buildChart("admin-activity-chart", "Activity", activities, CHART_COLORS.activities);
}

function loadChartJs() {
  if (window.Chart) {
    initAdminCharts();
    return;
  }

  if (document.getElementById("chartjs-cdn")) {
    document.getElementById("chartjs-cdn").addEventListener("load", initAdminCharts);
    return;
  }

  const script = document.createElement("script");
  script.id = "chartjs-cdn";
  script.src = "https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js";
  script.onload = initAdminCharts;
  document.head.appendChild(script);
}

document.addEventListener("turbo:load", loadChartJs);
document.addEventListener("turbo:before-cache", destroyAdminCharts);
document.addEventListener("DOMContentLoaded", loadChartJs);
