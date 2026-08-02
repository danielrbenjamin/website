% =========================================================================
% CHASSIS TORSIONAL STIFFNESS ANALYSIS
% UBC Formula Electric — Chassis Design Validation
%
% Reference: Deakin et al., SAE 2000-01-3554
%   "The Effect of Chassis Stiffness on Race Car Handling Balance"
%
% BACKGROUND
%   During cornering, lateral acceleration transfers vertical load from
%   inside wheels to outside wheels. The front/rear split of this lateral
%   load transfer (LLT) governs handling balance — more front LLT causes
%   understeer, more rear LLT causes oversteer.
%
%   The suspension ARB setting controls the intended LLT split. But this
%   only works if the chassis transmits the differential torsional moment
%   between axles. A soft chassis twists instead, pulling both axles
%   toward 50:50 LLT regardless of ARB position — degrading tuning authority.
%
% KEY INSIGHT
%   Deakin showed loss% depends almost entirely on the ratio Ktot/Kch,
%   not on individual values. The rule of thumb (Eq. 5) is:
%       Loss% ≈ (Ktot/Kch) × 20
%   This report applies the underlying model directly at our actual
%   operating conditions rather than using the approximation.
%
% OUTPUTS
%   Figure 1          LLT% vs roll stiffness split for a range of chassis
%                     stiffnesses. Equivalent to Deakin Fig. 9, at our
%                     Ktot = 729 Nm/deg. Kch values match the paper.
%
%   Figure 2          Loss% vs Ktot/Kch ratio at our worst-case tuning
%                     split. Equivalent to Deakin Fig. 15. Shows whether
%                     our chassis meets the Deakin (20%) and conservative
%                     (10%) loss targets.
%
%   Console           LLT table at our operating split, and chassis
%                     pass/fail assessment against both targets.
%
%   generated_values.tex
%                     Auto-generated LaTeX commands for every computed
%                     number. Input into chassis_stiffness.tex so the
%                     report updates automatically on recompile.
%
% NOTE ON FIGURE 2 EVALUATION SPLIT
%   Figure 2 uses maxTuningSplit (54%), not our 51:49 operating split.
%   At 51:49, rollDiff = 2 pp — near zero. Any chassis stiffness looks
%   adequate at this split, making it useless as a design target.
%   Using 54% gives rollDiff = 8 pp, which is the largest 
%   differential the chassis must ever transmit.
%
% VARIABLE GLOSSARY
%   Ktot         Total suspension roll stiffness [Nm/deg] = Krollf + Krollr
%   Krollf       Front roll stiffness: corner springs + front ARB [Nm/deg]
%   Krollr       Rear roll stiffness: corner springs + rear ARB [Nm/deg]
%   Kch          Chassis torsional stiffness (spaceframe) [Nm/deg]
%   rollDiff     |2×frontRollPct − 100|: intended LLT difference [pp]
%   loadDiff     |2×frontLLT% − 100|: LLT difference delivered [pp]
%   Loss%        (rollDiff − loadDiff)/rollDiff × 100: fraction of intended
%                LLT differential lost to chassis twist
%   Ratio        Ktot/Kch: dimensionless parameter governing loss%
%
% WORKFLOW
%   1. Update SECTION 1 inputs if car parameters change.
%   2. Run this script — figures and generated_values.tex are written
%      automatically to the current working directory.
%   3. Run: pdflatex chassis_stiffness.tex (twice for correct references).
%   Ensure MATLAB's working directory matches the folder with the .tex file.
%
% =========================================================================

clear; clc; close all;

% =========================================================================
% SECTION 1: INPUTS
% =========================================================================

% --- Roll stiffness at each axle ---
% Source: 2026 FSAE Design Spec Sheet, Suspension Parameters table.
% "Roll rate (chassis to wheel center)" — includes corner springs and ARB,
% referred to the wheel center through the suspension motion ratios.
%   Front: 596 Nm/deg
%   Rear:  513 Nm/deg
Krollf = 596;                % front axle roll stiffness [Nm/deg]
Krollr = 513;                % rear axle roll stiffness [Nm/deg]
Ktot   = Krollf + Krollr;   % total suspension roll stiffness [Nm/deg] = 1109

