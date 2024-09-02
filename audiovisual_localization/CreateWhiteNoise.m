% 参数设置
fs = 48000; % 采样率 (Hz)
duration = 0.5; % 总时长 (s)
fadeTime = 0.05; % 淡入淡出时长 (s)

% 生成白噪音
noise = randn(1, round(duration * fs));

% 生成淡入淡出窗口
fadeSamples = round(fadeTime * fs);
fadeIn = (1 - cos(pi * (0:fadeSamples-1) / fadeSamples)) / 2;
fadeOut = (1 + cos(pi * (0:fadeSamples-1) / fadeSamples)) / 2;

% 应用淡入淡出效果
noise(1:fadeSamples) = noise(1:fadeSamples) .* fadeIn;
noise(end-fadeSamples+1:end) = noise(end-fadeSamples+1:end) .* fadeOut;

% 将信号标准化到 [-1, 1] 区间
noise = noise / max(abs(noise));

% 创建双通道音频 (立体声)
stereoNoise = [noise; noise]; % 将单通道复制到两个通道

% 保存为 MP3 文件
audiowrite('white_noise_500ms.wav', stereoNoise', fs);
