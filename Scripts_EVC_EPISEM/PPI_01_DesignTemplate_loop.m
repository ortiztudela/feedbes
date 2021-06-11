%% FeedBES PPI Analysis - Script 01 - Create design templates for every participant and run
%
% Authors: Javier Ortiz-Tudela feat. Isabelle Ehrlich
% Lifespan Cognitive and Brain Development (LISCO) Lab
% Goethe University Frankfurt am Main
%
%% Description
%
% This script comprises two functions. The first one creates the respective
% output file and calls the second function which does the actual job of exchanging the placeholders (ID, ses, and run).
%
%% GO!

% Add a zero as prefix to the single digit particpant numbers
for cSub=1:9
    ProcessTemplate_TimeContrast(['0',num2str(cSub)])
end
for cSub=10:30
    ProcessTemplate_TimeContrast(num2str(cSub))
end


function ProcessTemplate_TimeContrast(cSub)

V = {cSub '01' '1'; cSub '01' '2'; cSub '02' '3'; cSub '02' '4'};           % Here I specify the participant number, then the session and then the run number. Later the variables "ID", "ses", and "run" are assigned to these numbers

for I = 1:size(V,1)
    
ID = V{I, 1}
ses = V{I, 2}
run = V{I, 3}

OutputFile = sprintf('template_sub-%s_run%s.fsf', ID, run)
ProcessTemplateSingle('template_episem_hlr.fsf', OutputFile, 'ID', ID, 'ses', ses, 'run', run)   

end 
end

% The following function is called by the previous (Template =
% 'template_episem_hlr.fsf', OutputFile = OutputFile, varargin aka
% placeholders = ID, ses, run
function ProcessTemplateSingle ( Template, File, varargin )                
    
    Variables = struct( [] );
    
    for I = 1 : 2 : length( varargin )
        Variables( ( I - 1 ) / 2 + 1 ).Name = varargin{ I + 0 };
        Variables( ( I - 1 ) / 2 + 1 ).Text = varargin{ I + 1 };   
    end
    
    % Read Template ( Binary )
    h = fopen( Template );
    s = fread( h, '*char' )';
    fclose( h );
    
    % 
    
    for I = 1 : length( Variables )
         s = regexprep( s, sprintf( '\\$%s\\$', Variables( I ).Name ), Variables( I ).Text, 'ignorecase' );
    end
    
    % 
    
    h = fopen( File, 'w' ); % open the file on our Screen 'w'
    fwrite( h, s ); % save the file 
    fclose( h );
    
end