% --- Operating roll stiffness split ---
% Computed directly from spec sheet roll rates: Krollf/Ktot.
% This is the actual front roll stiffness fraction, not an assumed value.
frontRollPct_car = (Krollf / Ktot) * 100;   % [%] = 53.74%

% --- Current chassis torsional stiffness ---
% Source: 2026 FSAE Design Spec Sheet, Frame section.
% Value is from FEA simulation (1855.4 Nm/deg). Physical torsional test
% not yet completed — update this value when test results are available.
Kch_current = 1855;          % [Nm/deg] (FEA simulated)

% --- Worst-case tuning split (Figure 2 only) ---
% Maximum front FLLTD the suspension lead would run at competition.
% Confirmed with Aidan Somani: "FLLTD is max 53.9%"
% Using 54% (rounded up) as a conservative bound.
% rollDiff at 54:46 = |2×54 − 100| = 8 pp.
% Note: FLLTD ≠ roll stiffness split. FLLTD includes geometric and
% unsprung components. The roll stiffness split at maximum tuning will
% be somewhat higher than 54% — using 54% is conservative.
maxTuningSplit = 54;         % [%] front

% --- Loss targets ---
% Two thresholds plotted on Figure 2:
%   20% — Deakin's own example threshold (Deakin et al., 2000)
%   10% — conservative in-house target, consistent with lower end of the
%          3-5x Ktot range cited in broader motorsport literature
targetLosses = [20, 10];                             % [%]
targetColors = {[0.369 0.902 0.627], [1.000 0.706 0.329]}; % site green, amber
targetLabels = {'20% (Deakin)', '10% (conservative)'};

% --- Weight distribution ---
% Source: 2026 FSAE Design Spec Sheet, "Weight Distribution with 68kg driver"
% Front: 49%, Rear: 51% (with driver).
% Per Deakin Figs 13-14, rear-heavy distributions shift the neutral point
% away from 50:50 and require a slightly stiffer chassis for the same loss%.
wf = 0.49;                   % front weight fraction (with driver)
wr = 0.51;                   % rear weight fraction (with driver)

% --- Chassis stiffness sweep (Figure 1) ---
% Matches Deakin Figs 9-12 exactly so curves can be compared directly.
Kch_list = [100, 300, 600, 1000, 2000, 4000, 8000, 16000]; % [Nm/deg]

% =========================================================================
% DERIVED QUANTITIES
% =========================================================================

a_car     = frontRollPct_car / 100;   % = 0.5374 (596/1109)
a_tuning  = maxTuningSplit   / 100;   % = 0.54
nK        = numel(Kch_list);

% rollDiff: the LLT difference the chassis must transmit [pp].
% Larger rollDiff = more demanding on the chassis.
rollDiff_car    = abs(2*frontRollPct_car - 100);   % 53.74:46.26 → ~7.5 pp
rollDiff_tuning = abs(2*maxTuningSplit   - 100);   % 54:46       → 8 pp

% =========================================================================
% SECTION 2: FIGURE 1 — LLT% vs ROLL STIFFNESS SPLIT
%
% Equivalent to Deakin Fig. 9, computed for Ktot = 1109 Nm/deg
% (596 front + 513 rear, from 2026 spec sheet).
% Deakin Fig. 9 uses Ktot = 500 Nm/deg — curve shapes will differ.
% Kch values match the paper for direct visual comparison.
%
% How to read: pick a curve (one Kch). The x-axis is your ARB setting.
% The y-axis is the LLT actually delivered to the tires. The dashed
% diagonal is a rigid chassis (LLT = roll split exactly). All curves
% meet at 50:50 — a symmetric split has no differential moment to distort.
% =========================================================================

frontPct_sweep = 0:1:100;
alpha_sweep    = frontPct_sweep / 100;

