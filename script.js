/* ══════════════════════════════════════
   AQARIO — script.js
   منصة العقارات المغربية
══════════════════════════════════════ */

'use strict';

// ── DATA ──────────────────────────────────────────────────────
const LISTINGS_DATA = [
  {
    id: 1, icon: '🏢', title: 'شقة فاخرة 3 غرف — المعاريف',
    city: '📍 الدار البيضاء', type: 'شقة', op: 'sale',
    price: '1,450,000 MAD', area: '120م²', beds: '3', baths: '2',
    bg: 'linear-gradient(135deg,#1a0d3d,#2d1b69)', featured: true,
    verified: true,
  },
  {
    id: 2, icon: '🏡', title: 'فيلا مع حديقة — أكدال',
    city: '📍 الرباط', type: 'فيلا', op: 'sale',
    price: '3,200,000 MAD', area: '280م²', beds: '5', baths: '3',
    bg: 'linear-gradient(135deg,#0a1f35,#162f4f)', featured: true,
    verified: true,
  },
  {
    id: 3, icon: '🌿', title: 'أرض قابلة للبناء — يوسفية',
    city: '📍 مراكش', type: 'أرض', op: 'sale',
    price: '850,000 MAD', area: '400م²', beds: '—', baths: '—',
    bg: 'linear-gradient(135deg,#0d1f0a,#183015)', featured: false,
    verified: true,
  },
  {
    id: 4, icon: '🏢', title: 'شقة مودرن 2 غرف — مارينا',
    city: '📍 الدار البيضاء', type: 'شقة', op: 'rent',
    price: '8,500 MAD/شهر', area: '90م²', beds: '2', baths: '1',
    bg: 'linear-gradient(135deg,#1a0a2e,#300f55)', featured: false,
    verified: true,
  },
  {
    id: 5, icon: '🏪', title: 'محل تجاري — البال فاس',
    city: '📍 فاس', type: 'تجاري', op: 'rent',
    price: '12,000 MAD/شهر', area: '65م²', beds: '—', baths: '—',
    bg: 'linear-gradient(135deg,#250f00,#3d1a00)', featured: false,
    verified: true,
  },
  {
    id: 6, icon: '🏡', title: 'فيلا ساحلية — الصخيرات',
    city: '📍 الرباط', type: 'فيلا', op: 'sale',
    price: '5,800,000 MAD', area: '450م²', beds: '6', baths: '4',
    bg: 'linear-gradient(135deg,#002a1a,#004a2a)', featured: true,
    verified: true,
  },
];

// ── NAVBAR SCROLL ─────────────────────────────────────────────
window.addEventListener('scroll', () => {
  const nav = document.getElementById('navbar');
  if (nav) {
    nav.classList.toggle('scrolled', window.scrollY > 30);
  }
});

// ── MOBILE MENU ───────────────────────────────────────────────
function toggleMenu() {
  const links = document.getElementById('navLinks');
  const btn   = document.getElementById('hamburger');
  if (!links) return;
  const open = links.classList.toggle('open');
  btn.textContent = open ? '✕' : '☰';
}

// Close menu when clicking outside
document.addEventListener('click', (e) => {
  const links = document.getElementById('navLinks');
  const btn   = document.getElementById('hamburger');
  if (links && !links.contains(e.target) && !btn.contains(e.target)) {
    links.classList.remove('open');
    btn.textContent = '☰';
  }
});

// ── SEARCH TAB SWITCH ─────────────────────────────────────────
function switchTab(el, tab) {
  document.querySelectorAll('.stab').forEach(t => t.classList.remove('active'));
  el.classList.add('active');
}

// ── SEARCH ACTION ─────────────────────────────────────────────
function doSearch() {
  const city  = document.getElementById('citySelect')?.value  || '';
  const type  = document.getElementById('typeSelect')?.value  || '';
  const price = document.getElementById('priceSelect')?.value || '';

  const filtered = LISTINGS_DATA.filter(l => {
    const matchCity  = !city  || l.city.includes(city);
    const matchType  = !type  || l.type === type;
    return matchCity && matchType;
  });

  renderListings(filtered);

  // Scroll to listings
  document.getElementById('listings')?.scrollIntoView({ behavior: 'smooth' });

  // Flash feedback
  const btn = document.querySelector('.search-btn');
  if (btn) {
    const orig = btn.textContent;
    btn.textContent = `✓ ${filtered.length} نتيجة`;
    btn.style.background = 'linear-gradient(135deg,#10B981,#06B6D4)';
    setTimeout(() => {
      btn.textContent = orig;
      btn.style.background = '';
    }, 2000);
  }
}

// ── FILTER BY CATEGORY ────────────────────────────────────────
function filterCat(type) {
  const filtered = LISTINGS_DATA.filter(l => l.type.includes(type) || l.title.includes(type));
  renderListings(filtered.length ? filtered : LISTINGS_DATA);
  document.getElementById('listings')?.scrollIntoView({ behavior: 'smooth' });
}

