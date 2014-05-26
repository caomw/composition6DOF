function P3 = projectDisparityTo3d( left, disparity )
%   This function projects a 2D Point into 3D using the disparity given
%   from a stereo vision system and Q, the Reprojection matrix of this
%   system, which is hard coded in stereoCameraReproject

%   Camera Parameter
    intrinsic1 = [749.642742046463, 0.0, 539.67454188334; ...
                    0.0, 718.738253774844, 410.819033898981; 0.0, 0.0, 1.0];
    radial1     = [-0.305727818014552, 0.125105811097608, 0.0021235435545915]; 
    tangential1 = [0.00101183009692414, 0.0];
    
    intrinsic2 = [747.473744648049, 0.0, 523.981339714942; ...
                    0.0, 716.76909875026, 411.218247507688; 0.0, 0.0, 1.0];     
    radial2     = [-0.312470781595577, 0.140416928438558, 0.00187045432179417]; 
    tangential2 = [-0.000772438457736498, 0.0];  
    
    
    left = [1, 2];
    disparity = 0.02;
        
    Q = stereoCameraReproject;
    
    point3 = [ left(1) + Q(1,4), left(2) + Q(2,4), Q(3,4)];
    w      = Q(4,3) .* disparity + Q(4,4);
    P3     = point3 .* (1.0/w);
    
end