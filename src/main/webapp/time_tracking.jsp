<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Terminal de Asistencia - Asama Moto Parts</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <!-- Face API JS -->
    <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        :root { --bg-color: #0a0a0a; --accent-orange: #FF6B35; --card-bg: #1a1a1a; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-color); color: #fff; min-height: 100vh; display: flex; align-items: center; padding: 20px; }
        
        .main-container { width: 100%; max-width: 1200px; margin: 0 auto; }
        
        .terminal-card, .history-card { 
            background: var(--card-bg); border-radius: 20px; padding: 30px; 
            box-shadow: 0 20px 50px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); 
            height: 100%;
        }
        
        .terminal-card { text-align: center; }
        
        .nav-tabs { border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 25px; justify-content: center;}
        .nav-tabs .nav-link { color: #888; border: none; font-weight: 500; font-size: 1.05rem; padding: 10px 15px;}
        .nav-tabs .nav-link.active { color: var(--accent-orange); background: transparent; border-bottom: 2px solid var(--accent-orange); }
        
        #video-container { position: relative; width: 100%; max-width: 480px; margin: 0 auto; border-radius: 15px; overflow: hidden; border: 3px solid #2D3436; aspect-ratio: 4/3; background: #000; }
        video { width: 100%; height: 100%; object-fit: cover; display: block; transform: scaleX(-1); }
        canvas { position: absolute; top: 0; left: 0; transform: scaleX(-1); width: 100%; height: 100%; object-fit: cover; }
        
        .pulse-icon { font-size: 4rem; color: var(--accent-orange); animation: pulse 2s infinite; }
        @keyframes pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.1); opacity: 0.8; } 100% { transform: scale(1); opacity: 1; } }
        
        .form-control { background: #2D3436; border: 1px solid rgba(255,255,255,0.1); color: #fff; font-size: 1.2rem; text-align: center; padding: 12px; border-radius: 10px; }
        .form-control:focus { background: #2D3436; color: #fff; border-color: var(--accent-orange); box-shadow: 0 0 0 3px rgba(255,107,53,0.15); }
        
        .loading-overlay { position: absolute; top:0; left:0; right:0; bottom:0; background: rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center; flex-direction: column; z-index: 10;}
        
        .table-dark { background-color: transparent !important; }
        .table { color: #ccc; font-size: 0.9rem; }
        .table th, .table td { border-color: rgba(255,255,255,0.1); vertical-align: middle; }
        .badge-entrada { background: rgba(46,204,113,0.15); color: #2ecc71; border: 1px solid rgba(46,204,113,0.3); padding: 4px 10px; border-radius: 20px; font-size: 0.75rem;}
        .badge-salida { background: rgba(231,76,60,0.15); color: #e74c3c; border: 1px solid rgba(231,76,60,0.3); padding: 4px 10px; border-radius: 20px; font-size: 0.75rem;}
        
        .table-container { max-height: 400px; overflow-y: auto; }
        /* Custom scrollbar for table container */
        .table-container::-webkit-scrollbar { width: 6px; }
        .table-container::-webkit-scrollbar-track { background: rgba(0,0,0,0.1); }
        .table-container::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 10px; }
    </style>
    <link rel="stylesheet" href="resources/theme.css">
</head>
<body>
<script src="resources/theme.js"></script>

    <a href="index.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0 m-4" style="border-radius: 20px; z-index: 100;"><i class="bi bi-arrow-left"></i> Volver</a>
    <div class="position-absolute top-0 end-0 m-4" style="z-index: 100;">
        <button onclick="toggleTheme()" class="theme-toggle-btn" title="Cambiar tema">
            <i id="themeIcon" class="bi bi-sun-fill"></i>
        </button>
    </div>

    <div class="main-container">
        <div class="row g-4 align-items-stretch">
            
            <!-- Left Column: Scanner -->
            <div class="col-lg-6">
                <div class="terminal-card">
                    <h3 class="fw-bold mb-1">Terminal de Asistencia</h3>
                    <p class="text-secondary mb-4" id="clock" style="font-size: 0.9rem;"></p>

                    <ul class="nav nav-tabs" id="myTab" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="face-tab" data-bs-toggle="tab" data-bs-target="#face-pane" type="button" role="tab"><i class="bi bi-person-bounding-box me-1"></i> Facial</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="barcode-tab" data-bs-toggle="tab" data-bs-target="#barcode-pane" type="button" role="tab"><i class="bi bi-upc-scan me-1"></i> Carnet</button>
                        </li>
                    </ul>

                    <div class="tab-content">
                        <!-- Face Recognition Tab -->
                        <div class="tab-pane fade show active" id="face-pane" role="tabpanel">
                            <div id="video-container">
                                <video id="video" autoplay muted></video>
                                <div id="modelLoading" class="loading-overlay">
                                    <div class="spinner-border text-warning mb-2"></div>
                                    <span class="small text-warning" id="loadingText">Cargando modelos...</span>
                                </div>
                            </div>
                            <div class="mt-3 text-secondary small"><i class="bi bi-info-circle"></i> Mira a la cámara fijamente. Límite de detección: 5 segs.</div>
                        </div>

                        <!-- Barcode Tab -->
                        <div class="tab-pane fade" id="barcode-pane" role="tabpanel">
                            <div class="pulse-icon my-4"><i class="bi bi-upc-scan"></i></div>
                            <h5 class="mb-4">Escanea tu Carnet</h5>
                            <input type="text" id="manualInput" class="form-control" placeholder="Escribe tu ID..." autocomplete="off">
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right Column: Live History Table -->
            <div class="col-lg-6">
                <div class="history-card">
                    <h4 class="fw-bold mb-1" style="color:var(--accent-orange)"><i class="bi bi-clock-history me-2"></i>Asistencia de Hoy</h4>
                    <p class="text-secondary small mb-4">El historial en vivo del personal que ha ingresado el día de hoy.</p>
                    
                    <div class="table-container pe-2">
                        <table class="table table-hover align-middle" id="attendanceTable">
                            <thead>
                                <tr>
                                    <th>Empleado</th>
                                    <th>Estado</th>
                                    <th>Hora</th>
                                </tr>
                            </thead>
                            <tbody id="attendanceTbody">
                                <!-- Loaded dynamically via JS -->
                                <tr>
                                    <td colspan="3" class="text-center text-secondary py-4">
                                        <div class="spinner-border spinner-border-sm me-2"></div> Cargando historial...
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
        </div>
    </div>

    <script>
        // Set Light/Dark colors for SweetAlert
        const getSwalBg = () => document.body.classList.contains('light-mode') ? '#fff' : '#1a1a1a';
        const getSwalColor = () => document.body.classList.contains('light-mode') ? '#000' : '#fff';

        // Clock
        setInterval(() => {
            let now = new Date();
            document.getElementById('clock').innerText = now.toLocaleString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' });
        }, 1000);

        // Fetch Today's Attendance
        function loadAttendanceTable() {
            fetch('time-tracking?action=list')
            .then(res => res.json())
            .then(data => {
                const tbody = document.getElementById('attendanceTbody');
                tbody.innerHTML = '';
                
                if(data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="3" class="text-center text-secondary py-4">No hay asistencias registradas hoy.</td></tr>';
                    return;
                }
                
                data.forEach(row => {
                    const hasExit = row.exit && row.exit.trim() !== "";
                    const statusHtml = hasExit 
                        ? `<span class="badge-salida"><i class="bi bi-box-arrow-right"></i> Salida</span>`
                        : `<span class="badge-entrada"><i class="bi bi-box-arrow-in-right"></i> Entrada</span>`;
                    
                    // Format times
                    let timeDisplay = "";
                    if (row.entry) {
                        let d = new Date(row.entry);
                        timeDisplay += d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                    }
                    if (hasExit) {
                        let d2 = new Date(row.exit);
                        timeDisplay += " - " + d2.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                    }

                    const tr = document.createElement('tr');
                    tr.innerHTML = `
                        <td class="fw-medium">${row.name}</td>
                        <td>${statusHtml}</td>
                        <td class="text-secondary small"><i class="bi bi-clock me-1"></i>${timeDisplay}</td>
                    `;
                    tbody.appendChild(tr);
                });
            })
            .catch(err => console.error("Error loading table:", err));
        }

        // --- FACE RECOGNITION LOGIC ---
        const video = document.getElementById('video');
        let labeledFaceDescriptors = [];
        let faceMatcher = null;
        let isProcessing = false;
        
        let unknownFramesCount = 0; // for 5-second logic (approx 5 frames if interval is 1s)

        async function initFaceRecognition() {
            try {
                // 1. Load Models
                const MODEL_URL = 'https://justadudewhohacks.github.io/face-api.js/models';
                await Promise.all([
                    faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
                    faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
                    faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
                ]);

                document.getElementById('loadingText').innerText = "Cargando rostros autorizados...";

                // 2. Fetch Employee Data
                const response = await fetch('faceData');
                const employees = await response.json();
                
                let loadedCount = 0;

                // 3. Create Labeled Descriptors
                for (let emp of employees) {
                    try {
                        if (!emp.photoUrl) continue; // Skip if no photo
                        
                        // Append timestamp to bust cache so new photos load immediately
                        const img = await faceapi.fetchImage(emp.photoUrl + '?t=' + Date.now());
                        const detections = await faceapi.detectSingleFace(img, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks().withFaceDescriptor();
                        if (detections) {
                            labeledFaceDescriptors.push(new faceapi.LabeledFaceDescriptors(emp.barcode, [detections.descriptor]));
                            loadedCount++;
                        }
                    } catch(e) { console.warn("No se pudo cargar imagen para: " + emp.name); }
                }

                if(loadedCount === 0) {
                    document.getElementById('modelLoading').innerHTML = "<span class='text-danger text-center p-3'>No hay personal con foto registrada para escaneo facial.</span>";
                    return; // Stop trying to start camera if no models exist
                }

                faceMatcher = new faceapi.FaceMatcher(labeledFaceDescriptors, 0.55); // 0.55 is max distance
                document.getElementById('modelLoading').style.display = 'none';
                startVideo();

            } catch(e) {
                console.error("Face API Error:", e);
                document.getElementById('modelLoading').innerHTML = "<span class='text-danger'>Error cargando reconocimiento facial. Usa el Carnet.</span>";
            }
        }

        function startVideo() {
            navigator.mediaDevices.getUserMedia({ video: {} })
                .then(stream => video.srcObject = stream)
                .catch(err => {
                    document.getElementById('modelLoading').style.display = 'flex';
                    document.getElementById('modelLoading').innerHTML = "<span class='text-danger text-center p-3'>No se pudo acceder a la cámara.</span>";
                });
        }

        video.addEventListener('play', () => {
            const canvas = faceapi.createCanvasFromMedia(video);
            document.getElementById('video-container').append(canvas);
            
            // Adjust to container size, not intrinsic video size
            const updateCanvasSize = () => {
                const container = document.getElementById('video-container');
                const displaySize = { width: container.clientWidth, height: container.clientHeight };
                faceapi.matchDimensions(canvas, displaySize);
                return displaySize;
            };
            
            let displaySize = updateCanvasSize();
            window.addEventListener('resize', () => displaySize = updateCanvasSize());

            setInterval(async () => {
                if(isProcessing || !faceMatcher) return;

                const detections = await faceapi.detectAllFaces(video, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks().withFaceDescriptors();
                const resizedDetections = faceapi.resizeResults(detections, displaySize);
                
                canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
                faceapi.draw.drawDetections(canvas, resizedDetections);

                if (resizedDetections.length > 0) {
                    const bestMatch = faceMatcher.findBestMatch(resizedDetections[0].descriptor);
                    
                    if(bestMatch.label !== 'unknown' && bestMatch.distance < 0.55) {
                        unknownFramesCount = 0; // reset
                        isProcessing = true;
                        submitAttendance(bestMatch.label);
                    } else {
                        // Face detected but unknown
                        unknownFramesCount++;
                        if(unknownFramesCount >= 5) { // Approx 5 seconds
                            isProcessing = true;
                            unknownFramesCount = 0; // reset
                            
                            Swal.fire({
                                icon: 'warning',
                                title: 'Rostro no reconocido',
                                text: 'Si eres empleado, puede que no tengas una foto de perfil registrada para el escaneo.',
                                confirmButtonColor: '#FF6B35',
                                background: getSwalBg(),
                                color: getSwalColor(),
                                timer: 4000
                            }).then(() => {
                                isProcessing = false;
                            });
                        }
                    }
                } else {
                    unknownFramesCount = 0; // reset if no face detected
                }
            }, 1000);
        });

        // Initialize Face API and Table
        window.addEventListener('load', () => {
            loadAttendanceTable();
            initFaceRecognition();
        });

        // --- BARCODE SCANNER LOGIC ---
        let barcodeBuffer = "";
        let lastKeyTime = Date.now();

        document.addEventListener('keypress', function(e) {
            // Ignore if active element is input
            if(document.activeElement.tagName === 'INPUT') return;
            
            let currentTime = Date.now();
            if (currentTime - lastKeyTime > 200) { barcodeBuffer = ""; }
            
            if (e.key === 'Enter' && barcodeBuffer.length > 0) {
                if(!isProcessing) {
                    isProcessing = true;
                    submitAttendance(barcodeBuffer);
                }
                barcodeBuffer = "";
            } else {
                barcodeBuffer += e.key;
            }
            lastKeyTime = currentTime;
        });

        document.getElementById('manualInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                if(!isProcessing) {
                    isProcessing = true;
                    submitAttendance(this.value);
                }
                this.value = "";
            }
        });

        function submitAttendance(barcode) {
            fetch('time-tracking', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'barcode=' + encodeURIComponent(barcode)
            })
            .then(res => res.json())
            .then(data => {
                if(data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: data.type === 'Entrada' ? '¡Bienvenido!' : '¡Hasta pronto!',
                        html: `${data.type} registrada para:<br><strong>${data.name}</strong>`,
                        timer: 3500,
                        showConfirmButton: false,
                        background: getSwalBg(),
                        color: getSwalColor()
                    }).then(() => { isProcessing = false; });
                    
                    // Reload table
                    loadAttendanceTable();
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Oops...',
                        text: data.error || 'Error al registrar asistencia',
                        confirmButtonColor: '#FF6B35',
                        background: getSwalBg(),
                        color: getSwalColor()
                    }).then(() => { isProcessing = false; });
                }
            })
            .catch(err => {
                isProcessing = false;
            });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
