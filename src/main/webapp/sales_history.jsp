<%@ page import="com.adso.cheng.models.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 1) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial de Ventas - Asama Moto Parts</title>
    <link rel="icon" type="image/png" href="resources/logo-asama.png?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
    
    <link rel="stylesheet" href="resources/theme.css?v=6">
    <style>
        /* --- LEGIBILIDAD MEJORADA --- */
        .text-secondary, .text-muted { color: rgba(255, 255, 255, 0.75) !important; }
        body.light-mode .text-secondary, body.light-mode .text-muted { color: rgba(0, 0, 0, 0.65) !important; }

        .table { color: var(--text-color) !important; }
        .table th { font-weight: 700; letter-spacing: 0.5px; font-size: 0.85rem; border-bottom: 2px solid var(--card-border); }
        .table td { font-weight: 500; font-size: 0.95rem; border-bottom: 1px solid var(--card-border); vertical-align: middle; }
        .table tbody tr:hover { background: rgba(255, 255, 255, 0.05); }
        body.light-mode .table tbody tr:hover { background: rgba(0, 0, 0, 0.03); }
    </style>
</head>
<body>
<script src="resources/theme.js"></script>

<%@ include file="navbar.jsp" %>

<div class="container-fluid px-4 pb-5 mb-5" style="margin-top: 100px;">
    
    <div class="d-flex align-items-center mb-4">
        <h2 class="fw-bold mb-0 text-accent"><i class="bi bi-journal-text me-2"></i>Historial de Ventas</h2>
        <span class="badge bg-secondary bg-opacity-25 text-light ms-3 px-3 py-2 rounded-pill fs-6 fw-normal border border-secondary border-opacity-25">Ultimos 30 dias</span>
    </div>
    
    <div class="row g-4 align-items-stretch">
        <div class="col-lg-6">
            <div class="action-card h-100 d-flex flex-column p-4">
                <div class="border-bottom border-secondary pb-3 mb-3">
                    <h5 class="fw-bold mb-0 text-accent"><i class="bi bi-person-badge me-2"></i>Ventas por Cajero</h5>
                </div>
                <div class="table-responsive flex-grow-1 pe-2" style="max-height: 50vh; overflow-y: auto;">
                    <table class="table table-borderless align-middle mb-0">
                        <thead class="sticky-top" style="background: var(--card-bg);">
                            <tr>
                                <th class="text-secondary text-uppercase pb-2">Fecha</th>
                                <th class="text-secondary text-uppercase pb-2">Cajero</th>
                                <th class="text-secondary text-uppercase pb-2 text-center">Transacciones</th>
                                <th class="text-secondary text-uppercase pb-2 text-end">Ingresos</th>
                            </tr>
                        </thead>
                        <tbody id="cashierHistoryTable">
                            <tr><td colspan="4" class="text-center text-secondary py-5"><div class="spinner-border spinner-border-sm me-2"></div>Cargando datos...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <div class="col-lg-6">
            <div class="action-card h-100 d-flex flex-column p-4">
                <div class="border-bottom border-secondary pb-3 mb-3">
                    <h5 class="fw-bold mb-0 text-accent"><i class="bi bi-globe me-2"></i>Ventas Online</h5>
                </div>
                <div class="table-responsive flex-grow-1 pe-2" style="max-height: 50vh; overflow-y: auto;">
                    <table class="table table-borderless align-middle mb-0">
                        <thead class="sticky-top" style="background: var(--card-bg);">
                            <tr>
                                <th class="text-secondary text-uppercase pb-2">Fecha</th>
                                <th class="text-secondary text-uppercase pb-2 text-center">Transacciones</th>
                                <th class="text-secondary text-uppercase pb-2 text-end">Ingresos</th>
                            </tr>
                        </thead>
                        <tbody id="onlineHistoryTable">
                            <tr><td colspan="3" class="text-center text-secondary py-5"><div class="spinner-border spinner-border-sm me-2"></div>Cargando datos...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Nueva tabla: Ventas por Día -->
    <div class="row mt-4">
        <div class="col-12">
            <div class="action-card d-flex flex-column p-4">
                <div class="border-bottom border-secondary pb-3 mb-3 d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold mb-0 text-accent"><i class="bi bi-calendar-check me-2"></i>Ventas por Día</h5>
                </div>
                <div class="table-responsive flex-grow-1 pe-2" style="max-height: 50vh; overflow-y: auto;">
                    <table class="table table-borderless align-middle mb-0">
                        <thead class="sticky-top" style="background: var(--card-bg);">
                            <tr>
                                <th class="text-secondary text-uppercase pb-2">Fecha</th>
                                <th class="text-secondary text-uppercase pb-2 text-center">Transacciones Cajero</th>
                                <th class="text-secondary text-uppercase pb-2 text-end">Ingresos Cajero</th>
                                <th class="text-secondary text-uppercase pb-2 text-center">Transacciones Online</th>
                                <th class="text-secondary text-uppercase pb-2 text-end">Ingresos Online</th>
                                <th class="text-secondary text-uppercase pb-2 text-end text-accent">Total General</th>
                            </tr>
                        </thead>
                        <tbody id="dailySummaryTable">
                            <tr><td colspan="6" class="text-center text-secondary py-5"><div class="spinner-border spinner-border-sm me-2"></div>Cargando datos...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Reportes Diarios PDF (Estilo time_tracking) -->
    <div class="row mt-4">
        <div class="col-12">
            <div class="action-card p-4">
                <div class="border-bottom border-secondary pb-3 mb-4">
                    <h5 class="fw-bold mb-1 text-accent"><i class="bi bi-file-earmark-pdf me-2"></i>Reportes Diarios PDF</h5>
                    <p class="text-secondary small mb-0">Descarga el reporte detallado de ventas por día.</p>
                </div>
                <div id="historyDaysContainer" class="d-flex flex-wrap gap-3">
                    <div class="spinner-border spinner-border-sm text-secondary me-2"></div> <span class="text-secondary small fw-medium">Cargando reportes disponibles...</span>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    
    // Fetch Cashier History
    fetch('dashboardData?action=cashierHistory')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('cashierHistoryTable');
            tbody.innerHTML = '';
            
            if(data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-3"></i>No hay registros recientes.</td></tr>';
            } else {
                data.forEach(row => {
                    tbody.innerHTML += 
                        '<tr>' +
                            '<td class="text-muted small">' + row.date + '</td>' +
                            '<td class="fw-bold">' + row.cashier + '</td>' +
                            '<td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2">' + row.sales_count + '</span></td>' +
                            '<td class="text-end fw-bold text-accent fs-6">$' + row.revenue.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                        '</tr>';
                });
            }
        }).catch(err => {
            document.getElementById('cashierHistoryTable').innerHTML = '<tr><td colspan="4" class="text-center text-danger py-4">Error al cargar los datos.</td></tr>';
        });

    // Fetch Online History
    fetch('dashboardData?action=onlineHistory')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('onlineHistoryTable');
            tbody.innerHTML = '';
            
            if(data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="3" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-3"></i>No hay registros recientes.</td></tr>';
            } else {
                data.forEach(row => {
                    tbody.innerHTML += 
                        '<tr>' +
                            '<td class="text-muted small">' + row.date + '</td>' +
                            '<td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2">' + row.sales_count + '</span></td>' +
                            '<td class="text-end fw-bold text-accent fs-6">$' + row.revenue.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                        '</tr>';
                });
            }
        }).catch(err => {
            document.getElementById('onlineHistoryTable').innerHTML = '<tr><td colspan="3" class="text-center text-danger py-4">Error al cargar los datos.</td></tr>';
        });

    // Fetch Daily Summary
    fetch('dashboardData?action=dailySummary')
        .then(res => res.json())
        .then(data => {
            const tbody = document.getElementById('dailySummaryTable');
            const container = document.getElementById('historyDaysContainer');
            tbody.innerHTML = '';
            container.innerHTML = '';
            
            if(data.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-secondary py-5"><i class="bi bi-inbox fs-1 d-block mb-3"></i>No hay registros recientes.</td></tr>';
                container.innerHTML = '<span class="text-secondary small">No hay historial disponible.</span>';
            } else {
                data.forEach(row => {
                    tbody.innerHTML += 
                        '<tr>' +
                            '<td class="text-muted fw-bold">' + row.date + '</td>' +
                            '<td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2">' + row.cashier_count + '</span></td>' +
                            '<td class="text-end fw-semibold">$' + row.cashier_revenue.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                            '<td class="text-center"><span class="badge bg-secondary bg-opacity-25 text-light px-2">' + row.online_count + '</span></td>' +
                            '<td class="text-end fw-semibold">$' + row.online_revenue.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                            '<td class="text-end fw-bold text-accent fs-6">$' + row.total_revenue.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) + '</td>' +
                        '</tr>';
                    
                    const btn = document.createElement('button');
                    btn.className = 'btn btn-moto-outline rounded-pill px-4 fw-bold d-flex align-items-center gap-2';
                    btn.innerHTML = '<i class="bi bi-calendar-day"></i> ' + row.date + ' <i class="bi bi-filetype-pdf fs-5 ms-1 text-danger"></i>';
                    btn.onclick = () => downloadPdfForDate(row.date);
                    container.appendChild(btn);
                });
            }
        }).catch(err => {
            document.getElementById('dailySummaryTable').innerHTML = '<tr><td colspan="6" class="text-center text-danger py-4">Error al cargar los datos.</td></tr>';
            document.getElementById('historyDaysContainer').innerHTML = '<span class="text-danger small">Error al cargar historial.</span>';
        });
});

