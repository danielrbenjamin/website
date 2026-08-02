(function () {
  const mounts = document.querySelectorAll("[data-site-footer]");
  mounts.forEach((mount) => {
    mount.outerHTML = `
      <footer class="wrap">
        <span class="copyright">© 2026 Daniel Benjamin</span>
        <span>ad astra.</span>
      </footer>`;
  });

  if (!document.querySelector(".project-body")) return;

  const images = document.querySelectorAll("main img:not([data-no-lightbox])");
  if (!images.length) return;

  const lightbox = document.createElement("div");
  lightbox.className = "project-lightbox";
  lightbox.setAttribute("role", "dialog");
  lightbox.setAttribute("aria-modal", "true");
  lightbox.setAttribute("aria-label", "Expanded project image");
  lightbox.hidden = true;
  lightbox.innerHTML = `
    <button class="project-lightbox-close" type="button" aria-label="Close expanded image">×</button>
    <img class="project-lightbox-image" alt="">`;
  document.body.appendChild(lightbox);

  const expandedImage = lightbox.querySelector(".project-lightbox-image");
  const closeButton = lightbox.querySelector(".project-lightbox-close");
  let trigger = null;
  let closeTimer = null;

  function openLightbox(image) {
    clearTimeout(closeTimer);
    trigger = image;
    expandedImage.src = image.currentSrc || image.src;
    expandedImage.alt = image.alt || "Expanded project image";
    lightbox.hidden = false;
    document.body.classList.add("project-lightbox-open");
    requestAnimationFrame(() => {
      lightbox.classList.add("is-open");
      closeButton.focus({ preventScroll: true });
    });
  }

  function closeLightbox() {
    if (lightbox.hidden) return;
    lightbox.classList.remove("is-open");
    document.body.classList.remove("project-lightbox-open");
    closeTimer = setTimeout(() => {
      lightbox.hidden = true;
      expandedImage.removeAttribute("src");
      if (trigger) trigger.focus({ preventScroll: true });
      trigger = null;
    }, 220);
  }

  images.forEach((image) => {
    image.classList.add("project-lightbox-trigger");
    image.tabIndex = 0;
    image.setAttribute("role", "button");
    image.setAttribute("aria-label", `${image.alt || "Project image"}. Click to expand.`);
    image.addEventListener("click", () => openLightbox(image));
    image.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        openLightbox(image);
      }
    });
  });

  closeButton.addEventListener("click", closeLightbox);
  lightbox.addEventListener("click", (event) => {
    if (event.target === lightbox) closeLightbox();
  });
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && !lightbox.hidden) closeLightbox();
  });
})();
