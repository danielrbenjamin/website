(function () {
  const mounts = document.querySelectorAll("[data-site-footer]");
  if (!mounts.length) return;

  mounts.forEach((mount) => {
    mount.outerHTML = `
      <footer class="wrap">
        <span class="copyright">© 2026 Daniel Benjamin</span>
        <span>ad astra.</span>
      </footer>`;
  });
})();
