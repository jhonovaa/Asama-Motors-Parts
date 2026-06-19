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
