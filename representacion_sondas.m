%%%%%% ESQUEMA DE LOCALIZACIÓN DE SONDAS (PROBES) %%%%%%
clear; close all; clc;

%% 1. PARÁMETROS GEOMÉTRICOS
l = 2.5;     % Longitud del conducto de entrada
W = 2.0;     % Distancia desde la salida hasta la punta del bisel
L = 5.0;     % Longitud total del cuerpo del bisel
h = 0.5;     % Espesor del canal y del cuerpo del bisel
bevel = 1.0; % Longitud de la rampa del bisel
shift = l;   % Desplazamiento para situar el origen (0,0) en la salida del canal

%% 2. CONFIGURACIÓN DEL DOMINIO
figure(1); hold on; box on;
% Definición de los límites del dominio computacional para la visualización
x_dom = [-1 10 10 -1 -1]; 
y_dom = [-6 -6 6 6 -6];
plot(x_dom, y_dom, 'k-', 'LineWidth', 1.5);

%% 3. DIBUJO DE LA GEOMETRÍA
% --- Conducto de entrada (Izquierdo) ---
% Situado de x = -l hasta x = 0
plot([0-l 0], [ h/2  h/2], 'k-', 'LineWidth', 2.5); 
plot([0-l 0], [-h/2 -h/2], 'k-', 'LineWidth', 2.5); 

% --- Cuerpo del Bisel (Derecho) ---
% Se define la geometría según las coordenadas relativas a la salida
x_bisel = [W, W + bevel, W + L, W + L, W];
y_bisel = [-h/2, h/2, h/2, -h/2, -h/2];

% Relleno sólido del bisel para facilitar su identificación
patch(x_bisel, y_bisel, [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 1.5);

%% 4. LOCALIZACIÓN DE SONDAS (COORDENADAS PYFR)
probes_xy = [
    0.0 0.0;    % S1: Salida del canal (Origen)
    2.0 0.0;    % S2: Eje del chorro (zona media)
    3.9 -0.6;   % S3: Capa de cizalla (zona de impacto)
    9.0 5.0;    % S4: Campo lejano superior
    9.0 -5.0    % S5: Campo lejano inferior
];
labels = {'S1','S2','S3','S4','S5'};

% Representación de las sondas puntuales
plot(probes_xy(:,1), probes_xy(:,2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);

% Etiquetado de los puntos de control
for i = 1:5
    text(probes_xy(i,1)+0.2, probes_xy(i,2)+0.2, labels{i}, ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', 'r');
end

%% 5. ESTÉTICA FINAL Y EJES
xlabel('Coordenada x', 'FontSize', 12);
ylabel('Coordenada y', 'FontSize', 12);
axis equal;
grid on;
xlim([-1 10]); 
ylim([-6 6]);
set(gca, 'FontSize', 11);

% Fin del script