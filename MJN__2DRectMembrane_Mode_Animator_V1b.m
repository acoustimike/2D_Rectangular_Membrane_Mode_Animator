%-------------------------------------------------------------------------%
% File   :  MJN__2DRectMembrane_Mode_Animator_V1b.m
% Summary:  Script to generate/animate modal plots for rectangular membranes
% Author :  Michael Newton
% Web    :  http://acoustimike.co.uk/
% Github :  https://github.com/acoustimike/2D_Rectangular_Membrane_Mode_Animator
% Date   :  26/10/2018
% Version:  V1a
%
% Log    :
%   01/11/2018 - Removed colourbar option. Normalised dimension control
%   using aspect ratio. Membrane modes shown as frequency multiples of f_1,1
%
% To Do  :
%   (1) Display breaks for aspect ratio of 1 (square) due to excessive
%   customisation for 1.5 (!)
%
%-------------------------------------------------------------------------%
clearvars;close all;clc;
set(0,'defaulttextinterpreter','latex')

%-------------------------------------------------------------------------%
% Membrane parameters
%-------------------------------------------------------------------------%
m       = 1;    % Modal index along 'x'
n       = 2;    % Modal index along 'y'
aspectR = 1.5;  % Aspect ratio: Lx/Ly
N_grid  = 50;   % Number of spatial sample points per Lx
c       = 1;    % Wave speed
Fs      = 200;   % Sample rate (Hz) (relevant only for video animation)


%-------------------------------------------------------------------------%
% Video animation controls
%-------------------------------------------------------------------------%
filenameOutput      = 'MembraneModes_m1_n2_V2'; % Output filename
option_MakeVideo    = 1;    % Make a video (1), don't make a video (0)
option_MakeGIF      = 0;    % Make a GIF (1) [requires option_MakeVideo=1], don't make a GIF (0)
frameRate           = 25;   % Output frame rate (25 fps is PAL standard)
N_Cycles_Video      = 3;    % Total number of whole cycles to plot (if video)
option_Colorbar     = 0;    % Display colorbar (1), don't display colorbar (0)
%-------------------------------------------------------------------------%


%-------------------------------------------------------------------------%
% Plotting controls
%-------------------------------------------------------------------------%
distance_TickLabels = 0.25;
figFont             = 22;


%-------------------------------------------------------------------------%
% Derived parameters etc
%-------------------------------------------------------------------------%
L_y                 = 1;
L_x                 = L_y*aspectR;
delta               = L_y/N_grid;
Ts                  = 1/Fs;
Nodal_Positions_x   = 0:L_x/m:L_x;Nodal_Positions_x = Nodal_Positions_x(2:end-1);
Nodal_Positions_y   = 0:L_y/n:L_y;Nodal_Positions_y = Nodal_Positions_y(2:end-1);
f                   = (c/2)*sqrt((m/L_x)^2 + (n/L_y)^2);
f1                  = (c/2)*sqrt((1/L_x)^2 + (1/L_y)^2);
N_Frames            = round(N_Cycles_Video*Fs/f);
tVec                = [0:Ts:(N_Frames-1)/Fs]';
x                   = 0:delta:L_x-delta;
y                   = 0:delta:L_y-delta;
x_mat               = repmat(x,[numel(y),1]);
y_mat               = repmat(y,[numel(x),1])';
X_x_mat             = sin(m*pi*x_mat/L_x);
Y_y_mat             = sin(n*pi*y_mat/L_y);
Psi                 = 0.2*(X_x_mat.*Y_y_mat);
T_t                 = cos(2*pi*f*tVec);


%-------------------------------------------------------------------------%
% Open up a video object if requested
%-------------------------------------------------------------------------%
switch option_MakeVideo
    case 0
    case 1
        myVideo = VideoWriter(filenameOutput,'MPEG-4');
        myVideo.FrameRate = frameRate;
        open(myVideo);
end


%-------------------------------------------------------------------------%
% Plotting (basic/static)
%-------------------------------------------------------------------------%
fig1            = figure(1);

