require 'spec_helper'

describe PipeDsl::Definition do

  it 'json roundtrip' do
     str = File.read(File.join($SPEC_ROOT,'samples','table_copy.json'));
     parsed = JSON.parse(str)
     parsed_objects = parsed['objects'].sort_by{ |v| v['id'] }

     definition = described_class.from_cli_json(str).as_cli_json
     #run through json to stringify keys
     definition = JSON.parse(JSON.dump(definition))
     objects = definition['objects'].sort_by{ |v| v['id'] }

     expect(parsed_objects).to match_array(objects)
  end
end