% --- Portfolio-site figure theme (mirrors styles.css) ---
site.bg         = [0.047 0.055 0.059]; % #0c0e0f
site.panel      = [0.078 0.094 0.098]; % #141819
site.line       = [0.137 0.161 0.169]; % #23292b
site.lineBright = [0.184 0.220 0.227]; % #2f383a
site.ink        = [0.863 0.890 0.878]; % #dce3e0
site.inkDim     = [0.541 0.592 0.580]; % #8a9794
site.inkFaint   = [0.361 0.404 0.392]; % #5c6764
site.amber      = [1.000 0.706 0.329]; % #ffb454
site.green      = [0.369 0.902 0.627]; % #5ee6a0
site.blueprint  = [0.498 0.718 1.000]; % #7fb7ff
site.mono       = 'JetBrains Mono';

% A restrained technical palette: site accents plus muted interpolations.
colors = [site.inkFaint; ...
          0.70*site.inkFaint + 0.30*site.blueprint; ...
          site.blueprint; ...
          0.55*site.blueprint + 0.45*site.green; ...
          site.green; ...
          0.55*site.green + 0.45*site.amber; ...
          site.amber; ...
          0.72*site.amber + 0.28*site.ink];

% Alternate solid/dotted for greyscale legibility (matches Deakin style)
lineStyles = repmat({'-'}, 1, nK);
lineStyles(ceil(nK/2)+1:end) = {':'};

figure('Name', 'Fig 1: LLT vs Roll Stiffness Split', ...
       'Color', site.bg, 'Position', [100 100 720 540]);
hold on; grid on; box on;

% One curve per chassis stiffness
for k = 1:nK
    Kch       = Kch_list(k);
    LLT_curve = arrayfun( ...
        @(a) frontLT_onePoint(Ktot*a, Ktot*(1-a), Kch, wf, wr), ...
        alpha_sweep);
    plot(frontPct_sweep, LLT_curve, ...
        'LineWidth',  2, ...
        'LineStyle',  lineStyles{k}, ...
        'Color',      colors(k,:), ...
        'DisplayName', sprintf('K_{ch} = %g Nm/deg', Kch));
end

% Rigid chassis reference diagonal
plot([0 100], [0 100], '--', 'Color', site.inkFaint, 'LineWidth', 1.2, ...
     'DisplayName', 'Rigid chassis (K_{ch} \rightarrow \infty)');

% Our car's current operating point
LLT_at_operating = frontLT_onePoint( ...
    Ktot*a_car, Ktot*(1-a_car), Kch_current, wf, wr);
plot(frontRollPct_car, LLT_at_operating, 'o', ...
     'MarkerFaceColor', site.amber, 'MarkerEdgeColor', site.bg, ...
     'LineWidth', 1.4, 'MarkerSize', 8, ...
     'DisplayName', sprintf('Our car  (K_{ch} = %g, %.1f:%.1f split)', ...
     Kch_current, frontRollPct_car, 100-frontRollPct_car));

xlabel('Front roll stiffness as % of total  (%)',      'FontSize', 11);
ylabel('Front lateral load transfer as % of total (%)', 'FontSize', 11);
title(sprintf('Lateral Load Transfer Distribution  (K_{tot} = %g Nm/deg)\ncf. Deakin Fig. 9  (K_{tot} = 500 Nm/deg)', Ktot), ...
      'FontSize', 11);
lgd1 = legend('Location', 'southeast', 'FontSize', 8);
xlim([0 100]); ylim([0 100]);
axFig1 = gca;
set(axFig1, 'FontSize', 10, 'FontName', site.mono, ...
    'Color', site.panel, 'XColor', site.inkDim, 'YColor', site.inkDim, ...
    'GridColor', site.lineBright, 'GridAlpha', 0.65, ...
    'MinorGridColor', site.line, 'Box', 'on', 'LineWidth', 0.8);
