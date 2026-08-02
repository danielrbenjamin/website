(function () {
  const mounts = document.querySelectorAll("[data-site-header]");
  if (!mounts.length) return;

  const thisScript =
    document.currentScript || document.querySelector('script[src$="site-header.js"]');
  const basePath = thisScript
    ? thisScript.getAttribute("src").replace(/site-header\.js(?:\?.*)?$/, "")
    : "";

  const currentPath = window.location.pathname;
  const currentFile = currentPath.split("/").pop() || "index.html";

  function isCurrent(href) {
    if (href === currentFile) return true;
    if (href === "projects.html" && currentPath.includes("/projects/")) return true;
    return false;
  }

  const desktopLinks = [
    { href: "index.html", label: "home" },
    { href: "about.html", label: "about" },
    { href: "projects.html", label: "projects" },
    { href: "experience.html", label: "experience" },
    { href: "resume.html", label: "résumé" },
    { href: "https://blog.danielrbenjamin.com/", label: "blog ↗", external: true },
  ];

  const mobileLinks = [
    { href: "index.html", label: "home" },
    { href: "about.html", label: "about" },
    { href: "projects.html", label: "projects" },
    { href: "experience.html", label: "experience" },
    { href: "resume.html", label: "résumé" },
    { href: "https://blog.danielrbenjamin.com/", label: "blog ↗", external: true },
  ];

  const logo = `
    <svg class="navlogo" viewBox="0 0 937.44 922.46" xmlns="http://www.w3.org/2000/svg" fill="none">
      <line x1="468.72" y1="254.47" x2="243.54" y2="254.47" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="558.80" x2="367.95" y2="757.53" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="558.80" x2="367.95" y2="194.97" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="194.97" x2="195.69" y2="50.22" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="50.22" y1="395.83" x2="367.95" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="395.83" x2="367.95" y2="757.53" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="757.53" x2="50.22" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="172.05" y1="534.52" x2="172.05" y2="359.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="172.05" y1="359.83" x2="243.54" y2="254.47" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="172.05" y1="534.52" x2="468.72" y2="872.24" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="468.72" y1="254.47" x2="693.90" y2="254.47" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="558.80" x2="569.49" y2="757.53" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="558.80" x2="569.49" y2="194.97" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="194.97" x2="741.74" y2="50.22" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="887.22" y1="395.83" x2="569.49" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="395.83" x2="569.49" y2="757.53" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="757.53" x2="887.22" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="765.38" y1="534.52" x2="765.38" y2="359.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="765.38" y1="359.83" x2="693.90" y2="254.47" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="765.38" y1="534.52" x2="468.72" y2="872.24" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="50.22" y1="395.83" x2="367.95" y2="757.53" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="757.53" x2="367.95" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="395.83" x2="50.22" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="395.83" x2="569.49" y2="757.53" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="757.53" x2="887.22" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="887.22" y1="395.83" x2="569.49" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="195.69" y1="50.22" x2="367.95" y2="194.97" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="367.95" y1="194.97" x2="367.95" y2="395.83" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="395.83" x2="569.49" y2="194.97" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
      <line x1="569.49" y1="194.97" x2="741.74" y2="50.22" stroke="currentColor" stroke-width="16" stroke-linecap="round"/>
    </svg>`;

  function renderLinks(links) {
    return links
      .map((link) => {
        const current = !link.external && isCurrent(link.href);
        const attrs = link.external ? ' target="_blank" rel="noopener"' : "";
        const currentAttrs = current ? ' class="is-current" aria-current="page"' : "";
        const href = link.external ? link.href : basePath + link.href;
        return `<a href="${href}"${attrs}${currentAttrs}>${link.label}</a>`;
      })
      .join("");
  }

  mounts.forEach((mount, index) => {
    const menuId = `mobile-menu-${index + 1}`;

    mount.innerHTML = `
      <div class="bar">
        <div class="id">
          <a href="${basePath}index.html" aria-label="Home">${logo}</a>
          <span>danielrbenjamin</span>
        </div>
        <nav>${renderLinks(desktopLinks)}</nav>
        <button class="menu-toggle" type="button" aria-label="Open menu" aria-expanded="false" aria-controls="${menuId}">
          <span></span><span></span>
        </button>
      </div>
      <div class="mobile-menu" id="${menuId}">
        ${renderLinks(mobileLinks)}
      </div>`;

    const toggle = mount.querySelector(".menu-toggle");
    const menu = mount.querySelector(".mobile-menu");
    if (!toggle || !menu) return;

    function closeMenu() {
      toggle.setAttribute("aria-expanded", "false");
      menu.classList.remove("is-open");
    }

    toggle.addEventListener("click", () => {
      const isOpen = toggle.getAttribute("aria-expanded") === "true";
      toggle.setAttribute("aria-expanded", String(!isOpen));
      menu.classList.toggle("is-open", !isOpen);
    });

    menu.querySelectorAll("a").forEach((link) => link.addEventListener("click", closeMenu));
    document.addEventListener("click", (event) => {
      if (!menu.classList.contains("is-open")) return;
      if (menu.contains(event.target) || toggle.contains(event.target)) return;
      closeMenu();
    });
    window.addEventListener("resize", () => {
      if (window.innerWidth > 680) closeMenu();
    });
  });
})();
