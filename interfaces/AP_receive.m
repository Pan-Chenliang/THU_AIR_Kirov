function [pwm, reset] = AP_receive(time)
global u
persistent connected frame_time last_sim_time frame_count last_SITL_frame past_time last_pwm

if isempty(u) || time == 0
    pnet('closeall') % close any connections left open from past runs
    u = pnet('udpsocket',9002);
    pnet(u,'setwritetimeout',1);
    pnet(u,'setreadtimeout',0);

    connected = false;
    frame_time = tic;
    last_sim_time = 0;
    frame_count = 0;
    last_SITL_frame = -1;
    past_time = -1;
    last_pwm = ones(1,16)*1000;
    last_pwm(5) = 2000;
    last_pwm(13,15,16) = 1500;
end

if past_time == time
    error('Receive repeat time');
end
past_time = time;

print_frame_count = 1000;
bytes_read = 4 + 4 + 16*2;

reset = false;
pwm = last_pwm;
received_valid_packet = false;

while true
    % 非阻塞读取：无数据时会立刻返回。
    in_bytes = pnet(u,'readpacket',bytes_read);

    if in_bytes <= 0
        if ~connected
            % 首帧握手：等到 SITL 发来第一帧 PWM。
            pause(0.001);
            continue;
        end

        % 已完成握手：无新包时立刻返回上一帧 PWM。
        break;
    end

    % 若有积压数据，继续读取，尽量只保留最新控制帧。
    if in_bytes > bytes_read
        if in_bytes == u.InputBufferSize
            fprintf('Buffer reset\n')
        end
        continue;
    end

    % 读取 SITL 发来的 PWM 包。
    magic = pnet(u,'read',1,'UINT16','intel');
    double(pnet(u,'read',1,'UINT16','intel')); % 不使用帧率字段
    SITL_frame = pnet(u,'read',1,'UINT32','intel');
    received_pwm = double(pnet(u,'read',16,'UINT16','intel'))';

    if magic ~= 18458
        warning('incorrect magic value')
        continue;
    end

    if SITL_frame < last_SITL_frame
        connected = false;
        reset = true;
        fprintf('Controller reset\n')
    elseif SITL_frame == last_SITL_frame
        fprintf('Duplicate input frame\n')
        continue;
    elseif SITL_frame ~= last_SITL_frame + 1 && connected
        fprintf('Missed %i input frames\n', ...
            SITL_frame - last_SITL_frame - 1)
    end

    last_SITL_frame = SITL_frame;
    last_pwm = received_pwm;
    pwm = last_pwm;
    received_valid_packet = true;

    if ~connected
        % 从首个 SITL PWM 包取得回传地址和端口。
        [ip, port] = pnet(u,'gethost');
        remoteHost = sprintf('%d.%d.%d.%d', ...
            ip(1), ip(2), ip(3), ip(4));

        % 让 AP_send 中的 writepacket 明确回传给 SITL。
        pnet(u,'udpconnect',remoteHost,port);

        connected = true;
        fprintf('Connected to %s:%d\n', remoteHost, port)
    end
end

% 仅统计实际收到的 SITL 帧率。
if received_valid_packet
    frame_count = frame_count + 1;

    if rem(frame_count,print_frame_count) == 0
        total_time = toc(frame_time);
        frame_time = tic;
        sim_time = time - last_sim_time;
        last_sim_time = time;
        time_ratio = sim_time / total_time;

        fprintf("%0.2f fps, %0.2f%% of realtime\n", ...
            print_frame_count / total_time, time_ratio * 100)
    end
end

end