fig1.Position   = [50 50 650*(16/11) 650];
fig1.Color      = [1,1,1];
ax(1)           = axes;
handleSurf1     = surf(ax(1),x_mat,y_mat,Psi);
%ax(1).XDir      = 'reverse';
axis equal
hold on
grid on
handle_xLab = xlabel('x-position','FontSize',figFont);
handle_yLab = ylabel('y-position','FontSize',figFont);
title1 = title({['Mode shapes for a pinned rectangular membrane'];['Aspect ratio $\frac{L_y}{L_x}$ = ' num2str(aspectR) ' --- ' ...
    'Mode: (' num2str(m) ', ' num2str(n) ') --- $f_{' num2str(m) ', ' num2str(n) '}$ = \textbf{' num2str(round((f/f1)*100)/100) '}$\cdot f_{1,1}$']},'FontSize',figFont+2);

% Show nodal lines
for nNode_x=1:m-1
    plx(nNode_x) = plot([Nodal_Positions_x(nNode_x),Nodal_Positions_x(nNode_x)],[0,L_y],'--','Color',0.9*[1,1,1],'LineWidth',3);
end
for nNode_y=1:n-1
    ply(nNode_y) = plot([0,L_x],[Nodal_Positions_y(nNode_y),Nodal_Positions_y(nNode_y)],'--','Color',0.12*[1,1,1],'LineWidth',3);
end

% Customise figure appearence
if m>1 && n>1
    legend1                 = legend([plx(1),ply(1)],['Nodal lines (x)'],['Nodal lines (y)']);
    legend1.Position        = [0.046155615586501 0.752307692307692 0.180188768826998 0.08];
    legend1.Interpreter     = 'Latex';
elseif m==1 && n>1
    legend1                 = legend([ply(1)],['Nodal lines (y)']);
    legend1.Position        = [0.046155615586501 0.752307692307692 0.180188768826998 0.08];
    legend1.Interpreter     = 'Latex';
elseif m>1 && n==1
    legend1                 = legend([plx(1)],['Nodal lines (x)']);
    legend1.Position        = [0.046155615586501 0.752307692307692 0.180188768826998 0.08];
    legend1.Interpreter     = 'Latex';
end
ax(1).ZAxis.Visible     = 'off';
%ax(1).CameraPosition    = [-9.5858 -3.1858 5.9917];
ax(1).FontSize          = figFont;
ax(1).ZLim              = [-max(max(abs(Psi))),max(max(abs(Psi)))];
ax(1).XTick             = [0:distance_TickLabels:L_x];
ax(1).YTick             = [0:distance_TickLabels:L_y];
ax(1).Position          = [0.0793910972947948 0.0230279822716346 0.851009615384615 0.936895094651443];
ax(1).TickLabelInterpreter = 'Latex';
set(get(ax(1),'xlabel'),'rotation',23)
%set(get(ax(1),'ylabel'),'rotation',-8)

% Normalise colour range for current data
caxis(ax(1),[-max(max(abs(Psi))), max(max(abs(Psi)))]);

annotation(fig1,'textbox',...
    [0.767307692307693 0.0176923076923077 0.22 0.078],...
    'String',{['\textcopyright \hspace{0.01cm} Acoustics and Audio Group, University of Edinburgh'];['\texttt{www.acoustics.ed.ac.uk}']},...
    'FitBoxToText','off','Interpreter','Latex','FontSize',figFont-8);

%-------------------------------------------------------------------------%
% Plotting (animated)
%-------------------------------------------------------------------------%

% Make an H264 video if requested
switch option_MakeVideo
    case 0
    case 1
        for nLoop = 1:N_Frames
            Psi_animate     = T_t(nLoop)*Psi;
            set(handleSurf1, 'ZData', Psi_animate);
            drawnow;
            F               = getframe(fig1);
            writeVideo(myVideo, F);
            disp(['Frame: ' num2str(nLoop) ' of ' num2str(N_Frames)])
            
            % Make a GIF if requested
            switch option_MakeGIF
                case 1
                    F_im    = frame2im(F);
                    [A,map] = rgb2ind(F_im,256);
                    if nLoop == 1
                        imwrite(A,map,[filenameOutput '.gif'],'gif','LoopCount',Inf,'DelayTime',Ts);
                    else
                        imwrite(A,map,[filenameOutput '.gif'],'gif','WriteMode','append','DelayTime',Ts);
                    end
            end
        end
        % Finish writing video file to disk
        close(myVideo);
end

