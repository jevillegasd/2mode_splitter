folder = "G:\.shortcut-targets-by-id\1_fIZZygnD3u3Mfa688VRKetjj7gDkdvq\PRL Group\04 Projects\2 Juan\5 Inverse Design\3 Splitter_2Mode\Simulations\SParam";
load (folder + "/T.mat");
ax1 = axes; 
wav = lum.x0*1e6';
S11 = 10*log10(lum.y0*2)';
S12 = 10*log10(lum.y1*2)';
S21 = 10*log10(lum.y2*2)';
S22 = 10*log10(lum.y3*2)';

y_break_start = -5;
y_break_end = -25;
%h = BreakPlot(wav, [S11 S12 S21 S22],y_break_start,y_break_end,'Patch');
plot(wav, [S11 S12 S21 S22], 'Linewidth',1.5);
format_plot(gca,'wavelength (\mum)','Transmittance (dB)',2,'single');
legend({"TE_0:TE_0_,_0","TE_1:TE_0_,_\pi","TE_0:TE_0_,_\pi","TE_1:TE_0_,_0"})

breakyaxis([y_break_end y_break_start])


h = gca;
grid on;
xt = h.XTick;


ytick = h.YTick;
ytick(ytick<y_break_start)=ytick(ytick<y_break_start)+y_break_end;
for i=1:length(ytick)
   yticklabel{i}=sprintf('%d',ytick(i));
end
set(gca,'yticklabel',yticklabel);

legend({"TE_0:TE_0_,_0","TE_1:TE_0_,_\pi","TE_0:TE_0_,_\pi","TE_1:TE_0_,_0"})

