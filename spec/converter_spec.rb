require 'spec_helper'

describe Landescape::Converter::VT100 do
  def convert(tokens)
    converter      = Landescape::Converter::VT100.start(array_to_result(tokens), non_block: true)
    convert_thread = converter.instance_variable_get(:@convert_thread)
    convert_thread.join if convert_thread.alive?

    result_to_array(converter.result)
  end

  it { convert(%W(\e[4m H i \e[m .)).should == [[:set_attributes, 4], [:print, 'H'], [:print, 'i'], [:exit_attribute_mode], [:print, '.']] }
  it { convert(%W(\e[50;2H)).should == [[:cursor_address, 50, 2]] }
  it { convert(%W(\e[5A)).should    == [[:cursor_up, 5]] }
  it { convert(%W(\e[5B)).should    == [[:cursor_down, 5]] }
  it { convert(%W(\e[5C)).should    == [[:cursor_right, 5]] }
  it { convert(%W(\e[5D)).should    == [[:cursor_left, 5]] }
  it { convert(%W(\e[1m)).should    == [[:set_attributes, 1]] }
  it { convert(%W(\e[1;20r)).should == [[:change_scroll_region, 1, 20]] }
  it { convert(%W(\e[s)).should     == [[:save_cursor]] }
  it { convert(%W(\e[u)).should     == [[:restore_cursor]] }
  it { convert(%W(\e[2J)).should    == [[:clear_screen]] }
  it { convert(%W(\e[J)).should     == [[:clear_screen]] }
  it { convert(%W(\e[K)).should     == [[:clear_eol]] }
  it { convert(%W(\e[?1h)).should   == [[:keypad_xmit]] }
  it { convert(%W(\e[?1l)).should   == [[:keypad_local]] }
  it { convert(%W(\e[?25h)).should  == [[:cursor_visible]] }
  it { convert(%W(\e[?25l)).should  == [[:cursor_invisible]] }
  it { convert(%W(\n)).should       == [[:newline]] }
  it { convert(%W(\r)).should       == [[:carriage_return]] }
  it { convert(%W(\a)).should       == [[:bell]] }
  it { convert(%W(\e\\)).should     == [[:carriage_return]] }
  it { convert(%W(\u000F)).should   == [[:unknown, "\u000F"]] }
end
