defmodule ETLConfig do

  def get_config(section, key) do
    pl = :econfig.get_value(:inifile, to_char_list(section))
    v = :proplists.get_value( to_char_list(key), pl  )
    to_string(v)
  end

end