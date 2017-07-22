require 'find'
require 'json'

def report(count, dict, name)
  print "[#{name}]"
  return
  dict.keys.sort{|a, b| dict[b] <=> dict[a]}.each {|k|
    print "#{k}: #{dict[k]}\n"
  }
  print "\n"
end

w = File.open('data.ndjson', 'w')
count = 0
dict = Hash.new{|h, k| h[k] = 0}
name = ''
Find.find('/Volumes/Extreme 900/experimental_rdcl') {|path|
  next unless path.end_with?('geojson')
  begin
    JSON::parse(File.read(path))['features'].each {|f|
      dict[f["properties"]["rdCtg"]] += 1
      f["tippecanoe"] = {
        "minzoom" => {
          "市区町村道等" => 14,
          "都道府県道" => 9,
          "国道" => 4,
          "高速自動車国道等" => 0,
          "その他" => 14
        }[f["properties"]["rdCtg"]]
      }
      name = f["properties"]["name"] unless f["properties"]["name"] == ""
      f["properties"].delete("rID") # to save storage
      f["properties"].delete("class") # to save storage
      f["properties"].delete("lfSpanFr") # to save storage
      f["properties"].delete("lfSpanTo") # to save storage
      f["properties"].delete("tmpFlg") # to save storage
      f["properties"].delete("admCode") # to save storage
      f["properties"].delete("devDate") # to save storage
      f["properties"].delete("sectID") # to save storage
      w.print JSON::dump(f), "\n"
      count += 1
      report(count, dict, name) if count % 10000 == 0
    }
  rescue
    print "\nerror in #{path}: #{$!}\n"
  end
}
w.close
