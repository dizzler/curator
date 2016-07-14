require 'spec_helper'
describe 'curator' do

  context 'with defaults for all parameters' do
    it { should contain_class('curator') }
  end
end
