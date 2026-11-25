function [rxstream] = disambiguationQPSK(zI, zQ, disambiguationHeader)
%function [rxstream] = disambiguation(zI, zQ, disambiguationHeader),
%Corrects the ambiguity after the phase synchronization
%Input parameters
% zI, zQ: Output symbols of the derotation module
% synchroAmbiguity: trainig sequence for disambiguation
%
%Output parameters
% rxstream: Corrected bits 
%

t=2*disambiguationHeader(1:2:end)-1; %real part of synchroAmbiguity
signalXcorr_tzI= xcorr(t, zI);
[maxAbsXcorr_tzI, indexI] = max( abs( signalXcorr_tzI  ) );
Xcorr_tzI = signalXcorr_tzI(indexI);

signalXcorr_tzQ= xcorr(t, zQ);
[maxAbsXcorr_tzQ, indexQ] = max( abs( signalXcorr_tzQ  ) );
Xcorr_tzQ = signalXcorr_tzQ(indexQ);


rxstreamI = zeros(size(zI));
rxstreamQ = zeros(size(zQ));
if ( abs( maxAbsXcorr_tzI ) >= abs( maxAbsXcorr_tzQ ) ) 
    if ( Xcorr_tzI>0 )
        disp('No change')
        rxstreamI(zI<0)=0;
        rxstreamI(zI>=0)=1;
        rxstreamQ(zQ<0)=0;
        rxstreamQ(zQ>=0)=1;  
    else
        disp('+180')
        rxstreamI(zI<0)=1;
        rxstreamI(zI>=0)=0;
        rxstreamQ(zQ<0)=1;
        rxstreamQ(zQ>=0)=0;
  end
else % abs( maxXcorr_tzI ) < abs( maxXcorr_tzQ )
    if ( Xcorr_tzQ>=0 )
        disp('+90')
        rxstreamI(zQ>=0)=1;
        rxstreamI(zQ<0)=0;
        rxstreamQ(zI>=0)=0;
        rxstreamQ(zI<0)=1;
    else
        disp('-90')
        rxstreamI(zQ>=0)=0;
        rxstreamI(zQ<0)=1;
        rxstreamQ(zI>=0)=1;
        rxstreamQ(zI<0)=0;
    end %if (maxXcorr_tzQ)
end %main if

rxstream = zeros(1, 2*length(zI) );
rxstream(1:2:end) = rxstreamI;
rxstream(2:2:end) = rxstreamQ;