load("G:/.shortcut-targets-by-id/1_fIZZygnD3u3Mfa688VRKetjj7gDkdvq/PRL Group/04 Projects/2 Juan/5 Inverse Design/3 Splitter_2Mode/Simulations/images/modes/S00.mat");
wav1 = lum.x0*1e9; S00 = lum.y0;
load ("G:/.shortcut-targets-by-id/1_fIZZygnD3u3Mfa688VRKetjj7gDkdvq/PRL Group/04 Projects/2 Juan/5 Inverse Design/3 Splitter_2Mode/Simulations/images/modes/S01.mat");;
wav2 = lum.x0*1e9; S11 = lum.y0;


T_00 = 10*log10(1-(S00.^2)./10);
T_11 = 10*log10(1-(S11.^2)./10);

ax1 = axes; 
plot(wav1,-T_00,wav2,-T_11,'LineWidth',2);

format_plot(ax1,'Wavelength (dB)','Insertion Loss (dB)',2,'flat');
legend({"|S_0_0|^2","|S_1_1|^2"})