set([axFig1.XLabel axFig1.YLabel], 'Color', site.inkDim, 'FontName', site.mono);
set(axFig1.Title, 'Color', site.ink, 'FontName', site.mono, 'FontWeight', 'normal');
set(lgd1, 'Color', site.panel, 'TextColor', site.inkDim, ...
    'EdgeColor', site.lineBright, 'FontName', site.mono);

% Save — set figure to fixed physical size for clean LaTeX inclusion,
% then export as PDF. exportgraphics crops tightly to the axes content.
% Width 14cm fits a two-column SAE-style layout at \linewidth.
fig1 = gcf;
% Force one typeface across ticks, labels, title, legend, and annotations.
set(findall(fig1, '-property', 'FontName'), 'FontName', site.mono);
exportgraphics(fig1, 'fig_LLT_curves.pdf', 'ContentType', 'vector');
fprintf('Saved: fig_LLT_curves.pdf\n');

% Compute LLT at each Kch at the operating split (for table export)
LLT_front_at_split = zeros(1, nK);
LLT_rear_at_split  = zeros(1, nK);
for k = 1:nK
    LLT_front_at_split(k) = frontLT_onePoint( ...
        Ktot*a_car, Ktot*(1-a_car), Kch_list(k), wf, wr);
    LLT_rear_at_split(k)  = 100 - LLT_front_at_split(k);
end

% Console: LLT table at operating split
fprintf('\n');
fprintf('=================================================================\n');
fprintf(' Figure 1: LLT at %.1f:%.1f operating split\n', ...
        frontRollPct_car, 100-frontRollPct_car);
fprintf(' Ktot = %g Nm/deg,  weight = %.0f:%.0f\n', Ktot, 100*wf, 100*wr);
fprintf('=================================================================\n');
fprintf('  %-18s  %-16s  %-16s\n', 'Kch (Nm/deg)', 'Front LLT (%)', 'Rear LLT (%)');
fprintf('  %s\n', repmat('-', 1, 52));
for k = 1:nK
    fprintf('  %-18g  %-16.3f  %-16.3f\n', ...
        Kch_list(k), LLT_front_at_split(k), LLT_rear_at_split(k));
end
fprintf('\n  Our chassis (Kch = %g Nm/deg): Front LLT = %.3f%%\n', ...
        Kch_current, LLT_at_operating);

% =========================================================================
% SECTION 3: FIGURE 2 — LOSS% vs Ktot/Kch RATIO
%
% Equivalent to Deakin Fig. 15, evaluated at our worst-case tuning split
% (maxTuningSplit = 54%) rather than the paper's 60:40.
%
% How the ratio sweep works: Deakin found loss% depends on Ktot/Kch
% alone, not on individual values. So we sweep the ratio directly —
% for each ratio we reconstruct Kch = Ktot/ratio, run the Deakin model,
% and compute loss%. This traces the same curve as the paper in one pass.
% The curve is specific to our maxTuningSplit input.
%
% How to read: find your acceptable loss% on the x-axis. Read the
% required Ktot/Kch ratio on the y-axis. Required Kch = Ktot / ratio.
% Use the computed curve. The right axis reads Kch directly.
% =========================================================================

ratios  = linspace(0.05, 4.5, 500);
lossPct = zeros(size(ratios));

for i = 1:numel(ratios)
    Kch_i      = Ktot / ratios(i);
    frontLT_i  = frontLT_onePoint(Ktot*a_tuning, Ktot*(1-a_tuning), Kch_i, wf, wr);
    loadDiff_i = abs(2*frontLT_i - 100);
    lossPct(i) = max(0, (rollDiff_tuning - loadDiff_i) / rollDiff_tuning * 100);
end

% Current chassis: loss and ratio
R_current    = Ktot / Kch_current;
lt_cur       = frontLT_onePoint(Ktot*a_tuning, Ktot*(1-a_tuning), Kch_current, wf, wr);
loss_current = max(0, (rollDiff_tuning - abs(2*lt_cur-100)) / rollDiff_tuning * 100);

