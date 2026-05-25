/* ============================================================================
   BatchIt — script.js
   Animations: fade-up, scroll progress, active nav, mouse parallax, particles
   ============================================================================ */

/* ── Scroll-progress bar ───────────────────────────────────────────────────── */
(function () {
  const bar = document.createElement('div');
  bar.className = 'scroll-progress';
  document.body.prepend(bar);
  window.addEventListener('scroll', () => {
    const max = document.documentElement.scrollHeight - innerHeight;
    bar.style.width = (scrollY / max * 100).toFixed(2) + '%';
  }, { passive: true });
})();

/* ── Navbar: scroll state + active section link ────────────────────────────── */
(function () {
  const nav   = document.querySelector('nav');
  const links = [...document.querySelectorAll('.nav-links a[href^="#"]')];
  const sections = links.map(a => document.querySelector(a.getAttribute('href'))).filter(Boolean);

  function onScroll () {
    if (!nav) return;

    // scrolled class for bg/shadow
    nav.classList.toggle('scrolled', scrollY > 50);

    // active link — find section whose top is closest above viewport midpoint
    const mid = scrollY + innerHeight * 0.4;
    let active = sections[0];
    sections.forEach(s => { if (s.offsetTop <= mid) active = s; });
    links.forEach(a => {
      a.classList.toggle('active', a.getAttribute('href') === '#' + active.id);
    });
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();
})();

/* ── Deployment info loader ────────────────────────────────────────────────── */
const deploymentInfoUrl = 'js/deployment-info.json';

function byId (id) { return document.getElementById(id); }
function setText (id, value) { const n = byId(id); if (n) n.textContent = value; }
function formatBytes (bytes) {
  if (!Number.isFinite(bytes) || bytes <= 0) return 'Unknown';
  const units = ['B','KB','MB','GB']; let size = bytes, i = 0;
  while (size >= 1024 && i < units.length - 1) { size /= 1024; i++; }
  return `${size.toFixed(size >= 10 ? 1 : 2)} ${units[i]}`;
}
async function getFileSize (path) {
  try {
    const r = await fetch(`${path}?v=${Date.now()}`, { method:'HEAD', cache:'no-store' });
    if (!r.ok) return 'Unavailable';
    return formatBytes(Number(r.headers.get('content-length')));
  } catch { return 'Unavailable'; }
}
async function loadDeploymentInfo () {
  try {
    const r = await fetch(`${deploymentInfoUrl}?v=${Date.now()}`, { cache:'no-store' });
    if (!r.ok) throw new Error('not found');
    const d = await r.json();
    setText('pipeline-status', 'Healthy');
    setText('build-number', d.build_number || '–');
    setText('deployed-at', d.deployed_at_cameroon || d.last_deployed || '–');
    const [apk, aab] = await Promise.all([
      getFileSize('download/BatchIt.apk'),
      getFileSize('download/BatchIt.aab'),
    ]);
    setText('apk-size', apk);
    setText('aab-size', aab);
  } catch {
    setText('pipeline-status', 'Waiting for first build');
  }
}

/* ── Intersection Observer for fade-up ────────────────────────────────────── */
const fadeObserver = new IntersectionObserver(
  entries => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); }),
  { threshold: 0.08, rootMargin: '0px 0px -40px 0px' }
);
document.querySelectorAll('.fade-up').forEach(el => fadeObserver.observe(el));

/* ── Mouse parallax on hero orbs ──────────────────────────────────────────── */
(function () {
  const hero = document.getElementById('hero');
  const orbs = [...document.querySelectorAll('.orb')];
  const strengths = [0.018, 0.012, 0.025, 0.008]; // multipliers per orb

  if (!hero || !orbs.length) return;

  let targetX = 0, targetY = 0, curX = 0, curY = 0;
  let raf;

  hero.addEventListener('mousemove', e => {
    const cx = innerWidth  / 2;
    const cy = innerHeight / 2;
    targetX = e.clientX - cx;
    targetY = e.clientY - cy;
  }, { passive: true });

  hero.addEventListener('mouseleave', () => { targetX = 0; targetY = 0; }, { passive: true });

  function tick () {
    curX += (targetX - curX) * 0.06;
    curY += (targetY - curY) * 0.06;
    orbs.forEach((orb, i) => {
      const s = strengths[i] || 0.01;
      orb.style.transform = `translate(${(curX * s).toFixed(2)}px, ${(curY * s).toFixed(2)}px)`;
    });
    raf = requestAnimationFrame(tick);
  }
  tick();
})();

/* ── Particle canvas ───────────────────────────────────────────────────────── */
(function () {
  const canvas = document.createElement('canvas');
  canvas.id = 'particle-canvas';
  document.body.prepend(canvas);
  const ctx = canvas.getContext('2d');

  function resize () {
    canvas.width  = innerWidth;
    canvas.height = innerHeight;
  }
  window.addEventListener('resize', resize, { passive: true });
  resize();

  const COLORS = ['rgba(29,200,138,', 'rgba(11,138,98,', 'rgba(255,179,71,'];
  const COUNT = 38;

  const particles = Array.from({ length: COUNT }, () => ({
    x:    Math.random() * innerWidth,
    y:    Math.random() * innerHeight + innerHeight,
    size: Math.random() * 1.6 + 0.4,
    speed: Math.random() * 0.5 + 0.15,
    opacity: Math.random() * 0.5 + 0.1,
    color: COLORS[Math.floor(Math.random() * COLORS.length)],
    drift: (Math.random() - 0.5) * 0.3,
  }));

  function draw () {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach(p => {
      p.y  -= p.speed;
      p.x  += p.drift;
      if (p.y < -10) {
        p.y = canvas.height + 10;
        p.x = Math.random() * canvas.width;
      }
      if (p.x < -10) p.x = canvas.width + 10;
      if (p.x > canvas.width + 10) p.x = -10;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fillStyle = p.color + p.opacity + ')';
      ctx.fill();
    });
    requestAnimationFrame(draw);
  }
  draw();
})();

/* ── Number counter animation for hero stats ───────────────────────────────── */
(function () {
  // Map stat elements to numeric targets where applicable
  const statMap = [
    { selector: '.hero-stat:nth-child(1) .hero-stat-num', target: 500, suffix: 'm',  duration: 1800 },
    { selector: '.hero-stat:nth-child(2) .hero-stat-num', target: 40,  prefix: 'Up to ', suffix: '%', duration: 1600 },
  ];

  const counterObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      counterObserver.unobserve(entry.target);
      const cfg = entry.target._counterCfg;
      if (!cfg) return;
      const start = performance.now();
      function step (now) {
        const t = Math.min((now - start) / cfg.duration, 1);
        const eased = 1 - Math.pow(1 - t, 3);
        const val = Math.round(eased * cfg.target);
        entry.target.textContent = (cfg.prefix || '') + val + (cfg.suffix || '');
        if (t < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    });
  }, { threshold: 0.5 });

  statMap.forEach(cfg => {
    const el = document.querySelector(cfg.selector);
    if (!el) return;
    el._counterCfg = cfg;
    counterObserver.observe(el);
  });
})();

/* ── Init ──────────────────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
  loadDeploymentInfo();
  setInterval(loadDeploymentInfo, 30000);
});
document.addEventListener('visibilitychange', () => {
  if (!document.hidden) loadDeploymentInfo();
});
