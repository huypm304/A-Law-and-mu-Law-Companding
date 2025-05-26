clear; 
clc;

% 1. Load speech signal 
Fs = 4000; 
[mSpeech,Fs] = audioread("MaleSpeech-16-4-mono-20secs.wav"); 
% sound(mSpeech,Fs) 
% Consider the speech signal in 1.5s 
t = 0:1/Fs:1.5; 
plot(t, mSpeech(1:length(t)),'LineWidth',2); 
hold on 

% 2. Quantize the sample signal  
L = 16; %the number of quantization levels 
V_p = 0.5625; %the peak voltage of signal  
% Determine the single quantile interval ?-wide 
q = (2*V_p)/(L-1); % Use the exact equation  
s_q_2 = quan_uni(mSpeech(1:length(t)),q); % Uniform quantization 
% Plot the sample signal and the quantization signal 
plot(t,s_q_2,'ro','MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor','r'); 

% 3. Calculate the average quantization noise power,...  
% the average power of the sample signal and SNR 
e_uni = mSpeech(1:length(t)) - s_q_2; % error between sample signal and quantized signal 

pow_noise_uni = 0; 
pow_sig = 0; 

for i = 1:length(t) 
    pow_noise_uni = pow_noise_uni + e_uni(i)^2; 
    pow_sig = pow_sig + mSpeech(i)^2; 
end 

pow_noise_uni = pow_noise_uni / length(e_uni);
pow_sig = pow_sig / length(mSpeech(1:length(t)));

SNR_a_uni = 10*log10(pow_sig/pow_noise_uni)
%--------compression-------------
% 5. Compress the sample signal �mSpeech�
mu = 255; % or A = ???; use the standard value
A = 87.6;
y_max = V_p; 
x_max = V_p;
% Replace the compress equation for u-law and A-law
% with x is the 'mSpeech' signal
Tu = log(1 + mu * abs(mSpeech) / x_max);
Mau = log(1 + mu);
s_c_5 = y_max*sign(mSpeech).*(Tu/Mau); 
 
% Plot the compress signal; 
plot(t,s_c_5(1:length(t)),'--'); 

% 6. Quantize the compress signal and plot the quantized signal 
s_q_6 = quan_uni(s_c_5,q); 
plot(t,s_q_6(1:length(t)),'b^','MarkerSize',6,'MarkerEdgeColor','b','MarkerFaceColor','b'); 

% 7. Expand the quantized signal 
Tu_1 = (exp(s_q_6 .* (log(1 + mu)) ./ (y_max .* sign(s_q_6))) - 1) * x_max;
s_e_7 = zeros(size(s_q_6)); 

for i = 1:length(s_q_6)
    if sign(s_q_6(i)) == 1
        s_e_7(i) = Tu_1(i) / mu;
    elseif sign(s_q_6(i)) == 0
        s_e_7(i) = 0;
    elseif sign(s_q_6(i)) == -1
        s_e_7(i) = (-1 * Tu_1(i)) / mu;
    end
end

plot(t,s_e_7(1:length(t)),'g*','MarkerSize',6,'MarkerEdgeColor','g','MarkerFaceColor','g'); 
xlim([0.52 0.59]);
ylim([-0.5625 0.5625]);
legend('Sample signal','Uniform quantized values','Compress signal','Compress quantized values','Nouniform quantized values'); 

% 9. Calculate the average quanti n noise power,...  
% the average power of the analog signal and SNR 
e_com = mSpeech(1:length(t)) - s_e_7; 
pow_noise_com = 0; 
pow_sig_2 = 0; 
for i = 1:length(t) 
    pow_noise_com = pow_noise_com + e_com(i)^2; 
    pow_sig_2 = pow_sig_2 + s_e_7(i)^2; 
end

SNR_a_com = 10*log10(pow_sig_2 /pow_noise_com);
mSpeech;
s_e_7;

function quan_sig = quan_uni(sig,q) 
    for i = 1:length(sig) 
        quan_sig(i) = quant(sig(i),q); 
        d = sig(i) - quan_sig(i); 
        if d == 0 
            quan_sig(i) = quan_sig(i) + q/2; 
        elseif (d > 0) && (abs(d) < q/2) 
            quan_sig(i) = quan_sig(i) + q/2; 
        elseif (d > 0) && (abs(d) >= q/2) 
            quan_sig(i) = quan_sig(i) - q/2; 
        elseif (d < 0) && (abs(d) < q/2) 
            quan_sig(i) = quan_sig(i) - q/2; 
        elseif (d < 0) && (abs(d) >= q/2) 
            quan_sig(i) = quan_sig(i) + q/2; 
        end 
    end 
end