// ── RENDER LISTINGS ───────────────────────────────────────────
function renderListings(data) {
  const grid = document.getElementById('listingsGrid');
  if (!grid) return;

  if (data.length === 0) {
    grid.innerHTML = `
      <div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--muted)">
        <div style="font-size:48px;margin-bottom:12px">🔍</div>
        <div style="font-size:16px;font-weight:700">لا توجد نتائج</div>
        <div style="font-size:13px;margin-top:6px">جرب تغيير معايير البحث</div>
      </div>`;
    return;
  }

  grid.innerHTML = data.map(l => `
    <div class="listing-card reveal" onclick="openListing(${l.id})">
      <div class="lc-img" style="background:${l.bg}">
        <span>${l.icon}</span>
        ${l.verified ? '<span class="lc-badge">✅ موثق</span>' : ''}
        ${l.featured ? '<span class="lc-featured">⭐ مميز</span>' : ''}
      </div>
      <div class="lc-body">
        <div class="lc-title">${l.title}</div>
        <div class="lc-city">${l.city} · ${l.type}</div>
        <div class="lc-specs">
          <span class="lc-spec">📐 ${l.area}</span>
          ${l.beds !== '—' ? `<span class="lc-spec">🛏 ${l.beds} غرف</span>` : ''}
          ${l.baths !== '—' ? `<span class="lc-spec">🚿 ${l.baths}</span>` : ''}
        </div>
        <div class="lc-footer">
          <span class="lc-price">${l.price}</span>
          <button class="lc-contact" onclick="event.stopPropagation();contactOwner(${l.id})">📞 تواصل</button>
        </div>
      </div>
    </div>
  `).join('');

  // Trigger reveal animations
  setTimeout(triggerReveal, 100);
}

// ── OPEN LISTING (placeholder) ────────────────────────────────
function openListing(id) {
  const listing = LISTINGS_DATA.find(l => l.id === id);
  if (!listing) return;
  showToast(`جاري فتح: ${listing.title}`);
}

// ── CONTACT OWNER ─────────────────────────────────────────────
function contactOwner(id) {
  const listing = LISTINGS_DATA.find(l => l.id === id);
  if (!listing) return;
  const msg = encodeURIComponent(`السلام عليكم، رأيت إعلانكم على Aqario: "${listing.title}" — هل لا زال متاحاً؟`);
  window.open(`https://wa.me/212600000000?text=${msg}`, '_blank');
}

// ── COUNTER ANIMATION ─────────────────────────────────────────
function animateCounters() {
  document.querySelectorAll('.hs-num[data-target]').forEach(el => {
    const target = parseInt(el.dataset.target);
    const dur    = 1400;
    const t0     = Date.now();
    const tick   = () => {
      const p = Math.min((Date.now() - t0) / dur, 1);
      const v = Math.round((1 - Math.pow(1 - p, 3)) * target);
      el.textContent = v.toLocaleString('ar-MA');
      if (p < 1) requestAnimationFrame(tick);
    };
    tick();
  });
}

// ── SCROLL REVEAL ─────────────────────────────────────────────
function triggerReveal() {
  const els = document.querySelectorAll('.reveal:not(.visible)');
  els.forEach(el => {
    const rect = el.getBoundingClientRect();
    if (rect.top < window.innerHeight - 60) {
      el.classList.add('visible');
    }
  });
}

// Add reveal class to animatable elements
function addRevealClasses() {
  const selectors = [
    '.cat-card', '.step-card', '.trust-item',
    '.agency-mini', '.section-head',
  ];
  selectors.forEach(sel => {
    document.querySelectorAll(sel).forEach((el, i) => {
      el.classList.add('reveal');
      el.style.transitionDelay = (i * 0.07) + 's';
    });
  });
}

// ── TOAST NOTIFICATION ────────────────────────────────────────
function showToast(msg, type = 'info') {
  const existing = document.getElementById('aqToast');
  if (existing) existing.remove();

  const colors = {
    info:    'rgba(124,58,237,.9)',
    success: 'rgba(16,185,129,.9)',
    error:   'rgba(239,68,68,.9)',
  };

  const toast = document.createElement('div');
  toast.id = 'aqToast';
  toast.textContent = msg;
  Object.assign(toast.style, {
    position: 'fixed', bottom: '24px', left: '50%',
    transform: 'translateX(-50%) translateY(20px)',
    background: colors[type] || colors.info,
    backdropFilter: 'blur(20px)',
    color: '#fff', padding: '12px 24px', borderRadius: '12px',
    fontFamily: 'Cairo, sans-serif', fontWeight: '700', fontSize: '14px',
    zIndex: '9999', opacity: '0',
    transition: 'all .3s ease', whiteSpace: 'nowrap',
    boxShadow: '0 8px 24px rgba(0,0,0,.4)',
  });

  document.body.appendChild(toast);

  requestAnimationFrame(() => {
    toast.style.opacity  = '1';
    toast.style.transform = 'translateX(-50%) translateY(0)';
  });

  setTimeout(() => {
    toast.style.opacity   = '0';
    toast.style.transform = 'translateX(-50%) translateY(20px)';
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

// ── SMOOTH ANCHOR LINKS ───────────────────────────────────────
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      // Close mobile menu
      document.getElementById('navLinks')?.classList.remove('open');
      const ham = document.getElementById('hamburger');
      if (ham) ham.textContent = '☰';
    }
  });
});

// ── PWA: SERVICE WORKER ───────────────────────────────────────
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js')
      .then(() => console.log('✅ Aqario SW registered'))
      .catch(err => console.log('SW error:', err));
  });
}

// ── INIT ──────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  // Render listings
  renderListings(LISTINGS_DATA);

  // Add reveal classes
  addRevealClasses();

  // Start counter animation after short delay
  setTimeout(animateCounters, 400);

  // Scroll listener for reveals
  window.addEventListener('scroll', triggerReveal, { passive: true });

  // Initial reveal check
  setTimeout(triggerReveal, 200);

  console.log('🏠 Aqario loaded — منصة العقارات المغربية');
});
