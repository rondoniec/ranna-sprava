(function () {
  var overlay;
  var panel;
  var titleNode;
  var urlNode;
  var copyButton;
  var openIssueLink;
  var emailLink;
  var whatsappLink;
  var facebookLink;
  var linkedinLink;
  var xLink;
  var previousOverflow = '';

  function fallbackCopy(text) {
    var textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', '');
    textarea.style.position = 'absolute';
    textarea.style.left = '-9999px';
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
  }

  function setStyles(node, styles) {
    var keys = Object.keys(styles);
    for (var i = 0; i < keys.length; i += 1) {
      node.style[keys[i]] = styles[keys[i]];
    }
  }

  function closeOverlay() {
    if (!overlay || overlay.hasAttribute('hidden')) {
      return;
    }

    overlay.setAttribute('hidden', '');
    overlay.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = previousOverflow;
  }

  function handleEscape(event) {
    if (event.key === 'Escape') {
      closeOverlay();
    }
  }

  function buildAction(label, isPrimary) {
    var action = document.createElement('a');
    action.href = '#';
    action.textContent = label;

    setStyles(action, {
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '46px',
      padding: '12px 14px',
      border: '1.5px solid #1A1208',
      textDecoration: 'none',
      color: isPrimary ? '#fff' : '#1A1208',
      background: isPrimary ? '#1A1208' : '#FAFAF7',
      fontFamily: "'Lora', serif",
      fontSize: '12px',
      textTransform: 'uppercase',
      letterSpacing: '1px',
      textAlign: 'center'
    });

    action.addEventListener('mouseenter', function () {
      action.style.background = '#C8962A';
      action.style.color = '#1A1208';
    });

    action.addEventListener('mouseleave', function () {
      action.style.background = isPrimary ? '#1A1208' : '#FAFAF7';
      action.style.color = isPrimary ? '#fff' : '#1A1208';
    });

    return action;
  }

  function ensureOverlay() {
    if (overlay) {
      return;
    }

    overlay = document.createElement('div');
    overlay.setAttribute('hidden', '');
    overlay.setAttribute('aria-hidden', 'true');
    setStyles(overlay, {
      position: 'fixed',
      inset: '0',
      background: 'rgba(26,18,8,0.72)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '24px',
      zIndex: '9999'
    });

    panel = document.createElement('div');
    setStyles(panel, {
      position: 'relative',
      width: '100%',
      maxWidth: '560px',
      background: '#FAFAF7',
      border: '1.5px solid #1A1208',
      boxShadow: '6px 6px 0 #C8962A',
      padding: '28px'
    });

    panel.addEventListener('click', function (event) {
      event.stopPropagation();
    });

    var closeButton = document.createElement('button');
    closeButton.type = 'button';
    closeButton.textContent = 'Zavrieť';
    setStyles(closeButton, {
      position: 'absolute',
      top: '12px',
      right: '12px',
      height: '36px',
      padding: '0 14px',
      border: '1px solid #1A1208',
      background: '#FAFAF7',
      color: '#1A1208',
      cursor: 'pointer',
      fontFamily: "'Lora', serif",
      fontSize: '11px',
      textTransform: 'uppercase',
      letterSpacing: '1px'
    });
    closeButton.addEventListener('click', closeOverlay);

    var eyebrow = document.createElement('div');
    eyebrow.textContent = 'Zdieľaj vydanie';
    setStyles(eyebrow, {
      fontFamily: "'Lora', serif",
      fontSize: '10px',
      letterSpacing: '2px',
      textTransform: 'uppercase',
      color: '#C8962A',
      marginBottom: '10px'
    });

    titleNode = document.createElement('h1');
    setStyles(titleNode, {
      fontFamily: "'Playfair Display', serif",
      fontSize: '34px',
      lineHeight: '1.1',
      textTransform: 'uppercase',
      marginBottom: '10px',
      color: '#1A1208'
    });

    var intro = document.createElement('p');
    intro.textContent = 'Vyber si, ako chceš odkaz poslať ďalej.';
    setStyles(intro, {
      fontFamily: "'Lora', serif",
      fontSize: '15px',
      lineHeight: '1.7',
      color: '#5A4E3F'
    });

    urlNode = document.createElement('div');
    setStyles(urlNode, {
      margin: '18px 0 22px',
      padding: '14px 16px',
      background: '#F0EAE0',
      border: '1px solid #D4C9B8',
      fontFamily: "'Lora', serif",
      fontSize: '14px',
      lineHeight: '1.5',
      color: '#1A1208',
      wordBreak: 'break-all'
    });

    var actions = document.createElement('div');
    setStyles(actions, {
      display: 'grid',
      gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
      gap: '10px'
    });

    copyButton = buildAction('Skopírovať odkaz', true);
    openIssueLink = buildAction('Otvoriť vydanie', false);
    emailLink = buildAction('Poslať emailom', false);
    whatsappLink = buildAction('WhatsApp', false);
    facebookLink = buildAction('Facebook', false);
    linkedinLink = buildAction('LinkedIn', false);
    xLink = buildAction('X', false);

    /* #2 — Pre-written message: copies a human-ready text, not just a bare URL */
    copyButton.addEventListener('click', function (event) {
      event.preventDefault();
      var shareUrl = copyButton.getAttribute('data-share-url');
      var shareMsg = copyButton.getAttribute('data-share-msg') || shareUrl;

      var promise;
      if (navigator.clipboard && window.isSecureContext) {
        promise = navigator.clipboard.writeText(shareMsg);
      } else {
        promise = new Promise(function (resolve, reject) {
          try {
            fallbackCopy(shareMsg);
            resolve();
          } catch (error) {
            reject(error);
          }
        });
      }

      promise.then(function () {
        copyButton.textContent = 'Skopírované ✓';
        window.setTimeout(function () {
          copyButton.textContent = 'Skopírovať odkaz';
        }, 1800);
      });
    });

    actions.appendChild(copyButton);
    actions.appendChild(openIssueLink);
    actions.appendChild(emailLink);
    actions.appendChild(whatsappLink);
    actions.appendChild(facebookLink);
    actions.appendChild(linkedinLink);
    actions.appendChild(xLink);

    var note = document.createElement('p');
    note.textContent = 'Ak kopírovanie zlyhá, odkaz hore si môžeš označiť a skopírovať ručne.';
    setStyles(note, {
      marginTop: '18px',
      fontFamily: "'Lora', serif",
      fontSize: '12px',
      color: '#7A6E5F'
    });

    panel.appendChild(closeButton);
    panel.appendChild(eyebrow);
    panel.appendChild(titleNode);
    panel.appendChild(intro);
    panel.appendChild(urlNode);
    panel.appendChild(actions);
    panel.appendChild(note);

    overlay.appendChild(panel);
    overlay.addEventListener('click', closeOverlay);
    document.body.appendChild(overlay);
    window.addEventListener('keydown', handleEscape);
  }

  function parseShareData(link) {
    var issueUrl = link.getAttribute('data-share-url') || link.href;
    var issueNumber = '';

    try {
      var parsedLink = new URL(link.href, window.location.href);
      issueNumber = parsedLink.searchParams.get('issue') || '';
    } catch (error) {
      issueNumber = '';
    }

    if (!issueNumber) {
      var match = issueUrl.match(/\/vydania\/(\d+)\//);
      if (match) {
        issueNumber = match[1];
      }
    }

    var title = issueNumber ? 'Ranná Správa – Vydanie #' + issueNumber : 'Ranná Správa';
    /* #2 — Pre-written share message used for clipboard copy, WhatsApp, and X */
    var shareMsg = 'Pozri si dnešnú Rannú Správu 👉 ' + issueUrl;

    return {
      issueNumber: issueNumber,
      issueUrl: issueUrl,
      sharePageUrl: link.href,
      title: title,
      shareMsg: shareMsg
    };
  }

  function openOverlay(link) {
    ensureOverlay();

    var share = parseShareData(link);
    previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    titleNode.textContent = share.title;
    urlNode.textContent = share.issueUrl;
    copyButton.setAttribute('data-share-url', share.issueUrl);
    copyButton.setAttribute('data-share-msg', share.shareMsg);
    copyButton.textContent = 'Skopírovať odkaz';
    openIssueLink.href = share.issueUrl;
    /* #2 — Pre-written message used in email subject/body, WhatsApp, X */
    emailLink.href = 'mailto:?subject=' + encodeURIComponent(share.title) + '&body=' + encodeURIComponent(share.shareMsg);
    whatsappLink.href = 'https://wa.me/?text=' + encodeURIComponent(share.shareMsg);
    facebookLink.href = 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(share.issueUrl);
    linkedinLink.href = 'https://www.linkedin.com/sharing/share-offsite/?url=' + encodeURIComponent(share.issueUrl);
    xLink.href = 'https://twitter.com/intent/tweet?text=' + encodeURIComponent(share.shareMsg);

    /* Defer showing by one tick so the triggering click event has already
       finished bubbling before the backdrop listener is active.
       Without this the opening click instantly hits the backdrop and closes
       the overlay on the same frame it opened. */
    window.setTimeout(function () {
      overlay.removeAttribute('hidden');
      overlay.setAttribute('aria-hidden', 'false');
    }, 0);
  }

  /* #1 — Native Share API: on mobile this opens the OS share sheet.
     Falls back to the in-page overlay when navigator.share is unavailable
     or when the user cancels (AbortError). */
  function handleShareClick(event) {
    event.preventDefault();
    var link = event.currentTarget;
    var share = parseShareData(link);

    if (navigator.share) {
      navigator.share({
        title: share.title,
        text: share.shareMsg,
        url: share.issueUrl
      }).catch(function (err) {
        /* AbortError = user cancelled the share sheet — do nothing.
           Any other error (e.g. DataError) falls back to overlay. */
        if (err && err.name !== 'AbortError') {
          openOverlay(link);
        }
      });
    } else {
      openOverlay(link);
    }
  }

  var shareLinks = document.querySelectorAll('.js-share-link');
  for (var i = 0; i < shareLinks.length; i += 1) {
    shareLinks[i].addEventListener('click', handleShareClick);
  }
}());
