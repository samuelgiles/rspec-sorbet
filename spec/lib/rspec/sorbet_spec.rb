# typed: ignore
# frozen_string_literal: true

require 'sorbet-runtime'
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

        sig{returns(T.nilable(Person))}
        def reversed
          Person.new(@surname, @forename)
        end

        sig{params(person: T.any(String, Person, T::Array[String])).returns(T.any(String, Person, T::Array[String]))}
        def self.person?(person)
          person
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

        sig{returns(Person)}
        def person
          T.cast(@person, Person)
        end

        sig{returns(T.nilable(Person))}
        def reversed
          T.let(@person.reversed, T.nilable(Person))
        end

        sig{params(others: T::Enumerable[Person]).void}
        def greet_others(others)
          "Hello #{@person.full_name}, #{others.map(&:full_name).join(', ')}"
        end
      end

      let(:my_instance_double) { instance_double(String) }
      let(:my_person) do
        Person.new('Sam', 'Giles')
      end
      let(:my_person_double) do
        instance_double(Person, full_name: 'Steph Giles', reversed: another_person)
      end
      let(:another_person) do
        instance_double(Person, full_name: 'Yasmin Collins')
      end
    end

    shared_examples 'it allows an instance double' do
      specify do
        expect { Greeter.new(my_person).greet }.not_to raise_error
        expect { Greeter.new(my_person_double).greet }.to raise_error(TypeError)
        expect { Greeter.new(my_person_double).reversed }.to raise_error(TypeError)
        expect { Greeter.new(my_person_double).person }.to raise_error(TypeError)
        expect { Person.person?(my_person_double) }.to raise_error(TypeError)
        expect { Greeter.new('Hello').greet }.to raise_error(TypeError)
        expect { T.let(my_instance_double, String) }.to raise_error(TypeError)
        expect { T.let(my_instance_double, Integer) }.to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet_others([my_person_double, another_person]) }
          .to raise_error(TypeError)
        subject
        expect { Greeter.new(my_person).greet }.not_to raise_error
        expect { Greeter.new(my_person_double).greet }.not_to raise_error
        expect { Greeter.new(my_person_double).reversed }.not_to raise_error
        expect { Greeter.new(my_person_double).person }.not_to raise_error
        expect { Person.person?(my_person_double) }.not_to raise_error
        expect { Greeter.new('Hello').greet }.to raise_error(TypeError)
        expect { Greeter.new(my_person_double).greet_others([my_person_double, another_person]) }
          .not_to raise_error
        expect { T.let(my_instance_double, String) }.not_to raise_error
        expect { T.let(my_instance_double, T.any(String, TrueClass)) }.not_to raise_error
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
        extend T::Sig

        class Rectangle; end
        class Square < Rectangle; end
        class Triangle; end

        sig{params(klass: T.class_of(Rectangle)).void}
        def rectangular_class?(klass); end

        specify 'inline types' do
          expect { T.let(Rectangle, Rectangle) }.to raise_error(TypeError)
          expect { T.let(class_double(Rectangle), Rectangle) }.to raise_error(TypeError)
          expect { T.let(Rectangle, T.class_of(Rectangle)) }.not_to raise_error
          expect { T.let(class_double(Rectangle), T.class_of(Rectangle)) }.to raise_error(TypeError)
          subject
          expect { T.let(Rectangle, Rectangle) }.to raise_error(TypeError)
          expect { T.let(class_double(Rectangle), Rectangle) }.to raise_error(TypeError)
          expect { T.let(Rectangle, T.class_of(Rectangle)) }.not_to raise_error
          expect { T.let(class_double(Rectangle), T.class_of(Rectangle)) }.not_to raise_error
        end

        specify 'method signatures' do
          expect { rectangular_class?(class_double(Rectangle)) }.to raise_error(TypeError)
          expect { rectangular_class?(Rectangle) }.not_to raise_error
          expect { rectangular_class?(class_double(Square)) }.to raise_error(TypeError)
          expect { rectangular_class?(Square) }.not_to raise_error
          expect { rectangular_class?(Triangle) }.to raise_error(TypeError)
          expect { rectangular_class?(class_double(Triangle)) }.to raise_error(TypeError)
          subject
          expect { rectangular_class?(class_double(Rectangle)) }.not_to raise_error
          expect { rectangular_class?(Rectangle) }.not_to raise_error
          expect { rectangular_class?(class_double(Square)) }.not_to raise_error
          expect { rectangular_class?(Square) }.not_to raise_error
          expect { rectangular_class?(class_double(Triangle)) }.to raise_error(TypeError)
        end
      end

      describe 'object doubles' do
        let(:my_object_double) { object_double(String) }

        specify do
          expect { T.let(my_object_double, String) }.to raise_error(TypeError)
          subject
          expect { T.let(my_object_double, String) }.not_to raise_error
        end
      end

      describe 'doubles' do
        let(:my_double) { double('name') }
        let(:my_non_verifying_double) { double(DoubleMethodArgument) }

        class DoubleMethodArgument
          extend T::Sig

          sig { params(message: String).void }
          def initialize(message)
            @message = message
          end
        end

        it 'allows test doubles as method arguments' do
          expect { DoubleMethodArgument.new(my_double) }.to raise_error(TypeError)
          expect { DoubleMethodArgument.new(my_non_verifying_double) }.to raise_error(TypeError)
          subject
          expect { DoubleMethodArgument.new(my_double) }.not_to raise_error
          expect { DoubleMethodArgument.new(my_non_verifying_double) }.not_to raise_error
        end

        specify do
          expect { T.let(my_double, String) }.to raise_error(TypeError)
          expect { T.let(my_non_verifying_double, String) }.to raise_error(TypeError)
          expect { T.let(my_non_verifying_double, DoubleMethodArgument) }.to raise_error(TypeError)
          subject
          expect { T.let(my_double, String) }.not_to raise_error
          expect { T.let(my_non_verifying_double, String) }.not_to raise_error
          expect { T.let(my_non_verifying_double, DoubleMethodArgument) }.not_to raise_error
        end
      end
    end
  end
end
