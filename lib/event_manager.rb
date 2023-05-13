require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone_number)
  if phone_number.length < 10 || phone_number.length > 11
    phone_number = 'x'
  elsif phone_number.length == 11
    if phone_number[0] == 1
      phone_number = phone_number[1..-1]
    else
      phone_number = 'x'
    end
  else
    phone_number
  end
end

def peak_hour(times)
  times.max_by { |i| times.count(i) }
end

def clean_time(date_time)
  if date_time[0].length < 8
    date_array = date_time[0].split("/")
    for i in 0..1
      if date_array[i].length < 2
        date_array[i] = "0" + date_array[i]
      end
    end
    date_time[0] = date_array.join("/")
  end
  year = ("20" + date_time[0][-2..-1]).to_i
  month = date_time[0][0..1]
  date = date_time[0][3..4]

  if date_time[1].length < 5
    time_array = date_time[1].split(":")
    if time_array[0].length < 2
      time_array[0] = "0" + time_array[0]
    end
    date_time[1] = time_array.join(":")
  end
  hour = date_time[1][0..1]
  min = date_time[1][3..4]

  return Time.new(year,month,date,hour,min)
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

times = []

contents.each do |row| #commented shit out so its faster when i do assignments
  #id = row[0]
  #name = row[:first_name]
  #zipcode = clean_zipcode(row[:zipcode])
  #legislators = legislators_by_zipcode(zipcode)

  #form_letter = erb_template.result(binding)

  #save_thank_you_letter(id,form_letter)

  #phone_number = clean_phone_number(row[:homephone].to_s.gsub(/\p{^Alnum}/, ""))

  cleaned_time = clean_time(row[:regdate].split(" "))
  times.push(cleaned_time)

end

hours = []
times.each do |time|
  hours.push(time.hour)
end
puts "#{peak_hour(hours)}"