% Required ratio and Kch at each loss target (interpolated from curve)
ratio_at_target = nan(size(targetLosses));
Kch_required    = nan(size(targetLosses));
for t = 1:numel(targetLosses)
    ratio_at_target(t) = interp1(lossPct, ratios, targetLosses(t), 'linear', NaN);
    if isnan(ratio_at_target(t))
        warning('Loss curve does not reach %g%%. Increase maxTuningSplit.', targetLosses(t));
    else
        Kch_required(t) = Ktot / ratio_at_target(t);
    end
end

% Axis limits: cap x at 25% (beyond this is not a realistic scenario)
xMax_plot = 25;
idx_xlim  = find(lossPct > xMax_plot, 1, 'first');
yMax_plot = min(4.5, ratios(idx_xlim) * 1.15);

fig2 = figure('Name', 'Fig 2: Chassis Stiffness Requirement', ...
              'Color', site.bg, 'Position', [840 100 760 560]);
ax1 = axes('Parent', fig2);
hold(ax1, 'on'); grid(ax1, 'on'); box(ax1, 'on');

% Loss curve
plot(ax1, lossPct, ratios, ...
     'Color', site.blueprint, 'LineWidth', 2.5, ...
     'DisplayName', sprintf('Loss curve  (%d:%d split,  K_{tot} = %g Nm/deg)', ...
     maxTuningSplit, 100-maxTuningSplit, Ktot));

% Green shaded region: within the Deakin 20% target
patch(ax1, [0 targetLosses(1) targetLosses(1) 0], [0 0 yMax_plot yMax_plot], ...
      site.green, 'EdgeColor', 'none', 'FaceAlpha', 0.08, ...
      'HandleVisibility', 'off');

% Target lines and intersection labels (one per target)
for t = 1:numel(targetLosses)
    tLoss  = targetLosses(t);
    tColor = targetColors{t};

    xline(ax1, tLoss, '--', 'Color', tColor, 'LineWidth', 1.8, ...
          'Label', sprintf('%g%%', tLoss), ...
          'LabelVerticalAlignment', 'top', ...
          'LabelHorizontalAlignment', 'right', ...
          'FontSize', 9, 'HandleVisibility', 'off');

    if ~isnan(ratio_at_target(t))
        % Dot at intersection
        plot(ax1, tLoss, ratio_at_target(t), 'o', ...
             'MarkerFaceColor', tColor, 'MarkerEdgeColor', site.bg, ...
             'MarkerSize', 9, 'HandleVisibility', 'off');

        % Alternate label above/below to avoid overlap between the two targets
        vAlign = 'bottom';
        if t == 2, vAlign = 'top'; end
        text(ax1, tLoss + xMax_plot*0.02, ratio_at_target(t), ...
             sprintf('  K_{ch} \\geq %g Nm/deg', round(Kch_required(t))), ...
             'FontSize', 9, 'Color', tColor, ...
             'VerticalAlignment', vAlign, 'HorizontalAlignment', 'left', ...
             'BackgroundColor', site.panel, 'EdgeColor', tColor, 'Margin', 2);
    end
end

% Current chassis: labelled dot

plot(ax1, loss_current, R_current, 'o', ...
     'MarkerFaceColor', site.amber, 'MarkerEdgeColor', site.bg, ...
     'MarkerSize', 10, 'LineWidth', 1.5, ...
     'DisplayName', sprintf('Our chassis  (K_{ch} = %g Nm/deg)', Kch_current));

text(ax1, loss_current, R_current + yMax_plot*0.08, ...
     sprintf('K_{ch} = %g Nm/deg\nLoss = %.1f%%', Kch_current, loss_current), ...
     'FontSize', 9, 'Color', site.amber, ...
     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
     'BackgroundColor', site.panel, 'EdgeColor', site.lineBright, 'Margin', 2);

