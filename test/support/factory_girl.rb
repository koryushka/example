# for Test::Unit assertion style
class MiniTest::Rails::ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

# for Spec expectation style
class MiniTest::Spec
  include FactoryGirl::Syntax::Methods
end