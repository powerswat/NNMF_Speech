function R = rec_cnmf(W,H,myeps)
% function R = rec_cnmf(W,H,myeps)
%
% Reconstruct a matrix R using Convolutive NMF using W and H matrices.
%

[n, r, win] = size(W);
m = size(H,2);

R = zeros(n,m);
for t = 0:win-1
    R = R + W(:,:,t+1)*shift(H,t);
end

R = max(R,myeps);

end

function O = shift(I, t)
% function O = shift(I, t)
%
% Shifts the columns of an input matrix I by t positions.  
% Zeros are shifted in to new spots.
%

if t < 0
    O = [I(:,-t+1:end) zeros(size(I,1),-t) ];
else
    O = [zeros(size(I,1),t) I(:,1:end-t) ];
end

end
