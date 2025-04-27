% cal_h is the call function to call the blackbox h-function and evaluate
% the quantity of interest (QoI), for all random samples 
% the size of y: [number of samples, number of QoIs]
% example of QoI: acceleration, stress, sound pressure etc 


% 22/04/2021 @ Franklin Court, Cambridge  [J Yang] --> initial trial 
% 32/05/2022 @ Franklin Court, Cambridge  [J Yang] --> update with dummy
% function and waitbar
% 2024 --> Added proper error handling for waitbar

function h_Results = cal_h (xS, Opts)

    % assign options
    nS = Opts.nSampMC;
    hfunction = str2func(Opts.funName);
    waith = [];
    
    try
        % Create waitbar with cancel button
        waith = waitbar(0,'Please wait...',...
            'CreateCancelBtn','setappdata(gcbf,''cancelling'',1)');
        setappdata(waith,'cancelling',0);

        if strcmp(Opts.funName,'trial')                  % trail function 
            y = sum(xS.samp);
        elseif strcmp(Opts.funName,'design_dummy')       % dummy function 
            y = xS.samp;
        else
            % do a run to check size of output y
            y0 = hfunction(xS.samp(1,:));
            Ne = length(y0);
            
            % loop over all samples 
            y = zeros(nS,Ne);
            
            for ii=1:nS
                if getappdata(waith,'cancelling')
                    break
                end
                
                y(ii,:) = hfunction(xS.samp(ii,:));
                
                waitbar(ii / nS, waith, strcat(num2str(ii),'/',num2str(nS),'{ }','Samples' )); 
            end
        end
        
        h_Results.y = y;
        
    catch ME
        % If any error occurs, make sure we clean up the waitbar
        if ~isempty(waith) && ishandle(waith)
            delete(waith);
        end
        % Rethrow the error to maintain the error state
        rethrow(ME);
    end
    
    % Clean up waitbar on successful completion
    if ~isempty(waith) && ishandle(waith)
        delete(waith);
    end
end