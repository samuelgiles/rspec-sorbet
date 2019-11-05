# frozen_string_literal: true

require 'rspec/sorbet'

module RSpec
  describe Sorbet do
    shared_context 'instance double' do
      class Person
        extend T::Sig

        sig{params(forename: String, surname: String).void}
        def initialize(forename, surname)
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

        sig{params(others: T::Enumerable[Person])}
        def greet_others(others)
          "Hello #{@person.full_name}, #{others.map(&:full_name).join(', ')}"
        end
      end

      let(:my_instance_double) { instance_double(String) }
      let(:my_person) do
        Person.new('Sam', 'Giles')
      end
      let(:my_person_double) do
        instance_double(Person, full_name: 'Steph Giles')
      end
      let(:another_person) do
        instance_double(Person, full_name: 'Yasmin Collins')
      end
    end

    shared_examples 'it allows an instance double' do
      specify do
        expect { Greeter.new(my_person).greet }.not_to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet }.to raise_error(TypeError)
        expect { Greeter.new('Hello').greet }.to raise_error(TypeError)
        expect { T.let(my_instance_double, String) }.to raise_error(TypeError)
        expect { T.let(my_instance_double, Integer) }.to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet_others([my_person_double, another_person]) }
          .to raise_error(TypeError)
        subject
        expect { Greeter.new(my_person).greet }.not_to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet }.not_to raise_error(TypeError)
        expect { Greeter.new('Hello').greet }.to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet_others([my_person_double, another_person]) }
          .not_to raise_error(TypeError)
        expect { T.let(my_instance_double, String) }.not_to raise_error(TypeError)
        expect { T.let(my_instance_double, T.any(String, TrueClass)) }.not_to raise_error(TypeError)
        expect { T.let(my_instance_double, Integer) }.to raise_error(TypeError)
        expect { T.let(my_instance_double, T.any(Integer, Numeric)) }.to raise_error(TypeError)
      end
    end

    after do
      T::Configuration.inline_type_error_handler = nil
      T::Configuration.call_validation_error_handler = nil
    end

    describe '.allow_instance_doubles!' do
      subject { described_class.allow_instance_doubles! }

      include_context 'instance double'
      it_should_behave_like 'it allows an instance double'
    end

    describe '.allow_doubles!' do
      subject { described_class.allow_doubles! }

      describe 'instance doubles' do
        include_context 'instance double'
        it_should_behave_like 'it allows an instance double'
      end

      describe 'class doubles' do
        let(:my_class_double) { class_double(String) }

        specify do
          expect { T.let(my_class_double, String) }.to raise_error(TypeError)
          subject
          expect { T.let(my_class_double, String) }.not_to raise_error(TypeError)
        end
      end

      describe 'object doubles' do
        let(:my_object_double) { object_double(String) }

        specify do
          expect { T.let(my_object_double, String) }.to raise_error(TypeError)
          subject
          expect { T.let(my_object_double, String) }.not_to raise_error(TypeError)
        end
      end
    end
  end
end
