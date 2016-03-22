require 'test_helper'

class ComplexEventTest < ActiveSupport::TestCase
  def complex_event
    @complex_event ||= ComplexEvent.new
  end

  def test_readonly?
    assert complex_event.readonly?
  end
end
