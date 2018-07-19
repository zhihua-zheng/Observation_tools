%--- getmat_read



%% read data from getmat preprocessing directory

getmat_dir = pwd;
data = load_getmat(fullfile(getmat_dir, 'allbins_'));

% DO apply the editing mask to get oceanic velocity
u = data.u .* data.nanmask;
v = data.v .* data.nanmask;

speed = sqrt(u.^2 + v.^2);
vs = v(1,2:end); % surface current (9m) in y direction

dday = data.dday;
date_vec = data.time;
lon = data.lon;
lat = data.lat;
depth = data.depth;

%% Spectral analysis for oceanic velocities

% remove the mean
vs = vs - nanmean(vs);

trunk_l = 64;  % trunk length for WOSA
fs = 30; % sampling frequency [cycle/hour] 

[pxx,w_span] = pwelch(vs,trunk_l,[],fs); % WOSA


% estimate one-lag atocorrelation coefficient (average for every trunk)
j = 0;
c_vs = NaN*ones(1,100);

for i = 1:trunk_l/2:length(vs)
    
    if i+trunk_l-1 <= length(vs)
        
        auto_vs = vs(i:i+trunk_l-1);
        [c,lag] = xcorr(auto_vs,10,'coeff');    
        j = j+1; % count the number of repeatance
        c_vs(j) = c(12);
        
    else
        continue
    end
end

a = nanmean(c_vs);

rspec = (1-a^2)./(1-2*a*cos(w_span)+a^2); % red noise spectrum fit (null hypothesis)
rspec = rspec*var(vs); % multiply by a ratio to preserve total variance

dof = 2*length(vs)*1.2/trunk_l - 1; % degree of freedom for velocity spectrum
dof_r = -length(vs)*log(a)/2; % degree of freedom for red noise spectrum

fst = finv(0.95,dof,dof_r);         % F-statistic
rspec_95 = rspec*fst;

%-------------------- plot spectra and the fitted red noise spectra

figure('position', [0, 0, 900, 400])

line(24*w_span,rspec,'LineWidth',1.3,'Color',rand(1,3),'LineStyle','--')
line(24*w_span,pxx,'LineWidth',1.3,'Color',rand(1,3))
line(24*w_span,rspec_95,'LineWidth',1.3,'Color',rand(1,3),'LineStyle','--')
    box on
    h = legend('red noise fit','surface current','95$$\%$$ confidence limit');
    ylabel('power spectrum density $\Phi(f)$', 'fontname', 'computer modern', 'fontsize', 13,'Interpreter', 'latex')
    xlabel('frequency (cycle per day)', 'fontname', 'computer modern', 'fontsize', 13,'Interpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex','yscale','log')
    set(h, 'FontSize', 12, 'FontName', 'computer modern','Interpreter', 'latex');
    

    
    