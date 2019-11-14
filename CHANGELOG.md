1.5.0

* Added support for `T.cast`.

1.4.0

* Added support for `T.let` referencing `T.nilable` types.

1.3.0

* Added ability to allow any kind of double (Class, Instance, Object).
* `RSpec::Sorbet.allow_instance_doubles!` has been renamed to `RSpec::Sorbet.allow_doubles!`, an alias remains for backwards compatibility for the time being.

1.2.1

* Fix call check when opts contains :message instead of :pretty_message.

1.2.0

* Added support for verifying `T::Enumerable` types.

1.1.0

* Add basic `instance_double` verification to help check the type of an instance double.

1.0.0

* Initial release
* Supports just allowing instance doubles for now