xlim(ax1, [0 xMax_plot]);
ylim(ax1, [0 yMax_plot]);
xlabel(ax1, 'LLT loss  (% of intended roll stiffness difference)', 'FontSize', 11);
ylabel(ax1, 'Ratio  K_{tot} / K_{ch}',                             'FontSize', 11);
title(ax1, sprintf('Chassis Stiffness Requirement  (K_{tot} = %g Nm/deg,  %d:%d worst-case split)\ncf. Deakin Fig. 15  (60:40 split)', ...
      Ktot, maxTuningSplit, 100-maxTuningSplit), 'FontSize', 11);
lgd2 = legend(ax1, 'Location', 'southeast', 'FontSize', 9);
set(ax1, 'FontSize', 10, 'FontName', site.mono, ...
    'Color', site.panel, 'XColor', site.inkDim, 'YColor', site.inkDim, ...
    'GridColor', site.lineBright, 'GridAlpha', 0.65, ...
    'MinorGridColor', site.line, 'Box', 'on', 'LineWidth', 0.8);
set([ax1.XLabel ax1.YLabel], 'Color', site.inkDim, 'FontName', site.mono);
set(ax1.Title, 'Color', site.ink, 'FontName', site.mono, 'FontWeight', 'normal');
set(lgd2, 'Color', site.panel, 'TextColor', site.inkDim, ...
    'EdgeColor', site.lineBright, 'FontName', site.mono);

% Right y-axis showing Kch directly in Nm/deg
% Kch_ticks must be ascending → flip so large Kch (small ratio) comes first
ax2 = axes('Parent', fig2, 'Position', ax1.Position, ...
           'YAxisLocation', 'right', 'Color', 'none', ...
           'XTick', [], 'FontSize', 10, 'FontName', site.mono, ...
           'XColor', site.inkDim, 'YColor', site.inkDim);

Kch_ticks_all = [200, 300, 500, 700, 1000, 1500, 2000, 3000, 5000];
Kch_ticks     = fliplr(Kch_ticks_all(Kch_ticks_all >= Ktot/yMax_plot));
ratio_ticks   = Ktot ./ Kch_ticks;   % ascending (large Kch → small ratio)

ylim(ax2, [0 yMax_plot]);
set(ax2, 'YTick', ratio_ticks, ...
         'YTickLabel', arrayfun(@(k) sprintf('%g', k), Kch_ticks, 'UniformOutput', false));
ylabel(ax2, 'K_{ch}  (Nm/deg)', 'FontSize', 11);
set(ax2.YLabel, 'Color', site.inkDim, 'FontName', site.mono);

% Highlight our chassis on the right axis
if R_current <= yMax_plot
    merged_ticks  = unique([ratio_ticks, R_current]);
    merged_labels = arrayfun(@(r) sprintf('%g', round(Ktot/r)), ...
                             merged_ticks, 'UniformOutput', false);
    [~, idx] = min(abs(merged_ticks - R_current));
    merged_labels{idx} = sprintf('\\bf%g \\rm\\leftarrow', Kch_current);
    set(ax2, 'YTick', merged_ticks, 'YTickLabel', merged_labels);
end

axes(ax1); %#ok<LAXES>

% Save — hide toolbars and export at fixed physical size
ax1.Toolbar.Visible = 'off';
ax2.Toolbar.Visible = 'off';
% Include both axes, ConstantLine labels, legends, and text callouts.
set(findall(fig2, '-property', 'FontName'), 'FontName', site.mono);
exportgraphics(fig2, 'fig_loss_ratio.pdf', 'ContentType', 'vector');
fprintf('Saved: fig_loss_ratio.pdf\n');

% Console: chassis assessment against both targets
passFailStr = 'meets';   % updated below if chassis fails any target
fprintf('\n');
fprintf('=================================================================\n');
fprintf(' Figure 2: Chassis Stiffness Assessment\n');
fprintf(' Evaluated at %d:%d split  (rollDiff = %g pp)\n', ...
        maxTuningSplit, 100-maxTuningSplit, rollDiff_tuning);
