function data = load_data(file_path, electromagnet_idx)

data = struct( ...
        'time', [], ...
        'position', [], ...
        'velocity', [], ...
        'current', [], ...
        'control', [], ...
        'voltage', []);

if (nargin == 1)
    electromagnet_idx = 1;
end

try
    measurements = load(file_path).measurements;
    data.time = measurements(1, :)';
    data.position = measurements(2, :)';
    data.velocity = measurements(3, :)';
    data.current = measurements(3 + electromagnet_idx, :)';
    data.control = measurements(5 + electromagnet_idx, :)';
catch
    MLS2EMExpData = load(file_path).MLS2EMExpData;
    data.time = MLS2EMExpData.time;
    data.position = MLS2EMExpData.signals(1).values;
    data.velocity = MLS2EMExpData.signals(2).values;
    data.current = MLS2EMExpData.signals(3).values(:, electromagnet_idx);
    data.control = MLS2EMExpData.signals(4).values(:, electromagnet_idx);
end

data.voltage = arrayfun(@(x) interp1(0:0.1:1, [0.043, 0.613, 1.768, 2.93, 4.10, 5.26, 6.43, 7.59, 8.80, 9.96, 11.06], x), data.control);

end