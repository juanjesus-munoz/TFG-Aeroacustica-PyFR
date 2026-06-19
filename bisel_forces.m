%%%%%% ANÁLISIS DE FUERZAS AERODINÁMICAS SOBRE EL BISEL %%%%%%
% Script para el análisis de la componente vertical de la fuerza (Fy).
% Nota: Cambiar la variable 'filename' para analizar diferentes casos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all; clc;

%% 1. LECTURA Y PREPARACIÓN DE DATOS
% ----------------------------------------------------------------------

% --- Sustituir 'X' por el caso correspondiente ---
filename = 'caso_X_bisel_forces.csv';

if ~exist(filename, 'file'), error('Archivo no encontrado.'); end

data = readtable(filename);
data = sortrows(data, 't'); % Ordenación cronológica

t = data.t;
Fx_p = data.px; Fy_p = data.py;
Fx_v = data.vx; Fy_v = data.vy;
Fx = Fx_p + Fx_v;
Fy = Fy_p + Fy_v; % Fuerza vertical total (fuente dipolar)

% Filtrado de valores no físicos
valid = isfinite(Fy) & (abs(Fy) < 10);
t = t(valid); Fy = Fy(valid); Fy_p = Fy_p(valid); Fy_v = Fy_v(valid);

%% 2. ANÁLISIS TEMPORAL (RÉGIMEN ESTACIONARIO)
% ----------------------------------------------------------------------

t_min = 400; t_max = 1000;
idx = (t >= t_min) & (t <= t_max);
t_sel = t(idx);
Fy_sel = Fy(idx);

% Centrado de la señal (eliminación de la componente DC)
Fy_mean = mean(Fy_sel);
Fy_fluc = Fy_sel - Fy_mean;

% % Figura 1: Evolución temporal de la fuerza vertical de presión
figure(1); plot(t, Fy_p, 'Color', [0 0.447 0.741], 'LineWidth', 1.3);
grid on; xlabel('t'); ylabel('F_y^{(p)}');

% % Figura 2: Desglose de componentes (Presión vs Viscosidad vs Total)
figure(2); plot(t, Fy_p, 'LineWidth', 1.2); hold on;
plot(t, Fy_v, '--', 'LineWidth', 1.2);
plot(t, Fy, 'k', 'LineWidth', 1.5);
xlabel('t'); ylabel('F_y'); legend('Presión', 'Viscosidad', 'Total'); grid on;

% % Figura 3: Señal de la fuerza Fy en el régimen estacionario seleccionado
figure(3); plot(t_sel, Fy_sel, 'k', 'LineWidth', 1.3);
grid on; xlabel('t'); ylabel('F_y');

% % Figura 4: Detalle del ciclo límite (Zoom temporal)
figure(4); plot(t_sel, Fy_sel, 'k', 'LineWidth', 1.2);
grid on; xlim([450 550]); xlabel('t'); ylabel('F_y');

% % Figura 5: Comparativa entre señal total y fluctuante (Fy - Fy_mean)
figure(5); plot(t_sel, Fy_sel, 'k', 'LineWidth', 1.2); hold on;
plot(t_sel, Fy_fluc, 'r', 'LineWidth', 1.2);
yline(0, 'k--', 'HandleVisibility', 'off');
xlabel('t'); ylabel('F_y'); legend('Original', 'Fluctuante'); grid on;

%% 3. ANÁLISIS ESPECTRAL (FFT)
% ----------------------------------------------------------------------

dt = mean(diff(t_sel));
fs = 1/dt;
N = length(Fy_fluc);

% Ventana de Hann (Implementación manual)
n = (0:N-1)';
w = 0.5*(1 - cos(2*pi*n/(N-1)));
Fy_win = Fy_fluc .* w;

% FFT con Zero-Padding para mejorar la definición de los picos
Nfft = 4*N;
Y = fft(Fy_win, Nfft);
P2 = abs(Y/N);
P1 = P2(1:floor(Nfft/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:floor(Nfft/2))/Nfft;

% Identificación de la frecuencia fundamental f0
idx_search = f > 0.01;
f_v = f(idx_search); P1_v = P1(idx_search);
[max_amp, idx_max] = max(P1_v);
f0 = f_v(idx_max);

% % Figura 6: Espectro de amplitud y detección de la frecuencia fundamental
figure(6)
plot(f, P1, 'Color', [0.85 0.32 0.1], 'LineWidth', 1.5); hold on;
plot(f0, max_amp, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');
text(f0*1.05, max_amp, sprintf(' f_0 = %.4f', f0), ...
'FontWeight', 'bold', 'FontSize', 10, 'VerticalAlignment', 'bottom');
xlabel('f'); ylabel('|F_y(f)|'); grid on; xlim([0 0.2]);

% Salida de resultados
fprintf('Análisis completado para: %s\n', filename);
fprintf('Frecuencia fundamental detectada f_0 = %.4f\n', f0);
