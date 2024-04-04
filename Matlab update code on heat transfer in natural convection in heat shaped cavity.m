% Parameters
L = 1;          % Length of cavity
W = 1;          % Width of cavity
H = 0.1;        % Height of cavity
T_hot = 100;    % Temperature of hot wall
T_cold = 0;     % Temperature of cold walls
nx = 51;        % Number of grid points in x-direction
ny = 51;        % Number of grid points in y-direction
dx = L/(nx-1);  % Grid spacing in x-direction
dy = W/(ny-1);  % Grid spacing in y-direction
max_iter = 100; % Maximum number of iterations
tolerance = 1e-5;% Convergence tolerance
alpha = 0.1;    % Thermal diffusivity

% Initialize temperature array
T = ones(nx, ny) * T_cold;

% Set up VideoWriter object

writerObj = VideoWriter('temperature_evolution.avi'); % Specify the file name
writerObj.FrameRate = 10; % Set the frame rate

% Open the video writer object
open(writerObj);

% Create a figure for animation
figure;

% Main loop (iterate until convergence)
for iter = 1:max_iter
    % Boundary conditions
    T(:,1) = T_cold;            % Left cold wall
    T(:,end) = T_cold;          % Right cold wall
    T(1,:) = T_hot;             % Hot wall
    T(ceil(end/2-round(H/(2*dy))):floor(end/2+round(H/(2*dy))), end) = T_cold; % Middle cold wall

    % Compute temperature field using finite difference method
    T_new = T;
    for i = 2:nx-1
        for j = 2:ny-1
            % Finite difference equation
            T_new(i,j) = T(i,j) + alpha * ( (T(i+1,j) - 2*T(i,j) + T(i-1,j))/dx^2 + (T(i,j+1) - 2*T(i,j) + T(i,j-1))/dy^2 );
        end
    end
    
    % Check for convergence
    if max(abs(T_new(:) - T(:))) < tolerance
        disp(['Converged at iteration ', num2str(iter)]);
        break;
    end
    
    % Update temperature array
    T = T_new;
    
    % Plot the current temperature distribution in 3D
    [X, Y] = meshgrid(linspace(0,L,nx), linspace(0,W,ny));
    surf(X, Y, T', 'EdgeColor', 'none');
    colorbar;
    xlabel('x');
    title(['Iteration: ', num2str(iter)]);
    axis([0 L 0 W 0 100]); % Set axis limits for consistency
    
    % Capture the frame
    frame = getframe(gcf);
    
    % Write the frame to the video file
    writeVideo(writerObj, frame);
end

% Close the video writer object
close(writerObj);
