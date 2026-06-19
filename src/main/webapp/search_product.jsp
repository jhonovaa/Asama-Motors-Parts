<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    User user = (User) session.getAttribute("user");
    // Roles permitidos: Admin(1), Bodeguero(3), Cajero(4), Cliente(5), Mecánico(6)
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3 && user.getRoleId() != 4 && user.getRoleId() != 5 && user.getRoleId() != 6)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><fmt:message key="search_product.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Load html5-qrcode for barcode scanning -->
    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>
    <style>
        .main-container { margin-top: 100px; padding-bottom: 50px; }
        .section-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 30px;
            margin-bottom: 24px;
        }
        .nav-tabs-custom .nav-link {
            color: var(--text-color) !important;
            border: 2px solid rgba(255, 255, 255, 0.15) !important;
            background: transparent !important;
            border-radius: 30px;
            padding: 8px 20px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        body.light-mode .nav-tabs-custom .nav-link {
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        .nav-tabs-custom .nav-link.active {
            background-color: var(--accent-orange) !important;
            color: #121417 !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 4px 15px var(--accent-glow);
        }
        .result-card-premium {
            background: var(--card-bg);
            border: 2px solid var(--accent-orange);
            border-radius: 16px;
            padding: 24px;
            margin-top: 24px;
            box-shadow: 0 8px 30px var(--accent-glow);
            display: none;
        }
        /* Style reader scanner container */
        #reader {
            border: 2px solid var(--accent-orange) !important;
            border-radius: 16px !important;
            overflow: hidden;
            background: rgba(0,0,0,0.2);
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
        }
        #reader button {
            background: var(--accent-orange) !important;
            color: #121417 !important;
            font-weight: bold;
            border-radius: 30px !important;
            border: none !important;
            padding: 8px 24px !important;
            box-shadow: 0 4px 15px var(--accent-glow);
            transition: 0.3s;
        }
        #reader button:hover {
            transform: scale(1.05);
        }
    </style>
    <link rel="stylesheet" href="resources/theme.css?v=6">
