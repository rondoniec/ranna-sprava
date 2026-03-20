(function () {
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

  function setCopiedState(link) {
    if (link.dataset.shareBusy === '1') {
      return;
    }

    if (!link.dataset.originalText) {
      link.dataset.originalText = link.textContent;
    }

    link.dataset.shareBusy = '1';
    link.textContent = 'Skopirovane';

    window.setTimeout(function () {
      link.textContent = link.dataset.originalText;
      link.dataset.shareBusy = '0';
    }, 1800);
  }

  function handleShareClick(event) {
    var link = event.currentTarget;
    var shareUrl = link.getAttribute('data-share-url');

    if (!shareUrl) {
      return;
    }

    event.preventDefault();

    var copyPromise;
    if (navigator.clipboard && window.isSecureContext) {
      copyPromise = navigator.clipboard.writeText(shareUrl);
    } else {
      copyPromise = new Promise(function (resolve, reject) {
        try {
          fallbackCopy(shareUrl);
          resolve();
        } catch (error) {
          reject(error);
        }
      });
    }

    copyPromise.then(function () {
      setCopiedState(link);
    }).catch(function () {
      window.location.href = link.href;
    });
  }

  var shareLinks = document.querySelectorAll('.js-share-link[data-share-url]');
  for (var i = 0; i < shareLinks.length; i += 1) {
    shareLinks[i].addEventListener('click', handleShareClick);
  }
}());
