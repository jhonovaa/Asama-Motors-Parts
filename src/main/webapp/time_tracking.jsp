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
    
    <style>
        :root { --bg-color: #0a0a0a; --accent-orange: #FF6B35; --card-bg: #1a1a1a; }
        body { font-family: 'Inter', sans-serif; background: var(--bg-color); color: #fff; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .terminal-card { background: var(--card-bg); border-radius: 20px; padding: 40px; width: 100%; max-width: 600px; box-shadow: 0 20px 50px rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); text-align: center; }
        .nav-tabs { border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 30px; justify-content: center;}
        .nav-tabs .nav-link { color: #888; border: none; font-weight: 500; font-size: 1.1rem; }
        .nav-tabs .nav-link.active { color: var(--accent-orange); background: transparent; border-bottom: 2px solid var(--accent-orange); }
        
        #video-container { position: relative; width: 100%; max-width: 480px; margin: 0 auto; border-radius: 15px; overflow: hidden; border: 3px solid #2D3436; }
        video { width: 100%; height: auto; display: block; transform: scaleX(-1); }
        canvas { position: absolute; top: 0; left: 0; transform: scaleX(-1); }
        
        .pulse-icon { font-size: 4rem; color: var(--accent-orange); animation: pulse 2s infinite; }
        @keyframes pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.1); opacity: 0.8; } 100% { transform: scale(1); opacity: 1; } }
        
        .form-control { background: #2D3436; border: 1px solid rgba(255,255,255,0.1); color: #fff; font-size: 1.5rem; text-align: center; padding: 15px; border-radius: 10px; }
        .form-control:focus { background: #2D3436; color: #fff; border-color: var(--accent-orange); box-shadow: 0 0 0 3px rgba(255,107,53,0.15); }
        
        .status-msg { font-size: 1.2rem; font-weight: 600; padding: 15px; border-radius: 10px; margin-top: 20px; display: none; }
        .status-success { background: rgba(40,167,69,0.1); color: #28a745; border: 1px solid rgba(40,167,69,0.3); }
        .status-error { background: rgba(220,53,69,0.1); color: #dc3545; border: 1px solid rgba(220,53,69,0.3); }
        
        .loading-overlay { position: absolute; top:0; left:0; right:0; bottom:0; background: rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center; flex-direction: column; z-index: 10;}
    </style>
</head>
<body>

    <a href="index.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0 m-4" style="border-radius: 20px;"><i class="bi bi-arrow-left"></i> Volver</a>

    <div class="terminal-card">
        <h2 class="fw-bold mb-1">Terminal de Asistencia</h2>
        <p class="text-secondary mb-4" id="clock"></p>

        <ul class="nav nav-tabs" id="myTab" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="face-tab" data-bs-toggle="tab" data-bs-target="#face-pane" type="button" role="tab"><i class="bi bi-person-bounding-box me-1"></i> Reconocimiento Facial</button>
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
                        <span class="small text-warning">Cargando modelos e imágenes...</span>
                    </div>
                </div>
                <div class="mt-3 text-secondary small"><i class="bi bi-info-circle"></i> Mira a la cámara para registrar tu asistencia automáticamente.</div>
            </div>

            <!-- Barcode Tab -->
            <div class="tab-pane fade" id="barcode-pane" role="tabpanel">
                <div class="pulse-icon my-4"><i class="bi bi-upc-scan"></i></div>
                <h4 class="mb-4">Escanea tu Carnet</h4>
                <input type="text" id="manualInput" class="form-control" placeholder="Escribe el ID si no tienes scanner" autocomplete="off">
            </div>
        </div>

        <div id="statusBox" class="status-msg"></div>
    </div>

    <script>
        // Clock
        setInterval(() => {
            let now = new Date();
            document.getElementById('clock').innerText = now.toLocaleString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' });
        }, 1000);

        // --- FACE RECOGNITION LOGIC ---
        const video = document.getElementById('video');
        let labeledFaceDescriptors = [];
        let faceMatcher = null;
        let isProcessing = false;
        let scannerTimeout = null;

        async function initFaceRecognition() {
            try {
                // 1. Load Models from standard CDN url
                const MODEL_URL = 'https://justadudewhohacks.github.io/face-api.js/models';
                await Promise.all([
                    faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
                    faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
                    faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
                ]);

                // 2. Fetch Employee Data
                const response = await fetch('faceData');
                const employees = await response.json();

                // 3. Create Labeled Descriptors
                for (let emp of employees) {
                    try {
                        const img = await faceapi.fetchImage(emp.photoUrl);
                        const detections = await faceapi.detectSingleFace(img, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks().withFaceDescriptor();
                        if (detections) {
                            // Store barcode as the label so we can send it to the server
                            labeledFaceDescriptors.push(new faceapi.LabeledFaceDescriptors(emp.barcode, [detections.descriptor]));
                        }
                    } catch(e) { console.error("Error loading image for " + emp.name, e); }
                }

                if(labeledFaceDescriptors.length > 0) {
                    faceMatcher = new faceapi.FaceMatcher(labeledFaceDescriptors, 0.6); // 0.6 is max distance
                }
                
                document.getElementById('modelLoading').style.display = 'none';
                startVideo();

            } catch(e) {
                console.error("Face API Error:", e);
                document.getElementById('modelLoading').innerHTML = "<span class='text-danger'>Error cargando reconocimiento facial. Usa el código de barras.</span>";
            }
        }

        function startVideo() {
            navigator.mediaDevices.getUserMedia({ video: {} })
                .then(stream => video.srcObject = stream)
                .catch(err => console.error(err));
        }

        video.addEventListener('play', () => {
            const canvas = faceapi.createCanvasFromMedia(video);
            document.getElementById('video-container').append(canvas);
            const displaySize = { width: video.clientWidth, height: video.clientHeight };
            faceapi.matchDimensions(canvas, displaySize);

            setInterval(async () => {
                if(isProcessing || !faceMatcher) return;

                const detections = await faceapi.detectAllFaces(video, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks().withFaceDescriptors();
                const resizedDetections = faceapi.resizeResults(detections, displaySize);
                
                canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
                faceapi.draw.drawDetections(canvas, resizedDetections);

                if (resizedDetections.length > 0) {
                    const bestMatch = faceMatcher.findBestMatch(resizedDetections[0].descriptor);
                    
                    if(bestMatch.label !== 'unknown' && bestMatch.distance < 0.55) {
                        isProcessing = true;
                        submitAttendance(bestMatch.label);
                    }
                }
            }, 1000);
        });

        // Initialize Face API on load
        window.addEventListener('load', initFaceRecognition);


        // --- BARCODE SCANNER LOGIC ---
        let barcodeBuffer = "";
        let lastKeyTime = Date.now();

        document.addEventListener('keypress', function(e) {
            // Ignore if active element is input
            if(document.activeElement.tagName === 'INPUT') return;
            
            let currentTime = Date.now();
            if (currentTime - lastKeyTime > 200) { barcodeBuffer = ""; }
            
            if (e.key === 'Enter' && barcodeBuffer.length > 0) {
                if(!isProcessing) submitAttendance(barcodeBuffer);
                barcodeBuffer = "";
            } else {
                barcodeBuffer += e.key;
            }
            lastKeyTime = currentTime;
        });

        document.getElementById('manualInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                if(!isProcessing) submitAttendance(this.value);
                this.value = "";
            }
        });

        function submitAttendance(barcode) {
            isProcessing = true;
            fetch('time-tracking', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'barcode=' + encodeURIComponent(barcode)
            })
            .then(res => res.json())
            .then(data => {
                let box = document.getElementById('statusBox');
                box.style.display = 'block';
                if(data.success) {
                    box.className = 'status-msg status-success';
                    box.innerHTML = `<i class="bi bi-check-circle me-2"></i> ${data.type} registrada para: <strong>${data.name}</strong>`;
                } else {
                    box.className = 'status-msg status-error';
                    box.innerHTML = `<i class="bi bi-x-circle me-2"></i> ${data.error || 'Error al registrar asistencia'}`;
                }
                
                // Reset after 4 seconds
                clearTimeout(scannerTimeout);
                scannerTimeout = setTimeout(() => {
                    box.style.display = 'none';
                    isProcessing = false;
                }, 4000);
            })
            .catch(err => { isProcessing = false; });
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