fprintf('=================================================================\n');
fprintf('  Kch current   = %g Nm/deg\n',   Kch_current);
fprintf('  Ratio         = %.4f\n',          R_current);
fprintf('  Loss          = %.2f%%\n',         loss_current);
fprintf('  Abs LLT lost  = %.3f pp  (of %g pp rollDiff)\n', ...
        rollDiff_tuning * loss_current/100, rollDiff_tuning);
fprintf('\n');
fprintf('  %-28s  %-16s  %-10s  %s\n', 'Target', 'Required Kch', 'Ratio', 'Status');
fprintf('  %s\n', repmat('-', 1, 64));
for t = 1:numel(targetLosses)
    if isnan(Kch_required(t))
        fprintf('  %-28s  %-16s  %-10s  UNKNOWN\n', ...
            sprintf('<= %g%%  (%s)', targetLosses(t), targetLabels{t}), 'N/A', 'N/A');
    else
        if Kch_current >= Kch_required(t)
            pfStr = 'PASS';
        else
            pfStr = 'FAIL';
            passFailStr = 'does not meet';
        end
        fprintf('  %-28s  %-16s  %-10s  %s\n', ...
            sprintf('<= %g%%  (%s)', targetLosses(t), targetLabels{t}), ...
            sprintf('%g Nm/deg', round(Kch_required(t))), ...
            sprintf('%.2f', ratio_at_target(t)), pfStr);
    end
end

% =========================================================================
% SECTION 4: EXPORT TO LaTeX
%
% Writes generated_values.tex containing one \newcommand per computed
% value. The main report (chassis_stiffness.tex) inputs this file so
% every number updates automatically when the script is rerun.
% Do not edit generated_values.tex by hand.
% =========================================================================

fid = fopen('generated_values.tex', 'w');
if fid == -1
    warning('Could not write generated_values.tex — check folder permissions.');
else
    fprintf(fid, '%% Auto-generated by chassis_stiffness_analysis.m\n');
    fprintf(fid, '%% %s\n', datestr(now));
    fprintf(fid, '%% Do not edit by hand.\n\n');

    % Inputs
    fprintf(fid, '\\newcommand{\\KrollfVal}{%g}\n',    Krollf);
    fprintf(fid, '\\newcommand{\\KrollrVal}{%g}\n',    Krollr);
    fprintf(fid, '\\newcommand{\\KtotVal}{%g}\n',      Ktot);
    fprintf(fid, '\\newcommand{\\KchCurrent}{%g}\n',   Kch_current);
    fprintf(fid, '\\newcommand{\\FrontRollPct}{%.1f}\n', frontRollPct_car);
    fprintf(fid, '\\newcommand{\\RearRollPct}{%.1f}\n',  100-frontRollPct_car);
    fprintf(fid, '\\newcommand{\\MaxTuningSplit}{%d}\n',  maxTuningSplit);
    fprintf(fid, '\\newcommand{\\MaxTuningRear}{%d}\n',   100-maxTuningSplit);
    fprintf(fid, '\\newcommand{\\WeightFront}{%.0f}\n',   100*wf);
    fprintf(fid, '\\newcommand{\\WeightRear}{%.0f}\n',    100*wr);

    % Derived
    fprintf(fid, '\\newcommand{\\RollDiffCar}{%g}\n',     rollDiff_car);
    fprintf(fid, '\\newcommand{\\RollDiffTuning}{%g}\n',  rollDiff_tuning);
    fprintf(fid, '\\newcommand{\\RatioCurrent}{%.3f}\n',  R_current);
    fprintf(fid, '\\newcommand{\\LossCurrent}{%.1f}\n',   loss_current);
    fprintf(fid, '\\newcommand{\\AbsLLTLost}{%.3f}\n',    rollDiff_tuning * loss_current/100);
    fprintf(fid, '\\newcommand{\\LLTatOperating}{%.2f}\n', LLT_at_operating);

    % LLT table rows (one \newcommand per Kch in Kch_list)
    rowLetters = 'ABCDEFGH';
    for k = 1:nK
        fprintf(fid, '\\newcommand{\\LLTrow%c}{%g & %.3f & %.3f \\\\}\n', ...
            rowLetters(k), Kch_list(k), LLT_front_at_split(k), LLT_rear_at_split(k));
    end

    % Target-specific values (suffixes: Twenty, Ten)
    targetSuffixes = {'Twenty', 'Ten'};
    for t = 1:numel(targetLosses)
        sfx = targetSuffixes{t};
        if ~isnan(Kch_required(t))
            fprintf(fid, '\\newcommand{\\RatioAtTarget%s}{%.2f}\n', sfx, ratio_at_target(t));
            fprintf(fid, '\\newcommand{\\KchRequired%s}{%.0f}\n',   sfx, Kch_required(t));
            fprintf(fid, '\\newcommand{\\KchDeficit%s}{%.0f}\n',    sfx, max(0, Kch_required(t)-Kch_current));
            if Kch_current >= Kch_required(t)
                fprintf(fid, '\\newcommand{\\PassFail%s}{meets}\n', sfx);
            else
                fprintf(fid, '\\newcommand{\\PassFail%s}{does not meet}\n', sfx);
            end
        else
            fprintf(fid, '\\newcommand{\\RatioAtTarget%s}{N/A}\n', sfx);
            fprintf(fid, '\\newcommand{\\KchRequired%s}{N/A}\n',   sfx);
            fprintf(fid, '\\newcommand{\\KchDeficit%s}{N/A}\n',    sfx);
            fprintf(fid, '\\newcommand{\\PassFail%s}{unknown}\n',  sfx);
        end
    end

    % Overall pass/fail (fails if chassis fails any target)
    fprintf(fid, '\\newcommand{\\PassFail}{%s}\n', passFailStr);

    fclose(fid);
    fprintf('\nExported: generated_values.tex\n');
