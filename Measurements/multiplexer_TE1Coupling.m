%% Insertion LOsses of Mode MUX 

% Description: Use a set of 12 and 6 back to back evanescent multiplexers to
% determine IL for TE1.

die = "jvillegas02";
circuits =      ["coupler_IL_12v6","coupler_IL_12v6"];
outputs_ref =   ["Output_1_adia_IL_TE1_12", "Output_1_adia_IL_TE1_12"]; % Output + circuit
outputs =       ["Output_1","Output_2"];
colors = ['r','b'];

gauss_size  = 20000/10; %in 10s of pm
figure(1), clf
subplot(2,1,1)
P = []; P_s = [];
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref(i); output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
   
    %Plot measured power
    leg_entries = {};
    for j = 1:length(data)
        P(:,i,j) = smoothdata(data{j}.P,'gaussian',gauss_size)';
        P_s(:,i,j) = smoothdata(data{j}.P,'gaussian',3)';
        hold on; grid on;
    end
end
wav = data{1}.wav;
plot (wav, P_s,'--');
plot(wav,P,'-','LineWidth',2)

legend({"","","N=6","N=12"});
xlim([1520, 1580])
format_plot(gca,'Wavelength (nm)','Transmitance (dB)',2,'double')

%% Calcuate losses
subplot(2,1,2), cla, hold on
x = [6; 12].*2;
X = [ones(length(x), 1) x];

b = zeros(length(P), 2);
for i = 1: length(P)
    b(i,:) = X\P(i,:)';
end
loss_modemuxTE1= b(:,2);

semilogy(wav,-loss_modemuxTE1,'LineWidth',2)
format_plot(gca,'Wavelength (nm)','Excess Loss (dB)',2,'double')
xlim([1520, 1580])

save('muxref','loss_modemuxTE1')
