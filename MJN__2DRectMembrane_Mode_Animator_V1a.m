%-------------------------------------------------------------------------%
% File   :  MJN__2DRectMembrane_Mode_Animator_V1a.m
% Summary:  Script to generate/animate modal plots for rectangular membranes
% Author :  Michael Newton
% Web    :  http://acoustimike.co.uk/
% Github :  https://github.com/acoustimike/2D_Rectangular_Membrane_Mode_Animator
% Date   :  26/10/2018     
% Version:  V1a
%-------------------------------------------------------------------------%
clearvars;close all;clc;
set(0,'defaulttextinterpreter','latex')


%-------------------------------------------------------------------------%
% Video animation controls
%-------------------------------------------------------------------------%
option_MakeVideo    = 1;    % Make a video (1), don't make a video (0)
option_MakeGIF      = 0;    % Make a GIF (1) [requires option_MakeVideo=1], don't make a GIF (0) 
filenameOutput      = 'MembraneModes_m3_n4_V1'; % Output filename
frameRate           = 25;   % Output frame rate (25 fps is PAL standard)
N_Cycles_Video      = 3;    % Total number of whole cycles to plot (if video)
option_Colorbar     = 0;    % Display colorbar (1), don't display colorbar (0)
%-------------------------------------------------------------------------%


%-------------------------------------------------------------------------%
% Membrane parameters
%-------------------------------------------------------------------------%
m       = 3;        % Modal index along 'x'
n       = 4;        % Modal index along 'y'
L_x     = 1.5;      % Membrane length along 'x'
L_y     = 2;        % Membrane length along 'y'
delta   = 0.035;    % Spatial grid spacing
%delta   = 0.01;     % Spatial grid spacing
c       = 400;      % Wave speed
Fs      = 44100;    % Sample rate (relevant only for video animation)


%-------------------------------------------------------------------------%
% Plotting controls
%-------------------------------------------------------------------------%
distance_TickLabels = 0.2;
figFont             = 26;
figFontName         = 'Times';


%-------------------------------------------------------------------------%
% Derived parameters etc
%-------------------------------------------------------------------------%
Ts                  = 1/Fs;
Nodal_Positions_x   = 0:L_x/m:L_x;Nodal_Positions_x = Nodal_Positions_x(2:end-1);
Nodal_Positions_y   = 0:L_y/n:L_y;Nodal_Positions_y = Nodal_Positions_y(2:end-1);
f                   = (c/2)*sqrt((m/L_x)^2 + (n/L_y)^2);
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
fig1.Position   = [50 50 650*(16/10) 650];
fig1.Color      = [1,1,1];
ax(1)           = axes;
handleSurf1     = surf(ax(1),x_mat,y_mat,Psi);
axis equal
hold on
grid on
xlabel('x-position (m)','FontSize',figFont,'FontName',figFontName)
ylabel('y-position (m)','FontSize',figFont,'FontName',figFontName)
title({['Mode shapes for a rectangular membrane.'];['$L_x$ = ' num2str(L_x) 'm, $L_y$ = ' num2str(L_y) 'm. ' ...
    'Mode: (' num2str(m) ', ' num2str(n) '). $f_{' num2str(m) ', ' num2str(n) '}$ = ' num2str(round(f*100)/100) 'Hz.']},'FontSize',figFont+2,'FontName',figFontName)

% Show nodal lines
for nNode_x=1:m-1
    pl(nNode_x) = plot([Nodal_Positions_x(nNode_x),Nodal_Positions_x(nNode_x)],[0,L_y],'--','Color',0.9*[1,1,1],'LineWidth',3);
end
for nNode_y=1:n-1
    pl(nNode_y) = plot([0,L_x],[Nodal_Positions_y(nNode_y),Nodal_Positions_y(nNode_y)],'--','Color',0.12*[1,1,1],'LineWidth',3);
end


%handleSurf1.EdgeColor = 'none';
ax(1).ZAxis.Visible     = 'off';
ax(1).CameraPosition    = [-9.5858 -3.1858 5.9917]; %[-8.9374 -4.8785 5.6434];
ax(1).FontName          = figFontName;
ax(1).FontSize          = figFont-4;
ax(1).ZLim              = [-max(max(abs(Psi))),max(max(abs(Psi)))];
ax(1).XTick             = [0:distance_TickLabels:L_x];
ax(1).YTick             = [0:distance_TickLabels:L_y];

caxis(ax(1),[-max(max(abs(Psi))), max(max(abs(Psi)))]);

switch option_Colorbar
    case 1
        handleCBar              = colorbar('peer',ax(1));
        handleCBar.Position     = [0.085 0.12 0.012 0.79];
        handleCBar.Label.String = 'Membrane displacement (normalised)';
        handleCBar.FontSize     = figFont-2;
        handleCBar.Ticks        = linspace(-max(max(abs(Psi))),max(max(abs(Psi))),9);
        handleCBar.TickLabels   = num2cell(linspace(-1,1,9));
        handleCBar.FontName     = figFontName;
end


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

