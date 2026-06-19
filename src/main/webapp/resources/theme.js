/* ═══════════════════════════════════════════════════════
   Asama Moto Parts — Theme Toggle Script
   ═══════════════════════════════════════════════════════ */

// Apply saved theme immediately to prevent flash
(function() {
    var theme = localStorage.getItem('asama-theme') || 'dark';
    if (theme === 'light') {
        document.body.classList.add('light-mode');
    }
})();

function toggleTheme() {
    document.body.classList.toggle('light-mode');
    var isLight = document.body.classList.contains('light-mode');
    localStorage.setItem('asama-theme', isLight ? 'light' : 'dark');
    // Update toggle icon
    var icon = document.getElementById('themeIcon');
    if (icon) {
        icon.className = isLight ? 'bi bi-moon-fill' : 'bi bi-sun-fill';
    }
}

// Update icon on page load to match current state
document.addEventListener('DOMContentLoaded', function() {
    var isLight = document.body.classList.contains('light-mode');
    var icon = document.getElementById('themeIcon');
    if (icon) {
        icon.className = isLight ? 'bi bi-moon-fill' : 'bi bi-sun-fill';
    }
});

/* ═══════════════════════════════════════════════════════
   Global Slow Internet / Loading Alert
   ═══════════════════════════════════════════════════════ */
(function() {
    var activeRequests = 0;
    var loaderTimeout = null;
    var safetyTimeout = null;
    var loaderElement = null;
    var SLOW_THRESHOLD_MS = 600; // Muestra la alerta si toma más de 600ms
    var MAX_LOADER_TIME_MS = 15000; // Oculta a los 15s por seguridad

    function createLoader() {
        if (loaderElement) return;
        loaderElement = document.createElement('div');
        loaderElement.id = 'global-slow-loader';
        loaderElement.style.cssText = 'position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 999999; display: none; flex-direction: column; justify-content: center; align-items: center; background: rgba(0,0,0,0.85); backdrop-filter: blur(5px);';
        loaderElement.innerHTML = 
            '<div class="spinner-border text-warning" style="width: 3.5rem; height: 3.5rem; border-width: 0.25em;" role="status"></div>' +
            '<h4 class="text-white mt-4 fw-bold" style="letter-spacing: 1px;">Conexión lenta...</h4>' +
            '<p class="text-white-50 small">Por favor espera un momento.</p>';
        document.body.appendChild(loaderElement);
    }

    function showLoader() {
        if (!loaderElement && document.body) createLoader();
        if (loaderElement) {
            loaderElement.style.display = 'flex';
            clearTimeout(safetyTimeout);
            safetyTimeout = setTimeout(forceHide, MAX_LOADER_TIME_MS);
        }
    }

    function forceHide() {
        activeRequests = 0;
        clearTimeout(loaderTimeout);
        clearTimeout(safetyTimeout);
        if (loaderElement) loaderElement.style.display = 'none';
    }

    function requestStarted() {
        activeRequests++;
        if (activeRequests === 1) {
            loaderTimeout = setTimeout(showLoader, SLOW_THRESHOLD_MS);
        }
    }

    function requestEnded() {
        activeRequests = Math.max(0, activeRequests - 1);
        if (activeRequests === 0) {
            forceHide();
        }
    }

    // 1. Interceptar fetch
    var originalFetch = window.fetch;
    window.fetch = function() {
        requestStarted();
        return originalFetch.apply(this, arguments).then(function(res) {
            requestEnded();
            return res;
        }).catch(function(err) {
            requestEnded();
            throw err;
        });
    };

    // 2. Interceptar XMLHttpRequest
    var originalXHR = window.XMLHttpRequest;
    function newXHR() {
        var xhr = new originalXHR();
        xhr.addEventListener('loadstart', requestStarted);
        xhr.addEventListener('loadend', requestEnded);
        xhr.addEventListener('error', requestEnded);
        xhr.addEventListener('abort', requestEnded);
        return xhr;
    }
    window.XMLHttpRequest = newXHR;

    // 3. Interceptar envíos de formularios
    document.addEventListener('submit', function(e) {
        if (e.target && e.target.target !== '_blank') {
            requestStarted();
        }
    });

    // 4. Reset al volver a la página (caché del navegador)
    window.addEventListener('pageshow', forceHide);

})();
