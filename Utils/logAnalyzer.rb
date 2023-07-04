# Simple log analyzer to parse error from v4Debug logs
# As beta version, this script should parse all the errors available in the input folder or single file
#  Input:
#     - logs folder
#     - signatures (optional): if there is no signature then return all the error
#  Output:
#     - error with format json
# Enhance:
#     - search error based on signature
#     - search error based on method

# 1. Get all the file logs in the input folder
# 2. Get all the error from each log and return object. Use the time as the key
# 3. Append all the errors into a hash and return the outpput
require 'json'

def get_log_files(input_dir)
    log_dir = Dir.entries(input_dir)
    file_list = []
    log_dir.each {
        |file_name|
        file_list.append("#{input_dir}/#{file_name}") if file_name.include? "v4Debug"
    }
    return file_list
end

# parsing each log
# return hash object with time is key
def parsing_errors(log_file)
    errors_hash = {}

    lines = File.readlines(log_file, :encoding => 'ISO-8859-1')
    lines.each_with_index {
        |line, index|
        next if (line.match(/error"/).nil? && line.match(/result"/).nil? && line.match(/input"/).nil?)

        index_space = line.index(/] \w+/)
        time = line[0..index_space]

        error_stack = line[index_space+2..-1]
        index_space = error_stack.index(/\{/)
        error_stack = error_stack[index_space..-1]

        errors_hash[:"#{time}[#{index+1}][#{log_file}]"] = JSON.parse(error_stack.to_json)

    }

    return errors_hash
end

def getting_all_error(input_dir)
    file_list = get_log_files(input_dir)
    error_result = {}
    file_list.each {
        |file|
        puts file
        error_result.merge!(parsing_errors(file))
    }
    return error_result
end

# getting the result and output to the terminal
result = getting_all_error("C:\\Users\\trang.vu\\Downloads\\21.04_logs\\")
result.keys.each {
    |key|
    next if result[key].to_s.match(/\"signature\":813/).nil?
    puts key
    puts JSON.pretty_generate(JSON.parse(result[key]))
}
