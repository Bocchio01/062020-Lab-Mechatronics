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

data.voltage = U_to_V(data.control);

end