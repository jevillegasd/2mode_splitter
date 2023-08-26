%% Adiabatic TE0 to TE1 Coupler

% Description: 
%  
die = "jvillegas";
circuits = ["TE0_DEV03","TE1_DEV03"];
outputs_ref = ["Output_1_test_TE","Output_1_test_TE"]; % Output + circuit
outputs = ["Output_1","Output_1"];
colors = ['r','b'];
gauss_size = 50/10; %in 10s of pm
plot_step = 10;

figure(1)
tcl = tiledlayout(1,2);

nexttile
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
    P = smoothdata(data{1}.P,'gaussian',gauss_size);
    
    %Plot measured power
    plot(data{1}.wav, P, colors(i)); 
    hold on; grid on;
end
title('Adiabatic TE1-TE0m Splitter - TE0 Output')
legend({"TE0", "TE1"})
xlim([1520, 1580])

circuits = ["TE0_DEV03","TE1_DEV03"];
outputs = ["Output_2","Output_2"];
nexttile
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
    P = smoothdata(data{1}.P,'gaussian',gauss_size);
    
    %Plot measured power
    plot(data{1}.wav, P, colors(i)); 
    hold on; grid on;
end
title('Adiabatic TE1-TE0m Splitter - TE1 Output')
legend({"TE0", "TE1"})
xlim([1520, 1580])

title(tcl,'Mode Modulator using Adiabatic Y-Splitters')
