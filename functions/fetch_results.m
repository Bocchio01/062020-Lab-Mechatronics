function simouts = fetch_results(test_label, controller_label, filter_label)

files_data = struct( ...
    'path', ['results\' test_label '\'], ...
    'dir_content', [], ...
    'N_files', 0);

files_data.dir_content = dir([files_data.path controller_label ' - ' filter_label '.mat']);
files_data.N_files = length(files_data.dir_content);

% Load results
simouts = cell(files_data.N_files, 2);
for file_idx = 1:files_data.N_files
    simouts{file_idx, 1} = load([files_data.path files_data.dir_content(file_idx).name]).logouts;
    simouts{file_idx, 2} = files_data.dir_content(file_idx).name;
end


end

