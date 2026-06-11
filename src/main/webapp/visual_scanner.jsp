<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    boolean isLoggedIn = user != null;
    int roleId = isLoggedIn ? user.getRoleId() : 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Escáner Visual de Repuestos - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <!-- TensorFlow.js + MobileNet for image classification -->
    <script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@4.10.0/dist/tf.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@tensorflow-models/mobilenet@2.1.0/dist/mobilenet.min.js"></script>

    <style>
        body { font-family: 'Inter', sans-serif; background-color: var(--bg-color); color: var(--text-color); padding-top: 60px; }

        .scanner-section {
            background: var(--card-bg);
            border-radius: 20px;
            border: 1px solid var(--card-border);
            padding: 30px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.5);
        }

        .camera-container {
            position: relative;
            width: 100%;
            max-width: 480px;
            margin: 0 auto;
            border-radius: 16px;
            overflow: hidden;
            border: 3px solid var(--card-border);
            background: #000;
        }
        .camera-container video {
            width: 100%;
            height: auto;
            display: block;
        }
        .camera-container canvas {
            display: none;
        }
        .camera-overlay {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            display: flex; align-items: center; justify-content: center;
            pointer-events: none;
        }
        .scan-frame {
            width: 70%;
            height: 70%;
            border: 2px dashed var(--accent-orange);
            border-radius: 16px;
            position: relative;
        }
        .scan-frame::before {
            content: '';
            position: absolute;
            top: -2px; left: -2px; right: -2px; bottom: -2px;
            border-radius: 18px;
            background: linear-gradient(45deg, transparent 30%, rgba(255,107,53,0.1) 50%, transparent 70%);
            animation: scanPulse 2s ease-in-out infinite;
        }
        @keyframes scanPulse {
            0%, 100% { opacity: 0.3; }
            50% { opacity: 1; }
        }

        .capture-btn {
            background: var(--accent-orange);
            color: white;
            border: none;
            border-radius: 50%;
            width: 70px;
            height: 70px;
            font-size: 1.8rem;
            box-shadow: 0 8px 25px rgba(255,107,53,0.4);
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 20px auto 0;
        }
        .capture-btn:hover {
            transform: scale(1.1);
            box-shadow: 0 12px 35px rgba(255,107,53,0.5);
        }
        .capture-btn:active { transform: scale(0.95); }
        .capture-btn:disabled {
            opacity: 0.5;
            cursor: wait;
        }

        .ai-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255,107,53,0.1);
            border: 1px solid rgba(255,107,53,0.25);
            color: var(--accent-orange);
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .prediction-tag {
            display: inline-block;
            background: rgba(255,107,53,0.12);
            color: var(--accent-orange);
            border: 1px solid rgba(255,107,53,0.3);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 600;
            margin: 3px;
        }

        .product-grid { margin-top: 30px; }

        .product-card {
            background: var(--card-bg);
            border-radius: 16px;
            border: 1px solid var(--card-border);
            padding: 18px;
            text-align: center;
            transition: all 0.3s;
            box-shadow: 0 8px 20px rgba(0,0,0,0.3);
            height: 100%;
        }
        .product-card:hover {
            transform: translateY(-5px);
            border-color: var(--accent-orange);
            box-shadow: 0 12px 30px rgba(255,107,53,0.15);
        }
        .product-card img {
            width: 100%;
            height: 160px;
            object-fit: cover;
            border-radius: 12px;
            margin-bottom: 12px;
        }
        .product-card .placeholder-img {
            width: 100%;
            height: 160px;
            border-radius: 12px;
            background: var(--card-bg);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #555;
            font-size: 2.5rem;
            margin-bottom: 12px;
        }

        .btn-moto {
            background-color: var(--accent-orange);
            color: #fff;
            border: none;
            border-radius: 30px;
            padding: 8px 20px;
            font-weight: 600;
            transition: 0.3s;
        }
        .btn-moto:hover { background-color: #E55A2B; color: white; }

        .search-bar {
            background: var(--card-bg);
            border: 1px solid rgba(255,255,255,0.1);
            color: #fff;
            border-radius: 30px;
            padding: 12px 20px;
        }
        .search-bar:focus {
            background: var(--card-bg);
            color: #fff;
            border-color: var(--accent-orange);
            outline: none;
            box-shadow: 0 0 0 3px rgba(255,107,53,0.15);
        }

        .filter-chip {
            background: transparent;
            border: 1px solid rgba(255,255,255,0.15);
            color: #999;
            border-radius: 20px;
            padding: 6px 16px;
            font-size: 0.8rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }
        .filter-chip:hover, .filter-chip.active {
            background: rgba(255,107,53,0.1);
            border-color: var(--accent-orange);
            color: var(--accent-orange);
        }

        .loading-model {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.85);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 10;
            border-radius: 16px;
        }

        .text-orange { color: var(--accent-orange) !important; }

        .captured-preview {
            border: 2px solid var(--accent-orange);
            border-radius: 12px;
            max-width: 200px;
            margin: 10px auto;
        }
    </style>
