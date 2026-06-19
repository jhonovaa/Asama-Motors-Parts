<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><fmt:message key="time_tracking.title" /></title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
    
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- LEGIBILIDAD EXTREMA Y ESTILOS KIOSCO --- */
        .text-secondary, .text-muted { color: rgba(255, 255, 255, 0.75) !important; }
        body.light-mode .text-secondary, body.light-mode .text-muted { color: rgba(0, 0, 0, 0.65) !important; }

        /* Contenedor de Video */
        .video-wrapper {
            position: relative;
            width: 100%;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid var(--accent-orange);
            background: #000;
            aspect-ratio: 4/3;
            box-shadow: 0 8px 25px rgba(0,0,0,0.3);
        }
        .video-wrapper video {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transform: scaleX(-1);
        }
        .loading-overlay {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.7);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 10;
        }

        /* Pestanas Customizadas */
        .custom-tabs {
            border-bottom: 1px solid var(--card-border);
            margin-bottom: 20px;
        }
        .custom-tabs .nav-link {
            color: var(--text-color);
            opacity: 0.6;
            border: none;
            border-bottom: 2px solid transparent;
            border-radius: 0;
            padding: 12px 20px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .custom-tabs .nav-link:hover { opacity: 0.8; }
        .custom-tabs .nav-link.active {
            color: var(--accent-orange);
            opacity: 1;
            border-bottom: 2px solid var(--accent-orange);
            background: transparent;
            text-shadow: 0 0 10px var(--accent-glow);
        }

        /* Formularios consistentes */
        .form-control {
            background-color: rgba(255, 255, 255, 0.05) !important;
            color: #ffffff !important;
            border: 1px solid rgba(255, 255, 255, 0.15) !important;
            font-weight: 600;
            letter-spacing: 1px;
            text-align: center;
        }
        .form-control::placeholder { color: rgba(255, 255, 255, 0.3) !important; }
        .form-control:focus {
            background-color: rgba(255, 255, 255, 0.08) !important;
            border-color: var(--accent-orange) !important;
            box-shadow: 0 0 0 0.25rem var(--accent-glow) !important;
        }
        body.light-mode .form-control {
            background-color: #ffffff !important;
            color: #212529 !important;
            border-color: rgba(0, 0, 0, 0.15) !important;
        }
        body.light-mode .form-control::placeholder { color: rgba(0, 0, 0, 0.3) !important; }

        /* Badges de Asistencia */
        .badge-entrada { background: rgba(46, 204, 113, 0.15); color: #2ECC71; border: 1px solid rgba(46, 204, 113, 0.3); padding: 5px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }
        .badge-salida { background: rgba(231, 76, 60, 0.15); color: #E74C3C; border: 1px solid rgba(231, 76, 60, 0.3); padding: 5px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }

        /* Icono Pulso Carnet */
        @keyframes pulseAnim {
            0% { transform: scale(1); box-shadow: 0 0 0 0 var(--accent-glow); }
            70% { transform: scale(1.05); box-shadow: 0 0 0 20px rgba(0,0,0,0); }
            100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(0,0,0,0); }
        }
        .pulse-icon-wrapper {
            font-size: 4rem;
            color: var(--accent-orange);
            animation: pulseAnim 2s infinite;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(128,128,128,0.1);
            border-radius: 50%;
            width: 120px;
            height: 120px;
            margin: 0 auto;
        }

        /* Tabla de Asistencia */
        .history-table th { font-weight: 700; border-bottom: 2px solid var(--card-border); color: var(--text-color); }
        .history-table td { border-bottom: 1px solid var(--card-border); color: var(--text-color); }
    </style>
</head>
<body>
<script src="resources/theme.js?v=2"></script>

    <div class="d-flex justify-content-between align-items-center w-100 p-4 position-absolute top-0 start-0" style="z-index: 100;">
        <a href="dashboard.jsp" class="btn btn-moto-outline rounded-pill px-4 fw-bold shadow-sm d-flex align-items-center gap-2 transition-all">
            <i class="bi bi-arrow-left"></i> <fmt:message key="time_tracking.back_dashboard" />
        </a>
        <button onclick="toggleTheme()" class="btn btn-icon theme-toggle-btn rounded-circle transition-all shadow-sm" title="<fmt:message key='time_tracking.theme_toggle' />">
            <i id="themeIcon" class="bi bi-sun-fill fs-5"></i>
        </button>
    </div>

    <div class="container-fluid px-4 pb-5" style="margin-top: 100px;">
        <div class="row g-4 align-items-stretch">
            
            <div class="col-lg-5 col-xl-4">
                <div class="action-card h-100 p-4 p-xl-5 d-flex flex-column text-center">
                    <h3 class="fw-bold mb-1 text-accent"><fmt:message key="time_tracking.heading" /></h3>
                    <p class="text-secondary fw-medium mb-4" id="clock" style="font-size: 1rem;"></p>

                    <ul class="nav nav-tabs custom-tabs justify-content-center w-100" id="myTab" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="face-tab" data-bs-toggle="tab" data-bs-target="#face-pane" type="button" role="tab">
                                <i class="bi bi-person-bounding-box me-1"></i> <fmt:message key="time_tracking.tab_facial" />
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="barcode-tab" data-bs-toggle="tab" data-bs-target="#barcode-pane" type="button" role="tab">
                                <i class="bi bi-upc-scan me-1"></i> <fmt:message key="time_tracking.tab_card" />
                            </button>
                        </li>
                    </ul>

                    <div class="tab-content flex-grow-1 d-flex flex-column justify-content-center w-100">
                        <div class="tab-pane fade show active w-100" id="face-pane" role="tabpanel">
                            <div id="video-container" class="video-wrapper mb-4">
                                <video id="video" autoplay muted playsinline></video>
                                <div id="modelLoading" class="loading-overlay">
                                    <div class="spinner-border text-warning mb-3" style="width: 3rem; height: 3rem;"></div>
                                    <span class="fw-bold text-warning" id="loadingText"><fmt:message key="time_tracking.loading_models" /></span>
                                </div>
                            </div>
                            <p class="text-secondary small fw-medium mb-0">
                                <i class="bi bi-info-circle me-1"></i> <fmt:message key="time_tracking.camera_instruction" />
                            </p>
                        </div>

                        <div class="tab-pane fade w-100" id="barcode-pane" role="tabpanel">
                            <div class="pulse-icon-wrapper my-5">
                                <i class="bi bi-upc-scan"></i>
                            </div>
                            <h5 class="fw-bold mb-4"><fmt:message key="time_tracking.scan_card" /></h5>
                            <input type="text" id="manualInput" class="form-control form-control-lg" placeholder="<fmt:message key='time_tracking.id_placeholder' />" autocomplete="off">
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-7 col-xl-8 d-flex flex-column gap-4">
                <div class="action-card flex-grow-1 p-4 p-xl-5 d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center border-bottom border-secondary pb-3 mb-4">
                        <div>
                            <h4 class="fw-bold mb-1 text-accent"><i class="bi bi-clock-history me-2"></i><fmt:message key="time_tracking.today_attendance" /></h4>
                            <p class="text-secondary small mb-0"><fmt:message key="time_tracking.live_history" /></p>
                        </div>
                        <button class="btn btn-sm btn-outline-secondary rounded-pill px-3" onclick="loadAttendanceTable()"><i class="bi bi-arrow-clockwise"></i></button>
                    </div>
                    
                    <div class="table-responsive flex-grow-1" style="max-height: 50vh; overflow-y: auto;">
                        <table class="table table-hover table-borderless history-table align-middle" id="attendanceTable">
                            <thead class="sticky-top" style="background: var(--card-bg);">
                                <tr>
                                    <th class="text-uppercase small pb-3"><fmt:message key="time_tracking.col_employee" /></th>
                                    <th class="text-uppercase small pb-3 text-center"><fmt:message key="time_tracking.col_status" /></th>
                                    <th class="text-uppercase small pb-3 text-end"><fmt:message key="time_tracking.col_time" /></th>
                                </tr>
                            </thead>
                            <tbody id="attendanceTbody">
                                <tr>
                                    <td colspan="3" class="text-center text-secondary py-5">
                                        <div class="spinner-border spinner-border-sm me-2"></div> <fmt:message key="time_tracking.loading_history" />
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div class="action-card p-4">
                    <div class="border-bottom border-secondary pb-3 mb-4">
                        <h5 class="fw-bold mb-1 text-accent"><i class="bi bi-calendar-check me-2"></i><fmt:message key="time_tracking.daily_reports" /></h5>
                        <p class="text-secondary small mb-0"><fmt:message key="time_tracking.download_reports" /></p>
                    </div>
                    <div id="historyDaysContainer" class="d-flex flex-wrap gap-3">
                        <div class="spinner-border spinner-border-sm text-secondary me-2"></div> <span class="text-secondary small fw-medium"><fmt:message key="time_tracking.loading_reports" /></span>
                    </div>
                </div>
            </div>
            
        </div>
    </div>

    <script>
        // Set Light/Dark colors for SweetAlert
        const getSwalBg = () => document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24';
        const getSwalColor = () => document.body.classList.contains('light-mode') ? '#333333' : '#f8f9fa';

        // Reloj en vivo
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
                    tbody.innerHTML = '<tr><td colspan="3" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-3"></i><fmt:message key="time_tracking.no_attendance" /></td></tr>';
                    return;
                }
                
                data.forEach(row => {
                    const hasExit = row.exit && row.exit.trim() !== "";
                    const statusHtml = hasExit 
                        ? '<span class="badge-salida"><i class="bi bi-box-arrow-right me-1"></i> <fmt:message key="time_tracking.exit" /></span>'
                        : '<span class="badge-entrada"><i class="bi bi-box-arrow-in-right me-1"></i> <fmt:message key="time_tracking.entry" /></span>';
                    
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
                    tr.innerHTML = 
                        '<td class="fw-bold fs-6">' + row.name + '</td>' +
                        '<td class="text-center">' + statusHtml + '</td>' +
                        '<td class="text-end text-secondary fw-medium"><i class="bi bi-clock me-1"></i>' + timeDisplay + '</td>';
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
        
        let unknownFramesCount = 0; 
        
        let detectionInterval = null;
        let currentCanvas = null;
        let isFaceTabActive = true;

        async function initFaceRecognition() {
            try {
                const MODEL_URL = 'https://justadudewhohacks.github.io/face-api.js/models';
                await Promise.all([
                    faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
                    faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
                    faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
                ]);

                document.getElementById('loadingText').innerText = "<fmt:message key='time_tracking.loading_faces'/>";

                const response = await fetch('faceData');
                const employees = await response.json();
                
                let loadedCount = 0;

                for (let emp of employees) {
                    try {
                        if (!emp.photoUrl) continue; 
                        
                        const img = await faceapi.fetchImage(emp.photoUrl + '?t=' + Date.now());
                        const detections = await faceapi.detectSingleFace(img, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks().withFaceDescriptor();
                        if (detections) {
                            labeledFaceDescriptors.push(new faceapi.LabeledFaceDescriptors(emp.barcode, [detections.descriptor]));
                            loadedCount++;
                        }
                    } catch(e) { console.warn("No se pudo cargar imagen para: " + emp.name); }
                }

                if(loadedCount === 0) {
                    document.getElementById('modelLoading').innerHTML = "<span class='text-danger fw-bold text-center p-3'><i class='bi bi-exclamation-triangle d-block fs-1 mb-2'></i><fmt:message key='time_tracking.no_photos'/></span>";
                    return; 
                }

                faceMatcher = new faceapi.FaceMatcher(labeledFaceDescriptors, 0.55);
                document.getElementById('modelLoading').style.display = 'none';
                
                if(isFaceTabActive) {
                    startVideo();
                }

            } catch(e) {
                console.error("Face API Error:", e);
                document.getElementById('modelLoading').innerHTML = "<span class='text-danger fw-bold text-center p-3'><i class='bi bi-camera-video-off d-block fs-1 mb-2'></i><fmt:message key='time_tracking.facial_error'/></span>";
            }
        }

        function startVideo() {
            navigator.mediaDevices.getUserMedia({ video: {} })
                .then(stream => {
                    video.srcObject = stream;
                    document.getElementById('modelLoading').style.display = 'none';
                })
                .catch(err => {
                    document.getElementById('modelLoading').style.display = 'flex';
                    document.getElementById('modelLoading').innerHTML = "<span class='text-danger fw-bold text-center p-3'><i class='bi bi-camera-video-off d-block fs-1 mb-2'></i><fmt:message key='time_tracking.camera_error'/></span>";
                });
        }

        function stopVideo() {
            if (video.srcObject) {
                video.srcObject.getTracks().forEach(track => track.stop());
                video.srcObject = null;
            }
            if (detectionInterval) {
                clearInterval(detectionInterval);
                detectionInterval = null;
            }
            if (currentCanvas) {
                currentCanvas.remove();
                currentCanvas = null;
            }
        }

        video.addEventListener('play', () => {
            if (currentCanvas) currentCanvas.remove();
            currentCanvas = faceapi.createCanvasFromMedia(video);
            document.getElementById('video-container').append(currentCanvas);
            
            const updateCanvasSize = () => {
                const container = document.getElementById('video-container');
                const displaySize = { width: container.clientWidth, height: container.clientHeight };
                faceapi.matchDimensions(currentCanvas, displaySize);
                return displaySize;
            };
            
            let displaySize = updateCanvasSize();
            window.addEventListener('resize', () => {
                if(currentCanvas) displaySize = updateCanvasSize();
            });

            if (detectionInterval) clearInterval(detectionInterval);
            detectionInterval = setInterval(async () => {
                if(isProcessing || !faceMatcher || !isFaceTabActive) return;

                const detections = await faceapi.detectAllFaces(video, new faceapi.TinyFaceDetectorOptions()).withFaceLandmarks().withFaceDescriptors();
                const resizedDetections = faceapi.resizeResults(detections, displaySize);
                
                currentCanvas.getContext('2d').clearRect(0, 0, currentCanvas.width, currentCanvas.height);
                faceapi.draw.drawDetections(currentCanvas, resizedDetections);

                if (resizedDetections.length > 0) {
                    const bestMatch = faceMatcher.findBestMatch(resizedDetections[0].descriptor);
                    
                    if(bestMatch.label !== 'unknown' && bestMatch.distance < 0.55) {
                        unknownFramesCount = 0; 
                        isProcessing = true;
                        submitAttendance(bestMatch.label);
                    } else {
                        unknownFramesCount++;
                        if(unknownFramesCount >= 5) { 
                            isProcessing = true;
                            unknownFramesCount = 0; 
                            
                            Swal.fire({
                                icon: 'warning',
                                title: '<fmt:message key="time_tracking.unrecognized_face"/>',
                                text: '<fmt:message key="time_tracking.unrecognized_desc"/>',
                                confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#00E5FF',
                                background: getSwalBg(),
                                color: getSwalColor(),
                                timer: 4000
                            }).then(() => {
                                isProcessing = false;
                            });
                        }
                    }
                } else {
                    unknownFramesCount = 0; 
                }
            }, 1000);
        });

        // Cambio de pestanas
        document.getElementById('face-tab').addEventListener('shown.bs.tab', function () {
            isFaceTabActive = true;
            if (faceMatcher) {
                startVideo();
            }
        });

        document.getElementById('barcode-tab').addEventListener('shown.bs.tab', function () {
            isFaceTabActive = false;
            stopVideo();
        });

        // Inicializacion
        window.addEventListener('load', () => {
            loadAttendanceTable();
            loadHistoryDates();
            initFaceRecognition();
        });

        // --- HISTORY PDF LOGIC ---
        function loadHistoryDates() {
            fetch('time-tracking?action=history_dates')
            .then(res => res.json())
            .then(dates => {
                const container = document.getElementById('historyDaysContainer');
                container.innerHTML = '';
                if(dates.length === 0) {
                    container.innerHTML = '<span class="text-secondary small"><fmt:message key="time_tracking.no_history"/></span>';
                    return;
                }
                dates.forEach(date => {
                    const btn = document.createElement('button');
                    btn.className = 'btn btn-moto-outline rounded-pill px-4 fw-bold d-flex align-items-center gap-2';
                    btn.innerHTML = '<i class="bi bi-calendar-day"></i> ' + date + ' <i class="bi bi-filetype-pdf fs-5 ms-1 text-danger"></i>';
                    btn.onclick = () => downloadPdfForDate(date);
                    container.appendChild(btn);
                });
            })
            .catch(err => {
                document.getElementById('historyDaysContainer').innerHTML = '<span class="text-danger small"><fmt:message key="time_tracking.history_error"/></span>';
                console.error("Error loading dates:", err);
            });
        }

        function downloadPdfForDate(date) {
            Swal.fire({
                title: '<fmt:message key="time_tracking.generating_pdf"/>',
                text: '<fmt:message key="time_tracking.getting_records"/> ' + date,
                allowOutsideClick: false,
                didOpen: () => { Swal.showLoading(); },
                background: getSwalBg(),
                color: getSwalColor()
            });

            fetch('time-tracking?action=history_by_date&date=' + date)
            .then(res => res.json())
            .then(data => {
                Swal.close();
                if(data.length === 0) {
                    Swal.fire({
                        icon: 'info',
                        title: '<fmt:message key="time_tracking.no_records"/>',
                        text: '<fmt:message key="time_tracking.no_complete_attendance"/>',
                        background: getSwalBg(),
                        color: getSwalColor()
                    });
                    return;
                }

                const { jsPDF } = window.jspdf;
                const doc = new jsPDF();

                doc.setFontSize(18);
                doc.text('<fmt:message key="time_tracking.attendance_report"/> ' + date, 14, 22);
                doc.setFontSize(11);
                doc.setTextColor(100);
                doc.text('Asama Moto Parts', 14, 30);

                const tableData = data.map(row => {
                    let dIn = new Date(row.entry);
                    let timeIn = dIn.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                    let dOut = new Date(row.exit);
                    let timeOut = dOut.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                    return [row.name, timeIn, timeOut];
                });

                // Extraemos el color naranja de la paleta actual para el PDF
                const pdfAccent = getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim();
                let hexColor = [0, 229, 255]; // Fallback Azul Electrico
                if(pdfAccent.startsWith('#')) {
                    let c = pdfAccent.substring(1);      // strip #
                    let rgb = parseInt(c, 16);   // convert rrggbb to decimal
                    hexColor = [(rgb >> 16) & 0xff, (rgb >>  8) & 0xff, (rgb >>  0) & 0xff];
                }

                doc.autoTable({
                    startY: 40,
                    head: [['<fmt:message key="time_tracking.pdf_employee"/>', '<fmt:message key="time_tracking.pdf_entry_time"/>', '<fmt:message key="time_tracking.pdf_exit_time"/>']],
                    body: tableData,
                    theme: 'striped',
                    headStyles: { fillColor: hexColor },
                    styles: { fontSize: 10 }
                });

                doc.save('Asistencia_' + date + '.pdf');
            })
            .catch(err => {
                console.error(err);
                Swal.fire({
                    icon: 'error',
                    title: '<fmt:message key="time_tracking.error"/>',
                    text: '<fmt:message key="time_tracking.report_error"/>',
                    background: getSwalBg(),
                    color: getSwalColor()
                });
            });
        }

        // --- BARCODE SCANNER LOGIC ---
        let barcodeBuffer = "";
        let lastKeyTime = Date.now();

        document.addEventListener('keypress', function(e) {
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
                        title: data.type === 'Entrada' ? '<fmt:message key="time_tracking.welcome"/>' : '<fmt:message key="time_tracking.see_you"/>',
                        html: data.type + ' <fmt:message key="time_tracking.registered_for"/><br><strong class="fs-4 mt-2 d-block">' + data.name + '</strong>',
                        timer: 3500,
                        showConfirmButton: false,
                        background: getSwalBg(),
                        color: getSwalColor()
                    }).then(() => { isProcessing = false; });
                    
                    loadAttendanceTable();
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: '<fmt:message key="time_tracking.oops"/>',
                        text: data.error || '<fmt:message key="time_tracking.error_registering"/>',
                        confirmButtonColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim() || '#00E5FF',
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
