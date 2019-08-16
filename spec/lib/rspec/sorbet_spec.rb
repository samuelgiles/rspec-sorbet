# frozen_string_literal: true

require 'rspec/sorbet'

module RSpec
  describe Sorbet do
    describe '.allow_instance_doubles!' do
      subject(:allow_instance_doubles!) { described_class.allow_instance_doubles! }

      class Person
        extend T::Sig

        sig{params(forename: String, surname: String).void}
        def initialize(forename)
          @forename = T.let(forename, String)
          @surname = T.let(surname, String)
        end

        sig{returns(String)}
        def full_name
          [@forename, @surname].join(' ')
        end
      end

      class Greeter
        extend T::Sig

        sig{params(person: Person).void}
        def initialize(person)
          @person = T.let(person, Person)
        end

        sig{returns(String)}
        def greet
          "Hello #{@person.full_name}"
        end
      end

      let(:my_instance_double) { instance_double(String) }
      let(:my_person) do
        Person.new('Sam', 'Giles')
      end
      let(:my_person_double) do
        instance_double(Person, full_name: 'Steph Giles')
      end

      specify do
        expect { Greeter.new(my_person).greet }.not_to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet }.to raise_error(TypeError)
        expect { Greeter.new('Hello').greet }.to raise_error(TypeError)
        expect { T.let(my_instance_double, String) }.to raise_error(TypeError)
        expect { T.let(my_instance_double, Integer) }.to raise_error(TypeError)
        allow_instance_doubles!
        expect { Greeter.new(my_person).greet }.not_to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet }.not_to raise_error(TypeError)
        expect { Greeter.new('Hello').greet }.to raise_error(TypeError)
        expect { T.let(my_instance_double, String) }.not_to raise_error(TypeError)
        expect { T.let(my_instance_double, T.any(String, TrueClass)) }.not_to raise_error(TypeError)
        expect { T.let(my_instance_double, Integer) }.to raise_error(TypeError)
        expect { T.let(my_instance_double, T.any(Integer, Numeric)) }.to raise_error(TypeError)
      end
    end
  end
end
