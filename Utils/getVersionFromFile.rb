#!/usr/bin/env ruby

# Still in development

# CLI app that return file version when you input the download link or file path

require 'fiddle/import'

# Define the necessary functions from Windows API using Fiddle
module FileVersion
  extend Fiddle::Importer
  dlload 'version.dll'
  
  typealias 'DWORD', 'unsigned long'
  typealias 'LPCTSTR', 'const char*'
  
  # Get the file version info size
  extern 'DWORD GetFileVersionInfoSizeA(LPCTSTR, DWORD)'
  
  # Get the file version info
  extern 'DWORD GetFileVersionInfoA(LPCTSTR, DWORD, DWORD, void*)'
  
  # Retrieve a value from the file version info
  extern 'DWORD VerQueryValueA(const void*, LPCTSTR, void**, DWORD*)'
end

def get_file_version(file_path)
  # Get the file version info size
  info_size = FileVersion.GetFileVersionInfoSizeA(file_path, 0)

  if info_size > 0
    # Allocate memory buffer to store the file version info
    buffer = Fiddle::Pointer.malloc(info_size)

    # Retrieve the file version info
    FileVersion.GetFileVersionInfoA(file_path, 0, info_size, buffer)

    # Retrieve the file version value
    ffi = Fiddle::Pointer.malloc(Fiddle::SIZEOF_LONG)
    ffi_size = Fiddle::Pointer.malloc(Fiddle::SIZEOF_LONG)
    FileVersion.VerQueryValueA(buffer, '\\', ffi.ref, ffi_size.ref)

    major, minor, patch, build = ffi[0, 2].unpack('S2').concat(ffi[2, 2].unpack('S2'))
    file_version = "#{major}.#{minor}.#{patch}.#{build}"

    return file_version
  else
    return nil
  end
end

# Usage example
file_path = 'C:\Users\manh.duong\Downloads\officedeploymenttool_16327-20214.exe'

version = get_file_version(file_path)

if version.nil?
  puts "Unable to retrieve file version for #{file_path}"
else
  puts "File version of #{file_path}: #{version}"
end