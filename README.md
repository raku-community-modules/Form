[![Actions Status](https://github.com/raku-community-modules/Form/workflows/test/badge.svg)](https://github.com/raku-community-modules/Form/actions)

NAME
====

Form - A Raku implementation of Perl-style string formatting

SYNOPSIS
========

```raku
use Form;

my @items  = ('Widget A', 'Widget B');
my @prices = (9.99, 24.50);

print form
    'Item                   Price',
    '----------------------------',
    '{[[[[[[[[[[[[[[[[[[[} {]].[}',
    @items,                @prices;

# Item                   Price
# ----------------------------
# Widget A                9.99
# Widget B               24.50
```

DESCRIPTION
===========

An implementation of Perl's Form module, as described by Exegesis 7 and Damian Conway's Perl6::Form module.

Full documentation: [docs/Form.md](docs/Form.md)

NUMERIC FIELDS
==============

Numeric fields use `]` (block) or `>` (line) for the integer part, an arbitrary decimal marker character, and `[` (block) or `<` (line) for the fractional part, all enclosed in `{` `}`.

The closing brace `}` always contributes one position to the fractional width, and the opening brace `{` always contributes one position to the integer width. This means:

  * `{]].}` — 1 decimal place (no `[` chars; `}` alone provides fracs-width=1)

  * `{]].[}` — 2 decimal places (one `[` plus `}`)

  * `{]].[[}` — 3 decimal places (two `[` plus `}`)

The minimum is 1 decimal place. A bare trailing decimal like `0.` is not supported by design — `{]].}` gives `0.0`, not `0.`.

Numbers are rounded to the specified number of decimal places and zero-padded (e.g. `1.5` in a 2-decimal field renders as `1.50`).

TODO
====

  - Currencies
  - Complex numbers
  - Everything else

AUTHORS
=======

Matthew Walton, Stephen Roe

Source can be located at: https://github.com/raku-community-modules/Form . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2009 - 2012 Matthew Walton

Copyright 2013 - 2026 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

