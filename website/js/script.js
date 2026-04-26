// Intersection Observer for fade-up animations
const observer = new IntersectionObserver(
  (entries) => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); }),
  { threshold: 0.1, rootMargin: '0px 0px -40px 0px' }
);
document.querySelectorAll('.fade-up').forEach(el => observer.observe(el));

// Navbar background change on scroll
window.addEventListener('scroll', () => {
  const nav = document.querySelector('nav');
  if (nav) {
    nav.style.background = window.scrollY > 40 ? 'rgba(7,8,13,0.95)' : 'rgba(7,8,13,0.7)';
  }
});

// Deployment info loader (same as original, but using the new element IDs)
const deploymentInfoUrl = "js/deployment-info.json";
let lastBuildNumber = null;

function byId(id) { return document.getElementById(id); }
function setText(id, value) { const n = byId(id); if (n) n.textContent = value; }

function formatBytes(bytes) {
  if (!Number.isFinite(bytes) || bytes <= 0) return "Unknown";
  const units = ["B","KB","MB","GB"]; let size = bytes, index = 0;
  while (size >= 1024 && index < units.length - 1) { size /= 1024; index++; }
  return `${size.toFixed(size >= 10 ? 1 : 2)} ${units[index]}`;
}

async function getFileSize(path) {
  try {
    const r = await fetch(`${path}?v=${Date.now()}`, { method:"HEAD", cache:"no-store" });
    if (!r.ok) return "Unavailable";
    return formatBytes(Number(r.headers.get("content-length")));
  } catch { return "Unavailable"; }
}

async function loadDeploymentInfo() {
  try {
    const r = await fetch(`${deploymentInfoUrl}?v=${Date.now()}`, { cache:"no-store" });
    if (!r.ok) throw new Error("not found");
    const d = await r.json();
    const buildNumber = d.build_number || "-";
    lastBuildNumber = buildNumber;
    setText("pipeline-status", "Healthy");
    setText("build-number", buildNumber);
    setText("deployed-at", d.deployed_at_cameroon || d.last_deployed || "-");
    const [apk, aab] = await Promise.all([getFileSize("download/BatchIt.apk"), getFileSize("download/BatchIt.aab")]);
    setText("apk-size", apk);
    setText("aab-size", aab);
  } catch {
    setText("pipeline-status", "Waiting for first build");
  }
}

document.addEventListener("DOMContentLoaded", () => {
  loadDeploymentInfo();
  setInterval(loadDeploymentInfo, 30000);
});
document.addEventListener("visibilitychange", () => { if (!document.hidden) loadDeploymentInfo(); });