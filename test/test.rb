require 'minitest/autorun'
require_relative '../lib/shenmegui'

describe 'test' do
  before do
    ShenmeGUI.app do
      body do
        @b = button 'test'
      end
    end
  
  end

  it 'should have 2 in elements' do
    ShenmeGUI.elements.size.must_equal 2
  end
end