</head>
<body>
    <script src="resources/theme.js"></script>

    <%@ include file="navbar.jsp" %>

    <div class="container main-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold m-0"><i class="bi bi-search text-accent me-2"></i> <fmt:message key="search_product.header" /></h2>
        </div>

        <div class="section-card">
            <ul class="nav nav-pills nav-tabs-custom gap-2 mb-4" id="searchTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="camera-tab" data-bs-toggle="tab" data-bs-target="#camera-pane" type="button" role="tab"><i class="bi bi-camera me-1"></i> <fmt:message key="search_product.camera" /></button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="manual-tab" data-bs-toggle="tab" data-bs-target="#manual-pane" type="button" role="tab"><i class="bi bi-keyboard me-1"></i> <fmt:message key="search_product.manual_code" /></button>
                </li>
            </ul>

            <div class="tab-content" id="searchTabsContent">
                <!-- Camera Tab -->
                <div class="tab-pane fade show active" id="camera-pane" role="tabpanel">
                    <div class="text-center mb-3 text-secondary small"><fmt:message key="search_product.camera_hint" /></div>
                    <div id="reader"></div>
                </div>

                <!-- Manual Tab -->
                <div class="tab-pane fade" id="manual-pane" role="tabpanel">
                    <div class="mb-3">
                        <label class="form-label text-secondary fw-semibold small"><fmt:message key="search_product.enter_barcode" /></label>
                        <input type="text" id="manualBarcode" class="form-control" placeholder="<fmt:message key='search_product.barcode_placeholder'/>">
                    </div>
                    <button class="btn btn-accent rounded-pill px-5 fw-bold" onclick="searchManual()"><fmt:message key="search_product.search_btn" /></button>
                </div>
            </div>

            <!-- Result Section -->
            <div id="loadingIndicator" class="text-center my-4" style="display: none;">
                <div class="spinner-border text-accent" role="status"></div>
                <div class="mt-2 text-secondary small"><fmt:message key="search_product.searching" /></div>
            </div>

            <div id="resultCard" class="result-card-premium">
                <div class="row align-items-center">
                    <div class="col-md-4 text-center mb-3 mb-md-0" id="resultImgContainer">
                        <!-- Image rendered here -->
                    </div>
                    <div class="col-md-8">
                        <h4 id="resName" class="fw-bold mb-1"></h4>
                        <div class="text-secondary small mb-3">
                            <i class="bi bi-tag-fill me-1 text-accent"></i> <span id="resBrand" class="fw-semibold"></span> 
                            <span class="mx-2 text-muted">|</span> 
                            <fmt:message key="search_product.code_prefix" /> <span id="resBarcode" class="badge bg-secondary px-2 py-1 text-white"></span>
                        </div>
                        <p id="resDesc" class="text-secondary small mb-4"></p>
                        
                        <div class="d-flex justify-content-between align-items-center mt-3 border-top border-secondary border-opacity-10 pt-3">
                            <div>
                                <div class="text-secondary small mb-1"><fmt:message key="search_product.unit_price" /></div>
                                <h3 class="text-accent fw-bold m-0" id="resPrice"></h3>
                            </div>
                            <div class="text-end">
                                <div class="text-secondary small mb-1"><fmt:message key="search_product.inventory" /></div>
                                <h4 class="m-0 fw-bold" id="resStock"></h4>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div id="errorCard" class="alert alert-danger mt-4" style="display:none;">
                <i class="bi bi-exclamation-triangle me-2"></i> <fmt:message key="search_product.not_found" />
            </div>

        </div>
    </div>

    <script>
        let html5QrcodeScanner = null;
        let isPaused = false;

        function startScanner() {
            if(!html5QrcodeScanner) {
                html5QrcodeScanner = new Html5QrcodeScanner(
                    "reader",
                    { 
                        fps: 10, 
                        qrbox: {width: 250, height: 100},
                        // Fix for camera: Explicitly support 1D barcode formats
                        formatsToSupport: [
                            Html5QrcodeSupportedFormats.CODE_128,
                            Html5QrcodeSupportedFormats.EAN_13,
                            Html5QrcodeSupportedFormats.EAN_8,
                            Html5QrcodeSupportedFormats.CODE_39
                        ]
                    },
                    /* verbose= */ false);
                
                html5QrcodeScanner.render(onScanSuccess, onScanFailure);
            }
        }

        function onScanSuccess(decodedText, decodedResult) {
            if(isPaused) return; // Prevent multiple reads
            
            isPaused = true;
            searchProduct(decodedText);
            
            // Pause scanner for 5 seconds to let user read the result
            document.getElementById('reader').style.opacity = '0.5';
            setTimeout(() => {
                isPaused = false;
                document.getElementById('reader').style.opacity = '1';
            }, 5000);
        }

        function onScanFailure(error) {
            // handle scan failure, usually better to ignore and keep scanning
        }

        function searchManual() {
            let barcode = document.getElementById('manualBarcode').value.trim();
            if(barcode !== '') {
                searchProduct(barcode);
            }
        }

        function searchProduct(barcode) {
            document.getElementById('resultCard').style.display = 'none';
            document.getElementById('errorCard').style.display = 'none';
            document.getElementById('loadingIndicator').style.display = 'block';

            fetch('productSearch?barcode=' + encodeURIComponent(barcode))
                .then(response => response.json())
                .then(data => {
                    document.getElementById('loadingIndicator').style.display = 'none';
                    if (data.error) {
                        document.getElementById('errorCard').style.display = 'block';
                    } else {
                        // Populate results
                        document.getElementById('resName').innerText = data.name;
                        document.getElementById('resBrand').innerText = data.brand || '<fmt:message key="search_product.generic"/>';
                        document.getElementById('resBarcode').innerText = data.barcode;
                        document.getElementById('resDesc').innerText = data.description || '<fmt:message key="search_product.no_desc"/>';
                        document.getElementById('resPrice').innerText = '$' + data.price.toFixed(2);
                        
                        let stockEl = document.getElementById('resStock');
                        stockEl.innerText = data.stock + '<fmt:message key="search_product.units"/>';
                        stockEl.className = data.stock > 0 ? 'm-0 text-success' : 'm-0 text-danger';

                        let imgContainer = document.getElementById('resultImgContainer');
                        if (data.imageUrl) {
                            imgContainer.innerHTML = '<img src="' + data.imageUrl + '" class="result-img">';
                        } else {
                            imgContainer.innerHTML = `<div class="result-img bg-dark d-flex align-items-center justify-content-center text-secondary mx-auto"><i class="bi bi-tools fs-1"></i></div>`;
                        }

                        document.getElementById('resultCard').style.display = 'block';
                    }
                })
                .catch(err => {
                    document.getElementById('loadingIndicator').style.display = 'none';
                    document.getElementById('errorCard').style.display = 'block';
                });
        }

        // Handle Tab Switching to pause/resume camera
        document.getElementById('camera-tab').addEventListener('shown.bs.tab', function (e) {
            startScanner();
        });
        
        document.getElementById('manual-tab').addEventListener('shown.bs.tab', function (e) {
            if(html5QrcodeScanner) {
                html5QrcodeScanner.clear();
                html5QrcodeScanner = null;
            }
        });

        // Initialize scanner on load
        window.addEventListener('load', () => {
            startScanner();
        });

    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
