%% Optimized TE0 to TE1 Coupler

% Description: Adiabatic coupler used as a mode modulator. Tested for
% volatges between -2.0 amnd 0 volts. Uses a 200 um long heated wavegudies.
die = "jvillegas";
circuits = ["TE1_topo_DEV03","TE1_topo_DEV03"];
outputs = ["Output_1","Output_2"]; % Output_1: TE0  Output_2: TE1
outputs_ref = "Output_1_test_TE"; % Output + circuit
colors = {'b','r'};
gauss_size = 100/10; %in 10s of pm
plot_step = 10;
num_heaters = 2;
heat_length = 100e-6*num_heaters;
i_mult = 1/2; % 2 circuits per pairt of metal pads. 
modes = [1 2];
wav_t = 1548; %%%%%%%%%%%%%%%%%% <------------------------------------------------ %%%%%%%%%%%%%%%%%%%%%

%% Gather data from both ports
leg_entries = {}; P = [];
for i = 1:length(circuits)    
    circuit = circuits(i); ref = outputs_ref; output = outputs(i); 
    data = read_csv(die,circuit,output, ref);
    v = []; ic = [];
    for j = 1:length(data)
        P(i,:,j) = smoothdata(data{j}.P,'gaussian',gauss_size);
        
        v = [v str2double(data{j}.params.MeasuredVoltageCh1)];
        ic = [ic str2double(data{j}.params.CurrentCh1)];
        hold on; grid on;
    end
end
ic = ic*i_mult;
p = v.*ic;
wav = data{j}.wav;

%% Sort in terms of the power in the heater

[p,I] = sort(p); P_sorted = [];
v = v(I); ic = ic(I);
for i = 1:length(circuits)    
    for j = 1:length(I)
        P_sorted(i,:,j) = P(i,:,I(j));
    end
end
P = P_sorted; clear 'P_sorted' 

%% Find the resonance shift per voltage (power) and use it to extrapolate the data
dl = zeros(2,length(p));

for mode = 1:2
    wav_ref = wav_t; % First guess is the tracked wavelength (closest resonance to it)
    wav_tn = wav_ref;
    for v_idx = 1:length(p)
        [pks,locs] = findpeaks(-P(mode,:,v_idx),"MinPeakProminence",10);
        wav_tn = interp1(wav(locs),wav(locs),wav_tn,'nearest','extrap');     %This gets updated in each iteration to trck the same resoannce peak
        idx = find(wav==wav_tn);
        idx_locs = find(locs==idx);
        fsr = wav(locs(idx_locs))-wav(locs(idx_locs-1));
        if v_idx == 1
            dl(mode,v_idx) = 0;
            wav_ref = wav_tn; %Store the exact refrence resonance wavelength
        else
            dl(mode,v_idx) = (wav_tn - wav_ref);
        end
    end
end
P_pi = abs(p(end)/dl(end)*fsr/2);

%% Plot for a given wavelength all voltages
figure(5)
%tcl = tiledlayout(2,1);
%nexttile
subplot(2,1,1); 
cla reset
closest = interp1(wav,wav,wav_t,'nearest','extrap');
idx = find(wav==closest);

plot(p, squeeze(P(1,idx,:)),'x','MarkerSize',9,'LineWidth', 2, 'color',colors{1}); hold on;
plot(p, squeeze(P(2,idx,:)),'x','MarkerSize',9,'LineWidth', 2, 'color',colors{2});

title("Power for each mode, at \lambda="+num2str(wav_t)+" nm");
%lim([-30, 0])

% Extrapolate by shifting the data
p_ = linspace(0,2*P_pi,101);
newp_mode = zeros(length(p_),length(modes));
for mode = modes
    coeff = polyfit(p,dl(mode,:),1);
    dl_ = polyval(coeff,p_);
    for idx_dl = 1:length(dl_)
        closest = interp1(wav+dl_(idx_dl),wav+dl_(idx_dl),wav_t,'nearest','extrap');
        idx = find(wav+dl_(idx_dl)==closest);
        newp_mode(idx_dl, mode) = P(mode,idx,1); %Record from the 0V power, at the shifted wavelength
    end
    plot(p_, newp_mode(:,mode),'--','color',colors{mode},'LineWidth', 1.5)
end
x_ = [P_pi P_pi];
y_ = ylim;
x_lim = xlim;
plot(x_,y_,'--','color','black');
text( x_(1)+abs(x_lim(2)-x_lim(1))/100, y_(1)+abs(y_(2)-y_(1))/10  , "P_\pi = " + num2str(P_pi,3) + " W/m")
ylim(y_);
xlabel('Heater power density (W/m)'); ylabel('Resonance Shift (nm)');

% Calculate and plot mode fraction
TE0 = 10.^(newp_mode(:,1)/10);
TE1 = 10.^(newp_mode(:,2)/10);
TE0_mf = (TE0)./(TE1+TE0);

yyaxis right; cla
plot(p_, TE0_mf);
ylabel('TE0 Mode Fraction')
legend(["TE0", "TE1"]);
hold off

%% Fit and plot resonance shifts
subplot(2,1,2); cla; hold on
title("Resonance Shift at \lambda="+num2str(wav_ref)+" nm");

%nexttile;
colors = {'b','r'}; markers = {'x','x'};
p_ = linspace(0,P_pi*1.2, 101);
for mode = modes
    coeff = polyfit(p,dl(mode,:),1);
    plot(p,dl(mode,:),markers{mode},'MarkerSize',9,'LineWidth', 2,'color',colors{mode});
    y1 = polyval(coeff,p_);
    plot(p_,y1,'--','color',colors{mode});
end
xlabel('Heater power density (W/m)'); ylabel('Resonance Shift (nm)');

x_ = [P_pi P_pi];
y_ = [min(y1) max(y1)]; 
x_lim = xlim;
text( x_(1)+abs(x_lim(2)-x_lim(1))/100, y_(1)+abs(y_(2)-y_(1))/10  , "P_\pi = " + num2str(P_pi,3)+" W/m" )
plot(x_,y_,'--','color','black');
hold off; legend(["TE0",'', "TE1"])
ylim(y_);
