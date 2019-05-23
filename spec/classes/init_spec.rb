require 'spec_helper'
describe 'sguil' do
  context 'with default values for all parameters' do
    it { should contain_class('sguil') }
  end
end
