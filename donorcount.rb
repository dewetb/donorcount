require 'pdf-reader'
all_relevant_text = ""

folder_path = Dir.pwd + "/job-receipts"
Dir.glob(folder_path + "/*").sort.each do |f|

  filename = f.gsub(folder_path, "")

  reader = PDF::Reader.new("job-receipts#{filename}")
  whole_text = reader.pages.first.text
  received_index = whole_text.index("Amount Received")
  total_index = whole_text.index("Total:")
  
  relevant_text = whole_text[received_index+16..total_index+100] if received_index && total_index
  all_relevant_text += relevant_text if relevant_text
end

all_array = all_relevant_text.split("\n")

donations = all_array.select { |line| line.match(/(\d{1,2}[\/]){2}\d{4}/) }

trimmed = donations.map { |line| line.gsub(/ {3,}/, " ") }

grouped = trimmed.group_by { |line| line[/\A\D+/].chop }

def add_donations(array)
  total = 0
  array.each do |line|
    total += line[/\d+.\d{2}$/].to_i
  end
  total
end

output = []

grouped.each do |k, v|
  output << "#{k} gave #{v.size} times & totaled $#{add_donations(v)}"
end

puts output