</head>
<body>

    <%@ include file="navbar.jsp" %>

    <div class="container" style="margin-top: 30px; margin-bottom: 50px;">
        <!-- Header -->
        <div class="text-center mb-4">
            <h2 class="fw-bold"><i class="bi bi-camera text-orange me-2"></i>Escáner Visual de Repuestos</h2>
            <p class="text-secondary">Captura una foto del repuesto y la IA identificará productos similares</p>
            <span class="ai-badge"><i class="bi bi-cpu"></i> Powered by TensorFlow.js + MobileNet</span>
        </div>

        <div class="row g-4">
            <!-- Camera Panel -->
            <div class="col-lg-5">
                <div class="scanner-section">
                    <h5 class="fw-bold mb-3 text-center"><i class="bi bi-camera-video text-orange me-2"></i>Cámara</h5>
                    
                    <div class="camera-container" id="cameraContainer">
                        <video id="video" autoplay muted playsinline></video>
                        <canvas id="canvas"></canvas>
                        <div class="camera-overlay">
                            <div class="scan-frame"></div>
                        </div>
                        <div class="loading-model" id="modelLoading">
                            <div class="spinner-border text-warning mb-2"></div>
                            <span class="text-warning small">Cargando modelo de IA...</span>
                            <span class="text-secondary small mt-1">Esto puede tomar unos segundos</span>
                        </div>
                    </div>

                    <button class="capture-btn" id="captureBtn" onclick="captureAndAnalyze()" disabled>
                        <i class="bi bi-camera-fill"></i>
                    </button>
                    <p class="text-center text-secondary small mt-2">Apunta al repuesto y presiona para escanear</p>

                    <!-- Captured preview & Predictions -->
                    <div id="analysisResult" style="display:none;" class="mt-3">
                        <img id="capturedImage" class="captured-preview d-block" alt="Captura">
                        <div class="text-center mt-2">
                            <p class="small text-secondary mb-2">La IA detectó:</p>
                            <div id="predictionTags"></div>
                        </div>
                    </div>

                    <!-- Manual search fallback -->
                    <div class="mt-4">
                        <label class="form-label small text-secondary">O busca manualmente:</label>
                        <div class="d-flex gap-2">
                            <input type="text" id="manualSearch" class="form-control search-bar" placeholder="Ej. filtro, cadena, aceite...">
                            <button class="btn btn-moto" onclick="searchByText()">Buscar</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Results Panel -->
            <div class="col-lg-7">
                <div class="scanner-section">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0"><i class="bi bi-grid text-orange me-2"></i>Repuestos Encontrados</h5>
                        <span id="resultCount" class="text-secondary small">0 resultados</span>
                    </div>

                    <!-- Brand Filter Chips -->
                    <div id="brandFilters" class="d-flex flex-wrap gap-2 mb-3">
                        <button class="filter-chip active" onclick="filterByBrand('')">Todos</button>
                    </div>

                    <!-- Products Grid -->
                    <div class="product-grid">
                        <div class="row g-3" id="productsGrid">
                            <div class="col-12 text-center py-5">
                                <i class="bi bi-camera text-secondary" style="font-size: 3rem;"></i>
                                <p class="text-secondary mt-3">Captura una foto para buscar repuestos<br>o usa la búsqueda manual</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let model = null;
        let currentBrandFilter = '';
        let lastSearchResults = [];
        const isLoggedIn = <%= isLoggedIn %>;
        const userRoleId = <%= roleId %>;

        // ========== CAMERA ==========
        const video = document.getElementById('video');
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');

        async function initCamera() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: 'environment', width: { ideal: 640 }, height: { ideal: 480 } }
                });
                video.srcObject = stream;
            } catch(err) {
                console.error('Camera error:', err);
                document.getElementById('cameraContainer').innerHTML = 
                    '<div class="text-center p-5"><i class="bi bi-camera-video-off text-danger fs-1"></i>' +
                    '<p class="text-danger mt-2">No se pudo acceder a la cámara</p>' +
                    '<p class="text-secondary small">Usa la búsqueda manual</p></div>';
            }
        }

        // ========== MODEL ==========
        async function loadModel() {
            try {
                model = await mobilenet.load({ version: 2, alpha: 1.0 });
                document.getElementById('modelLoading').style.display = 'none';
                document.getElementById('captureBtn').disabled = false;
                console.log('MobileNet model loaded');
            } catch(err) {
                console.error('Model load error:', err);
                document.getElementById('modelLoading').innerHTML = 
                    '<span class="text-danger small"><i class="bi bi-exclamation-triangle me-1"></i>Error al cargar IA</span>' +
                    '<span class="text-secondary small mt-1">Usa la búsqueda manual</span>';
                // Still enable manual search
            }
        }

        // ========== CAPTURE & ANALYZE ==========
        async function captureAndAnalyze() {
            if (!model) {
                alert('El modelo de IA aún se está cargando. Usa la búsqueda manual.');
                return;
            }

            const captureBtn = document.getElementById('captureBtn');
            captureBtn.disabled = true;
            captureBtn.innerHTML = '<div class="spinner-border spinner-border-sm"></div>';

            // Capture frame from video
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            ctx.drawImage(video, 0, 0);
            
            // Show captured image
            const dataUrl = canvas.toDataURL('image/jpeg', 0.8);
            document.getElementById('capturedImage').src = dataUrl;
            document.getElementById('analysisResult').style.display = 'block';

            try {
                // Classify with MobileNet
                const predictions = await model.classify(canvas, 5);
                console.log('Predictions:', predictions);

                // Show prediction tags
                const tagsContainer = document.getElementById('predictionTags');
                tagsContainer.innerHTML = '';
                
                let searchTerms = [];
                predictions.forEach(pred => {
                    const label = pred.className;
                    const confidence = (pred.probability * 100).toFixed(1);
                    tagsContainer.innerHTML += '<span class="prediction-tag">' + label + ' (' + confidence + '%)</span>';
                    
                    // Split multi-word labels and collect unique terms
                    label.split(/[,\s]+/).forEach(term => {
                        const clean = term.toLowerCase().trim();
                        if (clean.length > 2 && !searchTerms.includes(clean)) {
                            searchTerms.push(clean);
                        }
                    });
                });

                // Translate common English labels to Spanish motorcycle part equivalents
                const translations = {
                    'chain': 'cadena', 'brake': 'freno', 'oil': 'aceite', 'filter': 'filtro',
                    'wheel': 'llanta', 'tire': 'llanta', 'battery': 'bateria', 'cable': 'cable',
                    'gear': 'piñon', 'bearing': 'rodamiento', 'spark': 'bujia', 'plug': 'bujia',
                    'disc': 'freno', 'pad': 'pastilla', 'light': 'luz', 'lamp': 'luz',
                    'motor': 'motor', 'engine': 'motor', 'gasket': 'empaque', 'piston': 'piston',
                    'clutch': 'embrague', 'throttle': 'acelerador', 'handlebar': 'manubrio',
                    'mirror': 'espejo', 'seat': 'silla', 'helmet': 'casco', 'wrench': 'herramienta',
                    'tool': 'herramienta', 'screw': 'tornillo', 'bolt': 'tornillo', 'nut': 'tuerca',
                    'rubber': 'caucho', 'plastic': 'plastico', 'metal': 'metal', 'steel': 'acero',
                    'lever': 'manigueta', 'sprocket': 'piñon', 'shaft': 'eje'
                };

                // Get only the most confident prediction to avoid searching for multiple unrelated concepts
                const topPrediction = predictions[0];
                let bestTerm = "";
                
                topPrediction.className.split(/[,\s]+/).forEach(term => {
                    const clean = term.toLowerCase().trim();
                    if (translations[clean] && !bestTerm) {
                        bestTerm = translations[clean];
                    } else if (clean.length > 2 && !bestTerm && !translations[clean]) {
                        bestTerm = clean; // fallback to english word if no translation
                    }
                });

                const searchQuery = bestTerm;
                
                // First try with AI labels
                let found = await fetchProducts(searchQuery);
                
                // If no results, DO NOT show all products. Just warn the user.
                if (found === 0) {
                    tagsContainer.innerHTML += '<br><span class="text-danger small mt-2 d-block"><i class="bi bi-exclamation-circle me-1"></i>No se encontraron repuestos similares en nuestro inventario.</span>';
                }

            } catch(err) {
                console.error('Analysis error:', err);
                document.getElementById('predictionTags').innerHTML = 
                    '<span class="text-danger small">Error al analizar la imagen. Intenta enfocar mejor o usa la búsqueda manual.</span>';
                // Do not fallback to the whole catalog anymore
            }

            captureBtn.disabled = false;
            captureBtn.innerHTML = '<i class="bi bi-camera-fill"></i>';
        }

        // ========== SEARCH ==========
        function searchByText() {
            const query = document.getElementById('manualSearch').value.trim();
            fetchProducts(query);
        }

        document.getElementById('manualSearch').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') searchByText();
        });

        async function fetchProducts(keyword) {
            let url = 'visualSearch?';
            if (keyword) url += 'keyword=' + encodeURIComponent(keyword);
            if (currentBrandFilter) url += '&brand=' + encodeURIComponent(currentBrandFilter);

            try {
                const res = await fetch(url);
                const data = await res.json();
                lastSearchResults = data;
                renderProducts(data);
                renderBrandFilters(data);
                return data.length;
            } catch(err) {
                console.error('Search error:', err);
                return 0;
            }
        }

        function renderProducts(products) {
            const grid = document.getElementById('productsGrid');
            const countEl = document.getElementById('resultCount');
            countEl.textContent = products.length + ' resultado' + (products.length !== 1 ? 's' : '');

            if (products.length === 0) {
                grid.innerHTML = '<div class="col-12 text-center py-5">' +
                    '<i class="bi bi-search text-secondary" style="font-size: 3rem;"></i>' +
                    '<p class="text-secondary mt-3">No se encontraron repuestos</p></div>';
                return;
            }

            grid.innerHTML = '';
            products.forEach(p => {
                const img = p.imageUrl 
                    ? '<img src="' + p.imageUrl + '" alt="' + p.name + '" loading="lazy">' 
                    : '<div class="placeholder-img"><i class="bi bi-tools"></i></div>';
                
                const stockBadge = p.stock > 0 
                    ? '<span class="badge bg-success bg-opacity-25 text-success">' + p.stock + ' en stock</span>'
                    : '<span class="badge bg-danger bg-opacity-25 text-danger">Agotado</span>';
                
                const addToCartBtn = p.stock > 0 
                    ? '<button class="btn btn-moto btn-sm w-100 mt-2" onclick="addToCart(' + p.id + ', \'' + p.name.replace(/'/g, "\\'") + '\', ' + p.price + ')"><i class="bi bi-cart-plus me-1"></i>Añadir</button>'
                    : '<button class="btn btn-secondary btn-sm w-100 mt-2" disabled>Agotado</button>';

                grid.innerHTML += 
                    '<div class="col-md-6 col-xl-4">' +
                        '<div class="product-card">' +
                            img +
                            '<h6 class="fw-bold mb-1">' + p.name + '</h6>' +
                            '<p class="text-secondary small mb-1">' + (p.brand || 'Genérico') + '</p>' +
                            '<div class="d-flex justify-content-between align-items-center mb-1">' +
                                '<h5 class="text-orange fw-bold mb-0">$' + p.price.toFixed(2) + '</h5>' +
                                stockBadge +
                            '</div>' +
                            addToCartBtn +
                        '</div>' +
                    '</div>';
            });
        }

        function renderBrandFilters(products) {
            const brands = [...new Set(products.map(p => p.brand).filter(b => b))];
            const container = document.getElementById('brandFilters');
            container.innerHTML = '<button class="filter-chip ' + (currentBrandFilter === '' ? 'active' : '') + '" onclick="filterByBrand(\'\')">Todos</button>';
            
            brands.forEach(brand => {
                container.innerHTML += '<button class="filter-chip ' + (currentBrandFilter === brand ? 'active' : '') + '" onclick="filterByBrand(\'' + brand + '\')">' + brand + '</button>';
            });
        }

        function filterByBrand(brand) {
            currentBrandFilter = brand;
            const filtered = brand === '' 
                ? lastSearchResults 
                : lastSearchResults.filter(p => p.brand === brand);
            renderProducts(filtered);
            
            // Update active chip
            document.querySelectorAll('.filter-chip').forEach(chip => {
                chip.classList.remove('active');
                if (chip.textContent === (brand || 'Todos')) chip.classList.add('active');
            });
        }

        // ========== CART ==========
        function addToCart(id, name, price) {
            if (!isLoggedIn) {
                window.location.href = "login.jsp?msg=Debes+iniciar+sesion+para+añadir+al+carrito";
                return;
            }
            let currentUserId = <%= user != null ? user.getId() : -1 %>;
            let cartKey = 'asama_cart_' + currentUserId;
            let cart = JSON.parse(localStorage.getItem(cartKey)) || [];
            let item = cart.find(i => i.id === id);
            if (item) {
                item.qty++;
            } else {
                cart.push({id, name, price, qty: 1});
            }
            localStorage.setItem(cartKey, JSON.stringify(cart));
            
            // Show nice toast instead of alert
            showToast(name + ' añadido al carrito');
        }

        function showToast(msg) {
            let toast = document.createElement('div');
            toast.style.cssText = 'position:fixed;bottom:30px;right:30px;background:var(--accent-orange);color:white;padding:14px 24px;border-radius:12px;font-weight:600;font-size:0.9rem;z-index:9999;box-shadow:0 8px 30px rgba(255,107,53,0.4);transform:translateY(20px);opacity:0;transition:all 0.3s;';
            toast.innerHTML = '<i class="bi bi-check-circle me-2"></i>' + msg;
            document.body.appendChild(toast);
            
            requestAnimationFrame(() => {
                toast.style.transform = 'translateY(0)';
                toast.style.opacity = '1';
            });
            
            setTimeout(() => {
                toast.style.transform = 'translateY(20px)';
                toast.style.opacity = '0';
                setTimeout(() => toast.remove(), 300);
            }, 2500);
        }

        // ========== INIT ==========
        window.addEventListener('load', async () => {
            await initCamera();
            await loadModel();
            // Load all products initially
            await fetchProducts('');
        });
    </script>
</body>
</html>
