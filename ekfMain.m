%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALISATION

hold on;
predictionSetup;
updateSetup;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN LOOP
for t = tt
%%     PREDICTION STEP
% xa1 is the first absolute Pose provided by libViso
% xa2 the second
    q1 = [aw(t-1), aq1(t-1), aq2(t-1), aq3(t-1)];   
    q1 = quatNormal( q1 );
        
    q2 = [aw(t), aq1(t), aq2(t), aq3(t)];
    q2 = quatNormal( q2 );
        
%     State Vectors (x, y, z, qw, qx, qy, qz)
    xa1  = [ aX(t-1), aY(t-1), aZ(t-1), q1(1), q1(2), q1(3), q1(4) ];
    xa2  = [ aX(t), aY(t), aZ(t), q2(1), q2(2), q2(3), q2(4) ];
    
    xLast = X( ((t-2)*7)+1: (t-1)*7 );
    cLast = C( ((t-2)*7)+1: (t-1)*7, : );
    
    
    [Xnew Cnew] = prediction(xLast, cLast, xa1, xa2, CovRel );

% Let the state-, covariance and timestamp-Vector grow
    X = [ X;  Xnew ];
    C = [ C;  Cnew ];

%%      UPDATE STEP
%     Try to find Loop closing candidate with a certain sampling rate
    if mod(t,loopSample) == 0  
%     Load Stereo Images from Database 
%       ( --> corresponding to the current timestamp of the odometry)
        [fNameLeft fNameRight status]= getImageByTimestamp(tMeasureOdo(t), ...
                                                    fLeft, fRight);
        if ( status == 0 )
%           if status == 0 no corresponding stereo image pair has been
%           found: skip this
        else
%           if status == 1 corresponding stereo image pair has been
%           found: look for loop closing
            ILeft  = imread([pathLeft '/' fNameLeft]);  
            IRight = imread([pathRight '/' fNameRight]);  
        
%           Pass already observed Images to update function
            fCurrentLoop = fLoop(1:t-10);

            [zk timestampsLC status] = update( ILeft, IRight, ...
                                                  fCurrentLoop, pathLoop );
            if( status == 1 )
%             If status is equal to 1 we have at least one loop closing
%             Don't forget to safe the timestamp of the reference Image
%             (left image) at the end of the timestamp vector
                timeRef = str2double( fNameLeft( 11:end-4 ) );
                timestampsLC = [ timestampsLC; timeRef];
                
%             Calculate h1 - hn: these are the realtive motions of states
%             taken from the state-vector (state estimations) corresponding
%             to the detected loop closing. In terms of EKF this is hk.
                [hk H] = calculateHandhk( X, tMeasureOdo, timestampsLC );
                
            end
        end
    end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOTTING
plotEKF;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SHUTTING DOWN MATLAB
clearMATLAB;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright (c) 2014, Markus Solbach
% All rights reserved.

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:

%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.