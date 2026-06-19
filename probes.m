%%%%%% ANÁLISIS DE PRESIÓN EN PROBES – POSTPROCESADO AEROACÚSTICO %%%%%%
% Script universal para el post-procesado de sondas puntuales.
% Basado en la extracción de datos de PyFR para análisis espectral y de fase.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;

%% 1. CONFIGURACIÓN Y LOCALIZACIÓN DE SONDAS
% ----------------------------------------------------------------------
% Coordenadas exactas de las sondas para la identificación en el CSV
probes_xy = [
    0.0   0.0;   % S1: Salida canal
    2.0   0.0;   % S2: Eje chorro
    3.9  -0.6;   % S3: Referencia (capa de cizalla)
    9.0   5.0;   % S4: Campo lejano superior
    9.0  -5.0    % S5: Campo lejano inferior
];

labels = {'S1','S2','S3','S4','S5'};
tol = 1e-6; % Tolerancia para búsqueda de coordenadas

%% 2. LECTURA Y PREPARACIÓN DE DATOS
% ----------------------------------------------------------------------
% --- Sustituir 'X' por el caso correspondiente ---
filename = 'caso_X_probes.csv';
data = readtable(filename); 

xref = 3.9; yref = -0.6; % Sonda S3 seleccionada como referencia
idx = abs(data.x - xref) < tol & abs(data.y - yref) < tol;
probe = sortrows(data(idx,:), 't'); 

t = probe.t;
p = probe.p;

%% 3. ANÁLISIS TEMPORAL Y SEÑAL FLUCTUANTE
% ----------------------------------------------------------------------
tmin = 400; tmax = 1000; 
idx_stat = t >= tmin & t <= tmax;
t_sel = t(idx_stat);
p_sel = p(idx_stat);

p_fluc = p_sel - mean(p_sel); 

% Figura 1: Historia temporal completa de la presión
figure(1); plot(t, p, 'k'); grid on; xlabel('t'); ylabel('p');

% Figura 2: Señal de presión en el régimen estacionario
figure(2); plot(t_sel, p_sel, 'k'); grid on; xlabel('t'); ylabel('p');

% Figura 3: Señal de presión fluctuante (eliminación de la componente DC)
figure(3); plot(t_sel, p_fluc, 'k'); grid on; xlabel('t'); ylabel('p''');

%% 4. ANÁLISIS ESPECTRAL (FFT)
% ----------------------------------------------------------------------
dt = mean(diff(t_sel));
fs = 1/dt;
N = length(p_fluc);
Y = fft(p_fluc);
P2 = abs(Y/N);
P1 = P2(1:floor(N/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:floor(N/2))/N;

% Búsqueda automática del tono fundamental en el rango de interés
f_min = 0.01; f_max = 0.08;
rango_indices = find(f > f_min & f < f_max);
[max_val, id_relativo] = max(P1(rango_indices));
f_tono = f(rango_indices(id_relativo));

fprintf('Archivo analizado: %s\n', filename);
fprintf('Frecuencia del tono detectada f_0 = %.4f\n', f_tono);

% Figura 4: Espectro de frecuencia de la presión en la sonda de referencia
figure(4)
plot(f, P1, 'k', 'LineWidth', 1.3); hold on;
plot(f_tono, max_val, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k'); 
text(f_tono * 1.05, max_val, sprintf(' f_0 = %.4f', f_tono), ...
    'FontWeight', 'bold', 'FontSize', 10, 'VerticalAlignment', 'bottom');
xline(f_tono, 'r--', 'LineWidth', 1.2);
xlim([0 0.2]); xlabel('f'); ylabel('|P(f)|'); grid on;

%% 5. COMPARATIVA Y CORRELACIÓN
% ----------------------------------------------------------------------
% Figura 5: Comparativa de espectros normalizados entre todas las sondas
figure(5); hold on; grid on;
leg = {};
for i = 1:5
    xi = probes_xy(i,1); yi = probes_xy(i,2);
    idx = abs(data.x - xi) < tol & abs(data.y - yi) < tol;
    pr = sortrows(data(idx,:), 't');
    t_i = pr.t; p_i = pr.p;
    idx_i = t_i >= tmin & t_i <= tmax;
    if sum(idx_i) < 500, continue, end
    
    p_i_fluc = p_i(idx_i) - mean(p_i(idx_i));
    Y_i = fft(p_i_fluc);
    P_i = abs(Y_i/length(p_i_fluc));
    P_i = P_i(1:floor(end/2)+1);
    P_i = P_i/max(P_i); 
    
    plot(f, P_i, 'LineWidth', 1.2);
    leg{end+1} = sprintf('(x=%.1f,y=%.1f)', xi, yi);
end
xlabel('f'); ylabel('|P(f)|_{norm}'); legend(leg); xlim([0 0.2]);

% Figura 6: Evolución espacial de la fase relativa (frente a sonda S3)
figure(6); hold on; grid on;
[~, k_tono] = min(abs(f - f_tono));
phi_ref = angle(Y(k_tono));
for i = 1:5
    xi = probes_xy(i,1); yi = probes_xy(i,2);
    idx = abs(data.x - xi) < tol & abs(data.y - yi) < tol;
    pr = sortrows(data(idx,:), 't');
    t_i = pr.t; p_i = pr.p;
    idx_i = t_i >= tmin & t_i <= tmax;
    if sum(idx_i) < 500, continue, end
    
    p_i_fluc = p_i(idx_i) - mean(p_i(idx_i));
    Y_i = fft(p_i_fluc);
    phi_val = wrapToPi(angle(Y_i(k_tono)) - phi_ref);
    plot(xi, phi_val, 'ko', 'MarkerFaceColor', 'k');
end
xlabel('x'); ylabel('\Delta\phi (rad)');

% Figura 7: Coeficientes de correlación cruzada y determinación de Uc
figure(7); hold on; grid on;
p_ref = p_fluc;
for i = 1:5
    xi = probes_xy(i,1); yi = probes_xy(i,2);
    idx = abs(data.x - xi) < tol & abs(data.y - yi) < tol;
    pr = sortrows(data(idx,:), 't');
    t_i = pr.t; p_i = pr.p;
    idx_i = t_i >= tmin & t_i <= tmax;
    if sum(idx_i) < 500, continue, end
    
    p_i_fluc = p_i(idx_i) - mean(p_i(idx_i));
    [R, lags] = xcorr(p_i_fluc, p_ref, 'coeff');
    tau = lags * dt;
    plot(tau, R, 'LineWidth', 1.2);
    
    [~, ip] = max(R);
    if abs(xi - xref) > tol
        Uc = abs(xi - xref) / abs(tau(ip));
        fprintf('Sonda x=%.1f: Uc = %.2f\n', xi, Uc);
    end
end
xlabel('\tau'); ylabel('Correlación normalizada'); xline(0, 'k--');