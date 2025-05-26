function x = expand_A_law(y, A)
%EXPAND_A_LAW Th?c hi?n m? r?ng (expansion) A-law.
%   x = expand_A_law(y, A) nh?n ??u v�o l� t�n hi?u ?� ???c n�n y v�
%   tham s? A, tr? v? t�n hi?u sau khi m? r?ng x theo c�ng th?c A-law.
%
% C�ng th?c n�n A-law th??ng ???c ??nh ngh?a nh? sau:
%   F(x) = sign(x) * { A*|x|/(1+log(A)), n?u |x| < 1/A
%                      (1+log(A*|x|))/(1+log(A)), n?u 1/A <= |x| <= 1 }
%
% Do ?�, h�m m? r?ng (inverse function) ???c t�nh nh? sau:
%   N?u |y| < 1/(1+log(A)) th�
%       x = sign(y) * |y|*(1+log(A))/A;
%   N?u |y| >= 1/(1+log(A)) th�
%       x = sign(y) * exp(|y|*(1+log(A))-1)/A;
%
% L?u �: ? ?�y s? d?ng log l� logarith t? nhi�n (log base e).

    % T�nh ng??ng cho h�m m? r?ng
    threshold = 1 / (1 + log(A));
    
    % Kh?i t?o x c� c�ng k�ch th??c v?i y
    x = zeros(size(y));
    
    % Tr??ng h?p 1: |y| < threshold
    idx = abs(y) < threshold;
    x(idx) = sign(y(idx)) .* abs(y(idx)) * (1 + log(A)) / A;
    
    % Tr??ng h?p 2: |y| >= threshold
    idx = abs(y) >= threshold;
    x(idx) = sign(y(idx)) .* exp(abs(y(idx)) * (1 + log(A)) - 1) / A;
end
