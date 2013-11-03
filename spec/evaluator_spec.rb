require 'spec_helper'

describe Landescape::Curses do
  def evaluate(tokens, window)
    evaluator   = Landescape::Curses.start(array_to_result(tokens), window, non_block: true)
    eval_thread = evaluator.instance_variable_get(:@eval_thread)
    eval_thread.join if eval_thread.alive?
  end

  let(:window) { double(:window) }

  before do
    window.stub(:maxy) { 20 }
  end

  describe '#print' do
    it do
      window.should receive(:addstr).with 'H'
      window.should receive :refresh

      evaluate [[:print, 'H']], window
    end
  end

  describe '#set_attributes' do
    context 'supported attribute' do
      it do
        window.should receive(:attron).with ::Curses::A_BLINK

        evaluate [[:set_attributes, 5]], window
      end
    end

    context 'not supported attribute' do
      it do
        window.should_not receive :attron
        window.should_not receive :attroff

        evaluate [[:set_attributes, 33]], window
      end
    end

    context 'empty arguments' do
      it do
        window.should receive :attroff

        evaluate [[:set_attributes]], window
      end
    end
  end

  describe '#exit_attribute_mode' do
    it do
      window.should receive :attroff

      evaluate [[:exit_attribute_mode]], window
    end
  end

  describe '#change_scroll_region' do
    it do
      window.should receive(:setscrreg).with 5, 10

      evaluate [[:change_scroll_region, 5, 10]], window
    end
  end

  describe '#scroll_reverse' do
    it do
      window.should receive(:scrl).with -1

      evaluate [[:scroll_reverse]], window
    end
  end

  describe '#scroll_forward' do
    it do
      window.should receive(:scrl).with 1

      evaluate [[:scroll_forward]], window
    end
  end

  describe '#cursor_address' do
    context 'not on bottom' do
      before do
        window.stub(:cury) { 1 }
        window.stub(:maxy) { 21 }
      end

      it do
        window.should receive(:setpos).with 4, 2

        evaluate [[:cursor_address, 4, 2]], window
      end
    end

    context 'on bottom' do
      before do
        window.stub(:cury) { 20 }
        window.stub(:maxy) { 21 }
      end

      it do
        window.should receive(:scrl).with 1
        window.should receive(:setpos).with 23, 2

        evaluate [[:cursor_address, 23, 2]], window
      end
    end
  end
end