const getSwalBg = () => document.body.classList.contains('light-mode') ? '#ffffff' : '#1e1e24';
const getSwalColor = () => document.body.classList.contains('light-mode') ? '#333333' : '#f8f9fa';

function downloadPdfForDate(date) {
    Swal.fire({
        title: 'Generando PDF...',
        text: 'Obteniendo registros de ' + date,
        allowOutsideClick: false,
        didOpen: () => { Swal.showLoading(); },
        background: getSwalBg(),
        color: getSwalColor()
    });

    fetch('dashboardData?action=dailySalesDetails&date=' + date)
    .then(res => res.json())
    .then(data => {
        Swal.close();
        if(data.length === 0) {
            Swal.fire({
                icon: 'info',
                title: 'Sin registros',
                text: 'No hay transacciones para este día.',
                background: getSwalBg(),
                color: getSwalColor()
            });
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        doc.setFontSize(18);
        doc.text('Reporte de Ventas - ' + date, 14, 22);
        doc.setFontSize(11);
        doc.setTextColor(100);
        doc.text('Asama Moto Parts', 14, 30);

        let totalCashier = 0;
        let totalOnline = 0;

        const tableData = data.map(row => {
            let d = new Date(row.sale_date);
            let timeStr = d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
            let isOnline = row.sale_type === 'ONLINE' || !row.cashier_name;
            let displayType = isOnline ? 'Online' : 'Cajero';
            let cashier = isOnline ? '-' : row.cashier_name;
            
            if (isOnline) totalOnline += row.total_price;
            else totalCashier += row.total_price;

            return [
                timeStr,
                displayType,
                cashier,
                row.product_name,
                row.quantity,
                '$' + row.total_price.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2})
            ];
        });

        const pdfAccent = getComputedStyle(document.documentElement).getPropertyValue('--accent-orange').trim();
        let hexColor = [230, 81, 0]; // Naranja por defecto
        if(pdfAccent.startsWith('#')) {
            let c = pdfAccent.substring(1);
            if (c.length === 3) c = c.split('').map(x => x + x).join('');
            let rgb = parseInt(c, 16);
            hexColor = [(rgb >> 16) & 0xff, (rgb >>  8) & 0xff, (rgb >>  0) & 0xff];
        }

        doc.autoTable({
            startY: 40,
            head: [['Hora', 'Tipo', 'Cajero', 'Producto', 'Cant.', 'Total']],
            body: tableData,
            theme: 'striped',
            headStyles: { fillColor: hexColor },
            styles: { fontSize: 10 },
            columnStyles: {
                4: { halign: 'center' },
                5: { halign: 'right' }
            }
        });

        let finalY = doc.lastAutoTable.finalY || 40;
        doc.setFontSize(11);
        doc.setTextColor(0);
        doc.text('Total Cajero: $' + totalCashier.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}), 14, finalY + 10);
        doc.text('Total Online: $' + totalOnline.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}), 14, finalY + 16);
        doc.setFont(undefined, 'bold');
        doc.text('Total del Día: $' + (totalCashier + totalOnline).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}), 14, finalY + 24);

        doc.save('Reporte_Ventas_' + date + '.pdf');
    })
    .catch(err => {
        console.error(err);
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'No se pudo generar el reporte.',
            background: getSwalBg(),
            color: getSwalColor()
        });
    });
}
</script>
</body>
</html>