% Dati delle bobine e dei rispettivi tau
coil_names = {'C1', 'C1.1', 'C1-F', 'C1-W', 'C1-P', 'C2'};  % Nomi delle bobine
tau_values = [0.026528, 0.228541, 0.057496, 0.0181, 0.5629, 41.9359];  % Valori di tau

% Plot dei valori di tau con diversi simboli
figure (1);
plot(1, tau_values(1), 'ro', 'MarkerSize', 10, 'DisplayName', coil_names{1}); hold on;
plot(2, tau_values(2), 'bs', 'MarkerSize', 10, 'DisplayName', coil_names{2});
plot(3, tau_values(3), 'gd', 'MarkerSize', 10, 'DisplayName', coil_names{3});
plot(4, tau_values(4), 'kv', 'MarkerSize', 10, 'DisplayName', coil_names{4});
plot(5, tau_values(5), 'm^', 'MarkerSize', 10, 'DisplayName', coil_names{5});
plot(6, tau_values(6), 'cp', 'MarkerSize', 10, 'DisplayName', coil_names{6});

% Personalizzazione del grafico
xlabel('Coils');
ylabel('Tau');
xticks(1:6);
xticklabels(coil_names);
legend('Location', 'northwest');
grid on;

% Dati delle bobine e dei rispettivi tau
coil_names = {'C1', 'C1.1', 'C1-F', 'C1-W', 'C1-P', 'C2'};  % Nomi delle bobine
tau_values = [0.026528, 0.228541, 0.057496, 0.0181, 0.5629, 41.9359];  % Valori di tau

% Plot dei valori di tau con scala logaritmica e simboli pieni
figure;
semilogy(1, tau_values(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', coil_names{1}); hold on;
semilogy(2, tau_values(2), 'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'DisplayName', coil_names{2});
semilogy(3, tau_values(3), 'gd', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', coil_names{3});
semilogy(4, tau_values(4), 'kv', 'MarkerSize', 10, 'MarkerFaceColor', 'k', 'DisplayName', coil_names{4});
semilogy(5, tau_values(5), 'm^', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'DisplayName', coil_names{5});
semilogy(6, tau_values(6), 'cp', 'MarkerSize', 10, 'MarkerFaceColor', 'c', 'DisplayName', coil_names{6});


% Personalizzazione del grafico
xlabel('Coils');
ylabel('Tau log scale');
xticks(1:6);
xticklabels(coil_names);
legend('Location', 'northwest');
grid on;
