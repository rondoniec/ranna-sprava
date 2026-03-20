(function () {
  var overlay;
  var frame;
  var previousOverflow = '';

  function closeOverlay() {
    if (!overlay) {
      return;
    }

    overlay.setAttribute('hidden', '');
    frame.setAttribute('src', 'about:blank');
    document.body.style.overflow = previousOverflow;
  }

  function ensureOverlay() {
    if (overlay) {
      return;
    }

    overlay = document.createElement('div');
    overlay.setAttribute('hidden', '');
    overlay.setAttribute('aria-hidden', 'true');
    overlay.style.position = 'fixed';
    overlay.style.inset = '0';
    overlay.style.background = 'rgba(26,18,8,0.72)';
    overlay.style.display = 'flex';
    overlay.style.alignItems = 'center';
    overlay.style.justifyContent = 'center';
    overlay.style.padding = '24px';
    overlay.style.zIndex = '9999';

    var panel = document.createElement('div');
    panel.style.position = 'relative';
    panel.style.width = '100%';
    panel.style.maxWidth = '640px';
    panel.style.height = 'min(760px, calc(100vh - 48px))';
    panel.style.background = '#FAFAF7';
    panel.style.border = '1.5px solid #1A1208';
    panel.style.boxShadow = '6px 6px 0 #C8962A';
    panel.style.overflow = 'hidden';

    var closeButton = document.createElement('button');
    closeButton.type = 'button';
    closeButton.textContent = 'Zavriet';
    closeButton.style.position = 'absolute';
    closeButton.style.top = '12px';
    closeButton.style.right = '12px';
    closeButton.style.height = '36px';
    closeButton.style.padding = '0 14px';
    closeButton.style.border = '1px solid #1A1208';
    closeButton.style.background = '#FAFAF7';
    closeButton.style.color = '#1A1208';
    closeButton.style.cursor = 'pointer';
    closeButton.style.fontFamily = "'Lora', serif";
    closeButton.style.fontSize = '11px';
    closeButton.style.textTransform = 'uppercase';
    closeButton.style.letterSpacing = '1px';
    closeButton.style.zIndex = '2';
    closeButton.addEventListener('click', closeOverlay);

    frame = document.createElement('iframe');
    frame.setAttribute('title', 'Zdielaj vydanie');
    frame.style.width = '100%';
    frame.style.height = '100%';
    frame.style.border = '0';
    frame.style.display = 'block';
    frame.style.background = '#FAFAF7';

    panel.appendChild(closeButton);
    panel.appendChild(frame);
    overlay.appendChild(panel);
    document.body.appendChild(overlay);

    overlay.addEventListener('click', function (event) {
      if (event.target === overlay) {
        closeOverlay();
      }
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape' && overlay && !overlay.hasAttribute('hidden')) {
        closeOverlay();
      }
    });
  }

  function openOverlay(url) {
    ensureOverlay();
    previousOverflow = document.body.style.overflow;
    frame.setAttribute('src', url);
    overlay.removeAttribute('hidden');
    document.body.style.overflow = 'hidden';
  }

  function handleShareClick(event) {
    var link = event.currentTarget;
    var sharePageUrl = link.href;

    if (!sharePageUrl) {
      return;
    }

    event.preventDefault();
    openOverlay(sharePageUrl);
  }

  var shareLinks = document.querySelectorAll('.js-share-link');
  for (var i = 0; i < shareLinks.length; i += 1) {
    shareLinks[i].addEventListener('click', handleShareClick);
  }
}());
