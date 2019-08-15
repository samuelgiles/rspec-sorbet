# frozen_string_literal: true

require 'rspec/sorbet'

module RSpec
  describe Sorbet do
    describe '.allow_instance_doubles!' do
      subject(:allow_instance_doubles!) { described_class.allow_instance_doubles! }

      context 'when an instance double is used' do
        let(:my_instance_double) { instance_double(String) }

        specify do
          expect { T.let(my_instance_double, String) }.to raise_error(TypeError)
          allow_instance_doubles!
          expect { T.let(my_instance_double, String) }.not_to raise_error(TypeError)
        end
      end
    end
  end
end