end

% =========================================================================
% SECTION 5: DONE
% =========================================================================

fprintf('\n=================================================================\n');
fprintf(' Outputs written to current working directory:\n');
fprintf('   fig_LLT_curves.pdf\n');
fprintf('   fig_loss_ratio.pdf\n');
fprintf('   generated_values.tex\n');
fprintf('\n Run: pdflatex chassis_stiffness.tex  (twice)\n');
fprintf('=================================================================\n');

% =========================================================================
% LOCAL FUNCTION: frontLT_onePoint
%
% Implements the Deakin quasi-static model (Equations 2, 3, 4).
%
% The car is two masses connected by a chassis spring Kch. Each end has
% a suspension roll spring. Lateral acceleration creates moments Mf, Mr.
%
%   Mf = Krollf·φ₁ − Kch·φ₃          front moment balance      (Eq. 2)
%   Mr = Krollr·φ₂ + Kch·φ₃          rear moment balance       (Eq. 3)
%   φ₁ + φ₃ = φ₂                      kinematic compatibility   (Eq. 4)
%
% Substituting Eq. 4 into Eq. 3 eliminates φ₂, giving a 2×2 system:
%
%   [ Krollf,        −Kch      ] [φ₁]   [Mf]
%   [ Krollr,  Krollr+Kch      ] [φ₃] = [Mr]
%
% Mf = wf, Mr = wr (weight fractions). Scale cancels in the LLT% ratio.
%
% Inputs:
%   Krollf, Krollr  roll stiffnesses [Nm/deg]
%   Kch             chassis torsional stiffness [Nm/deg]
%   wf, wr          weight fractions (must sum to 1)
%
% Output:
%   frontLTpct      front LLT as % of total [%]
% =========================================================================
function frontLTpct = frontLT_onePoint(Krollf, Krollr, Kch, wf, wr)

    A = [ Krollf,           -Kch       ;
          Krollr,   Krollr + Kch       ];
    b = [wf; wr];

    x    = A \ b;
    phi1 = x(1);
    phi3 = x(2);
    phi2 = phi1 + phi3;

    Msf = Krollf * phi1;
    Msr = Krollr * phi2;

    frontLTpct = (Msf / (Msf + Msr)) * 100;
end
