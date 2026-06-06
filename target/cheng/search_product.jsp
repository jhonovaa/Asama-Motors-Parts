<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Buscar Repuesto - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Load html5-qrcode for barcode scanning -->
    <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>

</head>
<body>

    <%@ include file="navbar.jsp" %>

    <div class="container main-container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold m-0"><i class="bi bi-search text-orange me-2"></i> Buscar Repuesto</h2>
        </div>

        <div class="card-custom">
            <ul class="nav nav-tabs" id="searchTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="camera-tab" data-bs-toggle="tab" data-bs-target="#camera-pane" type="button" role="tab"><i class="bi bi-camera me-1"></i> Cámara</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="manual-tab" data-bs-toggle="tab" data-bs-target="#manual-pane" type="button" role="tab"><i class="bi bi-keyboard me-1"></i> Código Manual</button>
                </li>
            </ul>

            <div class="tab-content" id="searchTabsContent">
                <!-- Camera Tab -->
                <div class="tab-pane fade show active" id="camera-pane" role="tabpanel">
                    <div class="text-center mb-3 text-secondary small">Apunta la cámara al código de barras del producto</div>
                    <div id="reader"></div>
                </div>

                <!-- Manual Tab -->
                <div class="tab-pane fade" id="manual-pane" role="tabpanel">
                    <div class="mb-3">
                        <label class="form-label text-secondary">Ingresa el código de barras</label>
                        <input type="text" id="manualBarcode" class="form-control" placeholder="Ej. ASAMA-1001">
                    </div>
                    <button class="btn btn-moto" onclick="searchManual()">Buscar Repuesto</button>
                </div>
            </div>

            <!-- Result Section -->
            <div id="loadingIndicator" class="text-center my-4" style="display: none;">
                <div class="spinner-border text-orange" role="status"></div>
                <div class="mt-2 text-secondary small">Buscando...</div>
            </div>

            <div id="resultCard" class="result-card">
                <div class="row align-items-center">
                    <div class="col-md-4 text-center mb-3 mb-md-0" id="resultImgContainer">
                        <!-- Image rendered here -->
                    </div>
                    <div class="col-md-8">
                        <h4 id="resName" class="fw-bold mb-1"></h4>
                        <div class="text-secondary small mb-2"><i class="bi bi-tag-fill me-1"></i> <span id="resBrand"></span> | Código: <span id="resBarcode"></span></div>
                        <p id="resDesc" class="text-light small mb-3"></p>
                        
                        <div class="d-flex justify-content-between align-items-end mt-3 border-top border-secondary pt-3">
                            <div>
                                <div class="text-secondary small">Precio Unitario</div>
                                <h3 class="text-orange fw-bold m-0" id="resPrice"></h3>
                            </div>
                            <div class="text-end">
                                <div class="text-secondary small">Inventario</div>
                                <h5 class="m-0" id="resStock"></h5>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div id="errorCard" class="alert alert-danger mt-4" style="display:none;">
                <i class="bi bi-exclamation-triangle me-2"></i> No se encontró ningún repuesto con ese código.
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
                        document.getElementById('resBrand').innerText = data.brand || 'Genérico';
                        document.getElementById('resBarcode').innerText = data.barcode;
                        document.getElementById('resDesc').innerText = data.description || 'Sin descripción';
                        document.getElementById('resPrice').innerText = '$' + data.price.toFixed(2);
                        
                        let stockEl = document.getElementById('resStock');
                        stockEl.innerText = data.stock + ' uds';
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
