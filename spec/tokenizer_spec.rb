require 'spec_helper'

describe Landescape::Tokenizer do
  def tokenize(str)
    tokenizer       = Landescape::Tokenizer.start(str)
    tokenize_thread = tokenizer.instance_variable_get(:@tokenize_thread)
    tokenize_thread.join if tokenize_thread.alive?

    result_to_array(tokenizer.result)
  end

  it { tokenize("\e]***").should            == %W(\e ] * * *) }
  it { tokenize("Hi\e[32mHello\e[m").should == %W(H i \e[32m H e l l o \e[m) }
  it { tokenize("\e[1;10H").should          == %W(\e[1;10H) }
  it { tokenize("\e[;H").should             == %W(\e[;H) }
  it { tokenize("\e[A").should              == %W(\e[A) }
  it { tokenize("\e[u").should              == %W(\e[u) }
  it { tokenize("\e[2J").should             == %W(\e[2J) }
  it { tokenize("\e[?1h").should            == %W(\e[?1h) }

  it { tokenize("\e(A\e)0").should          == %W(\e\(A \e\)0) }
  it { tokenize("\e#4").should              == %W(\e#4) }
  it { tokenize("\eB").should               == %W(\eB) }
  it { tokenize("\e<").should               == %W(\e<) }
  it { tokenize("\e>").should               == %W(\e>) }
  it { tokenize("\e=").should               == %W(\e=) }
  it { tokenize("\eD\eM").should            == %W(\eD \eM) }
  it { tokenize("\e\\").should              == %W(\e\\) }

  it { tokenize("\n\r").should              == %W(\n \r) }
end
