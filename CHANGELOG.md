# Changelog

## Unreleased

- Rubocop offenses resolved
- Sorbet signatures added to `RSpec::Sorbet::Doubles`
- Added `RSpec::Sorbet.reset!` to restore handlers to previous state
- Added fix to prevent `SystemStackError` by keeping track of when handlers have been configured. (thanks [@alex-tan](https://github.com/alex-tan))
- Added logic to pass type error onwards to existing inline type error handler.

## 1.9.1

- Support `T.nilable(T.class_of(...))` among others (thanks [@deecewan](https://github.com/deecewan))

## 1.9.0

- Allow specification of a custom validation handler (thanks [@bmalinconico](https://github.com/bmalinconico))

## 1.8.3

- Make sorbet a development dependency

## 1.8.2

- Reduce gem size by excluding RBIs from gem build

## 1.8.1

- [BUGFIX] Fix processing T.let type mismatch messages when there are digits in module name

## 1.8.0

- Fixed issues around union types referencing typed enumerables.

## 1.7.0

- Added support `T.class_of`.

## 1.6.0

- Non-verifying double support improved.

## 1.5.0

- Added support for `T.cast`.

## 1.4.0

- Added support for `T.let` referencing `T.nilable` types.

## 1.3.0

- Added ability to allow any kind of double (Class, Instance, Object).
- `RSpec::Sorbet.allow_instance_doubles!` has been renamed to `RSpec::Sorbet.allow_doubles!`, an alias remains for backwards compatibility for the time being.

## 1.2.1

- Fix call check when opts contains :message instead of :pretty_message.

## 1.2.0

- Added support for verifying `T::Enumerable` types.

## 1.1.0

- Add basic `instance_double` verification to help check the type of an instance double.

## 1.0.0

- Initial release
- Supports just allowing instance doubles for now
