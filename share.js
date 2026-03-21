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
  var backdropClickHandler = null; /* attached only while overlay is open */

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
    if (!overlay || overlay.style.display === 'none') {
      return;
    }

    overlay.style.display = 'none';
    overlay.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = previousOverflow;

    /* Remove the backdrop listener so it doesn't linger after close */
    if (backdropClickHandler) {
      document.removeEventListener('click', backdropClickHandler);
      backdropClickHandler = null;
    }
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
    overlay.setAttribute('aria-hidden', 'true');
    setStyles(overlay, {
      position: 'fixed',
      inset: '0',
      background: 'rgba(26,18,8,0.72)',
      display: 'none',
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
    closeButton.textContent = 'Zavrie' + '\u0165';
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
    eyebrow.textContent = 'Zdie' + '\u013e' + 'aj vydanie';
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
    intro.textContent = 'Vyber si, ako chce' + '\u0161' + ' odkaz posla' + '\u0165' + ' ' + '\u010f' + 'alej.';
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

    copyButton = buildAction('Skop' + '\u00ed' + 'rova' + '\u0165' + ' odkaz', true);
    openIssueLink = buildAction('Otvori' + '\u0165' + ' vydanie', false);
    emailLink = buildAction('Posla' + '\u0165' + ' emailom', false);
    whatsappLink = buildAction('WhatsApp', false);
    facebookLink = buildAction('Facebook', false);
    linkedinLink = buildAction('LinkedIn', false);
    xLink = buildAction('X', false);

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
        copyButton.textContent = 'Skop' + '\u00ed' + 'rovan' + '\u00e9';
        window.setTimeout(function () {
          copyButton.textContent = 'Skop' + '\u00ed' + 'rova' + '\u0165' + ' odkaz';
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
    note.textContent = 'Ak kop' + '\u00ed' + 'rovanie zlyh' + '\u00e1' + ', odkaz hore si m' + '\u00f4' + '\u017e' + 'e' + '\u0161' + ' ozna' + '\u010d' + 'i' + '\u0165' + ' a skop' + '\u00ed' + 'rova' + '\u0165' + ' ru' + '\u010d' + 'ne.';
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
    /* NOTE: no static click listener here — backdrop-close is attached
       dynamically inside openOverlay's setTimeout so it cannot fire
       during the same click that opened the overlay. */
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

    var title = issueNumber ? 'Rann' + '\u00e1' + ' Spr' + '\u00e1' + 'va - Vydanie #' + issueNumber : 'Rann' + '\u00e1' + ' Spr' + '\u00e1' + 'va';
    var shareMsg = 'Pozri si dne' + '\u0161' + 'n' + '\u00fa' + ' Rann' + '\u00fa' + ' Spr' + '\u00e1' + 'vu -> ' + issueUrl;

    return {
      issueUrl: issueUrl,
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
    copyButton.textContent = 'Skop' + '\u00ed' + 'rova' + '\u0165' + ' odkaz';
    openIssueLink.href = share.issueUrl;
    emailLink.href = 'mailto:?subject=' + encodeURIComponent(share.title) + '&body=' + encodeURIComponent(share.shareMsg);
    whatsappLink.href = 'https://wa.me/?text=' + encodeURIComponent(share.shareMsg);
    facebookLink.href = 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(share.issueUrl);
    linkedinLink.href = 'https://www.linkedin.com/sharing/share-offsite/?url=' + encodeURIComponent(share.issueUrl);
    xLink.href = 'https://twitter.com/intent/tweet?text=' + encodeURIComponent(share.shareMsg);

    window.setTimeout(function () {
      overlay.style.display = 'flex';
      overlay.setAttribute('aria-hidden', 'false');

      /* Attach the backdrop-close listener NOW — after the overlay is
         visible and after the opening click has fully propagated.
         Any click outside the panel will close the overlay. */
      backdropClickHandler = function (e) {
        if (!panel.contains(e.target)) {
          closeOverlay();
        }
      };
      document.addEventListener('click', backdropClickHandler);
    }, 0);
  }

  function handleShareClick(event) {
    event.preventDefault();
    openOverlay(event.currentTarget);
  }

  var shareLinks = document.querySelectorAll('.js-share-link');
  for (var i = 0; i < shareLinks.length; i += 1) {
    shareLinks[i].addEventListener('click', handleShareClick);
  }
}());
