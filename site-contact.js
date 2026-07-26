(function () {
  const mounts = document.querySelectorAll("[data-site-contact]");
  if (!mounts.length) return;

  mounts.forEach((mount) => {
    mount.outerHTML = `
      <section id="contact" class="contact">
        <div class="eyebrow reveal">Contact</div>
        <h2 class="sec-h reveal">Let's build something.</h2>
        <a href="mailto:contact@danielrbenjamin.com" class="contact-email reveal">contact@danielrbenjamin.com</a>
        <div class="links reveal">
          <a href="mailto:contact@danielrbenjamin.com" class="btn">✉ Email</a>
          <a href="https://github.com/danielrbenjamin" target="_blank" rel="noopener" class="btn">⌥ GitHub</a>
          <a href="https://linkedin.com/in/danielrbenjamin" target="_blank" rel="noopener" class="btn">in LinkedIn</a>
        </div>
      </section>`;
  });

  const io = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("in");
        io.unobserve(entry.target);
      }
    });
  }, { threshold: .1, rootMargin: "0px 0px -30px 0px" });

  document.querySelectorAll("#contact.reveal, #contact .reveal").forEach((el) => io.observe(el));
})();
