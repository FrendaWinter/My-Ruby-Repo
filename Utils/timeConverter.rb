#!/usr/bin/env ruby
# This Ruby CLI app for Time conversion

# gem install date
require 'date'

def show_help
    puts <<~TEXT
        Description: Takes a string with a time representation and outputs a string with a time representation,
                    in the process converting the one representation to another.

        Default output representation is 'MM/DD/YYYY'

        Example usage:
            ruby timeConverter.rb '2023-04-17' -i '%Y-%m-%d' -o '%m/%d/%Y'    ===>  Output will be: 04/17/2023
            ruby timeConverter.rb 'January 17, 2023' -i '%B %d, %Y' -o '%d-%m-%Y'  ===>  Output will be: 17-01-2023

            ----  Please use single quotes :)) ------

        How I format data:
            Formats date according to the directives in the given format string.
                The directives begins with a percent (%Q( character.
                Any text not listed as a directive will be passed through to the
                output string.

                The directive consists of a percent (%) character,
                zero or more flags, optional minimum field width,
                optional modifier and a conversion specifier
                as follows.

                %<flags><width><modifier><conversion>

                Flags:
                -  don't pad a numerical output.
                _  use spaces for padding.
                0  use zeros for padding.
                ^  upcase the result string.
                #  change case.
                :  use colons for %z.

                The minimum field width specifies the minimum width.

                The modifier is "E" and "O".
                They are ignored.

                Format directives:

                Date (Year, Month, Day):
                    %Y - Year with century (can be negative, 4 digits at least)
                            -0001, 0000, 1995, 2009, 14292, etc.
                    %C - year / 100 (round down.  20 in 2009)
                    %y - year % 100 (00..99)

                    %m - Month of the year, zero-padded (01..12)
                            %_m  blank-padded ( 1..12)
                            %-m  no-padded (1..12)
                    %B - The full month name (``January'')
                            %^B  uppercased (``JANUARY'')
                    %b - The abbreviated month name (``Jan'')
                            %^b  uppercased (``JAN'')
                    %h - Equivalent to %b

                    %d - Day of the month, zero-padded (01..31)
                            %-d  no-padded (1..31)
                    %e - Day of the month, blank-padded ( 1..31)

                    %j - Day of the year (001..366)

                Time (Hour, Minute, Second, Subsecond):
                    %H - Hour of the day, 24-hour clock, zero-padded (00..23)
                    %k - Hour of the day, 24-hour clock, blank-padded ( 0..23)
                    %I - Hour of the day, 12-hour clock, zero-padded (01..12)
                    %l - Hour of the day, 12-hour clock, blank-padded ( 1..12)
                    %P - Meridian indicator, lowercase (``am'' or ``pm'')
                    %p - Meridian indicator, uppercase (``AM'' or ``PM'')

                    %M - Minute of the hour (00..59)

                    %S - Second of the minute (00..59)

                    %L - Millisecond of the second (000..999)
                    %N - Fractional seconds digits, default is 9 digits (nanosecond)
                            %3N  millisecond (3 digits)
                            %6N  microsecond (6 digits)
                            %9N  nanosecond (9 digits)
                            %12N picosecond (12 digits)

                Time zone:
                    %z - Time zone as hour and minute offset from UTC (e.g. +0900)
                            %:z - hour and minute offset from UTC with a colon (e.g. +09:00)
                            %::z - hour, minute and second offset from UTC (e.g. +09:00:00)
                            %:::z - hour, minute and second offset from UTC
                                                            (e.g. +09, +09:30, +09:30:30)
                    %Z - Time zone abbreviation name

                Weekday:
                    %A - The full weekday name (``Sunday'')
                            %^A  uppercased (``SUNDAY'')
                    %a - The abbreviated name (``Sun'')
                            %^a  uppercased (``SUN'')
                    %u - Day of the week (Monday is 1, 1..7)
                    %w - Day of the week (Sunday is 0, 0..6)

                ISO 8601 week-based year and week number:
                The week 1 of YYYY starts with a Monday and includes YYYY-01-04.
                The days in the year before the first week are in the last week of
                the previous year.
                    %G - The week-based year
                    %g - The last 2 digits of the week-based year (00..99)
                    %V - Week number of the week-based year (01..53)

                Week number:
                The week 1 of YYYY starts with a Sunday or Monday (according to %U
                or %W).  The days in the year before the first week are in week 0.
                    %U - Week number of the year.  The week starts with Sunday.  (00..53)
                    %W - Week number of the year.  The week starts with Monday.  (00..53)

                Seconds since the Unix Epoch:
                    %s - Number of seconds since 1970-01-01 00:00:00 UTC.
                    %Q - Number of microseconds since 1970-01-01 00:00:00 UTC.

                Literal string:
                    %n - Newline character (\n)
                    %t - Tab character (\t)
                    %% - Literal ``%'' character

                Combination:
                    %c - date and time (%a %b %e %T %Y)
                    %D - Date (%m/%d/%y)
                    %F - The ISO 8601 date format (%Y-%m-%d)
                    %v - VMS date (%e-%b-%Y)
                    %x - Same as %D
                    %X - Same as %T
                    %r - 12-hour time (%I:%M:%S %p)
                    %R - 24-hour time (%H:%M)
                    %T - 24-hour time (%H:%M:%S)
                    %+ - date(1) (%a %b %e %H:%M:%S %Z %Y)

                This method is similar to strftime() function defined in ISO C and POSIX.
                Several directives (%a, %A, %b, %B, %c, %p, %r, %x, %X, %E*, %O* and %Z)
                are locale dependent in the function.
                However this method is locale independent.
                So, the result may differ even if a same format string is used in other
                systems such as C.
                It is good practice to avoid %x and %X because there are corresponding
                locale independent representations, %D and %T.

                Examples:

                d = DateTime.new(2007,11,19,8,37,48,"-06:00")
                                            #=> #<DateTime: 2007-11-19T08:37:48-0600 ...>
                d.strftime("Printed on %m/%d/%Y")   #=> "Printed on 11/19/2007"
                d.strftime("at %I:%M%p")            #=> "at 08:37AM"

                Various ISO 8601 formats:
                %Y%m%d           => 20071119                  Calendar date (basic)
                %F               => 2007-11-19                Calendar date (extended)
                %Y-%m            => 2007-11                   Calendar date, reduced accuracy, specific month
                %Y               => 2007                      Calendar date, reduced accuracy, specific year
                %C               => 20                        Calendar date, reduced accuracy, specific century
                %Y%j             => 2007323                   Ordinal date (basic)
                %Y-%j            => 2007-323                  Ordinal date (extended)
                %GW%V%u          => 2007W471                  Week date (basic)
                %G-W%V-%u        => 2007-W47-1                Week date (extended)
                %GW%V            => 2007W47                   Week date, reduced accuracy, specific week (basic)
                %G-W%V           => 2007-W47                  Week date, reduced accuracy, specific week (extended)
                %H%M%S           => 083748                    Local time (basic)
                %T               => 08:37:48                  Local time (extended)
                %H%M             => 0837                      Local time, reduced accuracy, specific minute (basic)
                %H:%M            => 08:37                     Local time, reduced accuracy, specific minute (extended)
                %H               => 08                        Local time, reduced accuracy, specific hour
                %H%M%S,%L        => 083748,000                Local time with decimal fraction, comma as decimal sign (basic)
                %T,%L            => 08:37:48,000              Local time with decimal fraction, comma as decimal sign (extended)
                %H%M%S.%L        => 083748.000                Local time with decimal fraction, full stop as decimal sign (basic)
                %T.%L            => 08:37:48.000              Local time with decimal fraction, full stop as decimal sign (extended)
                %H%M%S%z         => 083748-0600               Local time and the difference from UTC (basic)
                %T%:z            => 08:37:48-06:00            Local time and the difference from UTC (extended)
                %Y%m%dT%H%M%S%z  => 20071119T083748-0600      Date and time of day for calendar date (basic)
                %FT%T%:z         => 2007-11-19T08:37:48-06:00 Date and time of day for calendar date (extended)
                %Y%jT%H%M%S%z    => 2007323T083748-0600       Date and time of day for ordinal date (basic)
                %Y-%jT%T%:z      => 2007-323T08:37:48-06:00   Date and time of day for ordinal date (extended)
                %GW%V%uT%H%M%S%z => 2007W471T083748-0600      Date and time of day for week date (basic)
                %G-W%V-%uT%T%:z  => 2007-W47-1T08:37:48-06:00 Date and time of day for week date (extended)
                %Y%m%dT%H%M      => 20071119T0837             Calendar date and local time (basic)
                %FT%R            => 2007-11-19T08:37          Calendar date and local time (extended)
                %Y%jT%H%MZ       => 2007323T0837Z             Ordinal date and UTC of day (basic)
                %Y-%jT%RZ        => 2007-323T08:37Z           Ordinal date and UTC of day (extended)
                %GW%V%uT%H%M%z   => 2007W471T0837-0600        Week date and local time and difference from UTC (basic)
                %G-W%V-%uT%R%:z  => 2007-W47-1T08:37-06:00    Week date and local time and difference from UTC (extended)
                                
                More documentation can be found here:
                http://www.ruby-doc.org/stdlib-1.9.3/libdoc/date/rdoc/DateTime.html
    TEXT
end

=begin
    @param: strTime String That need to be parse
    @param: inputFormat  The Input format is actually a regex and should be treated as such. 
                            To read in a unix/epoch time stamp simply pass in the string 'epoch' as the input format. It will return the time in GMT
    @param: outputFormat The Input format is actually a regex and should be treated as such
    @return: String that match contents or return error message
=end
def ConvertTimeString(strTime, inputFormat, outputFormat = '%m/%d/%Y')
    begin
        output = 0
        
        if inputFormat.match(/unix/i) then inputFormat = '%s' end
        if inputFormat.match(/epoch/i) then inputFormat = '%Q' end
        if outputFormat.match(/epoch|unix/i) then outputFormat = '%Q' end

        output = DateTime.strptime(strTime, inputFormat).strftime(outputFormat)

        return output
    rescue => err
        return 'Error: ' + err.message
    end
end

strTime, inputFormat, outputFormat = String.new, String.new, String.new

show_help if ARGV.empty?
while arg = ARGV.shift do
    case arg
        when "--help" then show_help; exit
        when "-i" || "--input" then inputFormat = ARGV.shift.to_s
        when "-o" || "--output" then outputFormat = ARGV.shift.to_s
        else strTime << arg
    end
end

puts ConvertTimeString(strTime, inputFormat, outputFormat)


