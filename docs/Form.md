NAME
====

Form - Raku implementation of Perl-style fixed-width text formatting

SYNOPSIS
========

```raku
use Form;

my @items  = ('Widget A', 'Widget B');
my @prices = (9.99, 24.50);

print form
    'Item                   Price',
    '-----------------------------',
    '{[[[[[[[[[[[[[[[[[[[}  {]].[}',
    @items,                @prices;

# Item                   Price
# -----------------------------
# Widget A               9.99
# Widget B              24.50
```

DESCRIPTION
===========

`Form` provides a `form()` function for creating fixed-width formatted text. It takes alternating *format strings* and *data arguments*, fills each field in the format with the corresponding data, and returns the completed text as a `Str`.

```raku
my $text = form $format1, $datum1, $datum2,
                $format2, $datum3;
```

Like all Raku subroutines, `form` can be called in scalar context (returns a string) or void context (dies loudly, since the result would be lost).

CONCEPTS
========

Format
------

A string used as a template. It contains zero or more *fields* — fixed-width slots enclosed in braces — usually separated by literal characters.

Field
-----

A fixed-width slot within a format string, enclosed in `{ }`. The characters inside determine the type, width, and justification of the data interpolated there. Fields are designed to look like a stylised picture of the finished result:

    {<<<<<<<}    Justify text to the left
    {>>>>>>>}               Justify text to the right
    {>>>>>>>}                    Centre the text
    {<<<<>>>}    Fully  justify  text  to  both  margins

Data
----

A scalar string, number, or array supplied after each format string. `form` pulls from each data argument in turn to fill the fields in the preceding format.

Line field vs Block field
-------------------------

A **line field** interpolates only as much data as fits on a single line, then stops. A **block field** interpolates all its data over as many output lines as necessary.

Column
------

One character-width of horizontal space in the output.

FIELD TYPES
===========

All fields are enclosed in `{ }`. The characters inside the braces select the field type and width; the opening `{` and closing `}` each contribute **one** column to the field width.

Text Fields
-----------

### Left-justified

Data is padded with spaces on the right.

    {<<<<}     line field  — one line only; data truncated if wider than the field
    {[[[[}     block field — data wraps across as many lines as needed

```raku
print form '{[[[[[[[[[}', 'The quick brown fox';
# The
# quick
# brown
# fox
```

### Right-justified

Data is padded with spaces on the left.

    {>>>>}     line field
    {]]]]]}    block field

### Centred

Data is padded on both sides; any odd padding goes on the right. Two equivalent syntaxes are supported:

    {>>><<<}   or   {|||||||}    line field
    {]]][[[ }  or   {IIIIIII}    block field

### Fully justified

Whitespace in the data is stretched to fill the field width evenly. The final line of a block field is always left-justified.

    {<<<>>>>}    line field
    {[[[]]]]]}   block field

```raku
print form '{<<<<<<<<<<<>>>>>>>>>>>>}',
           'A fellow of infinite jest';
# A  fellow  of  infinite
```

### Verbatim

Data is copied exactly as-is, without any re-justification or word-wrapping. Newlines in the data produce new lines in the output.

    {''''''''}    line field  — first line only
    {"""""""""    block field — all lines preserved

```raku
print form '{""}', "line one\nline two";
# line one
# line two
```

Numeric Fields
--------------

A numeric field aligns a decimal number around a fixed-position decimal marker. The integer part is right-justified; the fractional part is left-justified and zero-padded to the declared number of decimal places.

    {>>>.<<}     line field  — 3 integer columns, dot, 2 fractional columns
    {]]].[{}     block field

### Field width and decimal places

The opening `{` contributes **one** position to the integer width, and the closing `}` contributes **one** position to the fractional width. This makes the minimum fractional width 1 (one decimal place), because even with zero `[` or `< ` characters the `}` still provides one column:

    {]].}      1 decimal place   ( 0 × [ + } )
    {]].[}     2 decimal places  ( 1 × [ + } )
    {]].[[}    3 decimal places  ( 2 × [ + } )

A bare trailing decimal such as `0.` is not possible by design.

### Rounding and zero-padding

Numbers are **rounded** to the declared number of decimal places and **zero-padded**. Any `Real` subtype — `Int`, `Rat`, or `Num` — is accepted:

```raku
say form '{]].[}', 5;        #    5.00   (Int  — zero-padded)
say form '{]].[}', 1.5;      #    1.50   (Rat  — zero-padded)
say form '{]].[}', 3.145;    #    3.15   (Rat  — rounded up)
say form '{]].[}', 3.144;    #    3.14   (Rat  — rounded down)
say form '{]].[}', 5e0;      #    5.00   (Num  — zero-padded)
```

### Custom decimal marker

Any character that is not `[`, `]`, `< `, `> `, or `+` may be used as the decimal marker. The same marker is also recognised in string input data:

```raku
say form '{]]],[}', 1.23;       #    1,23   (comma marker)
say form '{]]],[}', '1,23';     #    1,23   (comma in input accepted too)
say form '{]]:}',   7.5;        #    7:5    (colon marker, 1dp)
```

### Thousands separators

Include a separator character at the desired grouping position inside the integer part of the field; `form` infers the grouping pattern from its position. Five major conventions are supported:

```raku
# Brittanic  — groups of 3, comma separator
say form '{],]]],]]].[}', 1234567.89;    #  1,234,567.89

# Continental  — groups of 3, period separator, comma decimal
say form '{].]]].]]],[}', 1234567.89;    #  1.234.567,89

# Subcontinental  — group of 3 then groups of 2
say form '{]],]],]]].[[}', 1234567.89;   # 12,34,567.890

# Hyperspatial  — space separator
say form '{] ]]] ]]].[}', 1234567.89;    #  1 234 567.89

# Asiatic  — groups of 4
say form '{]]]],]]]].[}', 1234567.89;    #   123,4567.89

# Swiss Army (apostrophe separator)
say form "{]']]]']]].[}", 1234567.89;    #  1'234'567.89
```

### Overflow and invalid data

When the integer part is too wide for the available columns, the entire field fills with `#` characters. When data cannot be parsed as a number, the field fills with `?` characters:

```raku
say form '{]].[}', 9999.9;    # ###.##
say form '{]].[}', 'hello';   # ???.??
```

Negative numbers work naturally; the minus sign occupies one integer column:

```raku
say form '{]]].[}', -3.14;    #   -3.14
```

Vertical Alignment
------------------

When a format row mixes block fields that produce different numbers of output lines, `form` pads the shorter columns with blank lines to match the tallest. An alignment modifier before or after the field type controls where the data appears within that padding.

### Top (default)

Data appears at the top; blank lines fill below. This is the default — no special character is needed.

### Middle

Prefix the field type with `=` (or suffix, or both). Data is centred vertically; odd padding goes below.

    {=[[[[[[[}    or    {[[[[[[[=}    middle-aligned block field

### Bottom

Prefix the field type with `_` (or suffix, or both). Data is pushed to the bottom of the padded column.

    {_[[[[[[[}    or    {[[[[[[[_}    bottom-aligned block field

DATA ARGUMENTS
==============

Scalar values (`Str`, `Int`, `Rat`, `Num`, …) and `Array`s may be passed as data. Arrays are not flattened — each array is bound to its corresponding field and its elements are consumed one per output row:

```raku
my @names  = <Alice Bob Carol>;
my @scores = (98, 74, 85);

print form '{<<<<<<<<<} {]].[}',
           @names,      @scores;
# Alice       98.00
# Bob         74.00
# Carol       85.00
```

Each array element provides one datum; block fields consume one element per row and may wrap that element over multiple lines.

MULTIPLE FORMAT STRINGS
=======================

A single call to `form` may contain any number of format / data pairs. `form` processes them in order and concatenates the results into one string:

```raku
print form
    'Invoice: {<<<<<}',    $id,
    'Date:    {<<<<<<<<}', $date,
    '----------------------------',
    '{[[[[[[[[[[[[} {]]].[[}',
    @descriptions, @amounts;
```

Literal strings (format strings with no fields) contribute their text directly, one line per call.

FIELD REFERENCE TABLE
=====================

    Field type            Line field        Block field
    ──────────────────    ──────────────    ──────────────
    left-justified        {<<<<<<<}         {[[[[[[[}
    right-justified       {>>>>>>>}         {]]]]]]]}`
    centred               {>>><<<}          {]]][[[ }
    centred (alt)         {|||||||}         {IIIIIII}
    fully justified       {<<<>>>>}         {[[[]]]]}`
    verbatim              {'''''''}         {"""""""}

    numeric               {>>>.<<}          {]]].[[}
    euronumeric           {>>>,<<}          {]]],[{}
    comma'd (Brittanic)   {>,>>>,>>>.<<}    {],]]],]]].[{}
    space'd (Hyperspatial){> >>> >>>.<<}    {] ]]] ]]].[{}
    subcontinental        {>>,>>,>>>.<<}    {]],]],]]].[{}
    eurocomma (Continen.) {>.>>>.>>>,<<}    {].]]].]]],[{}
    Swiss Army apostrophe {>'>>>'>>.<<}     {]']]]']]].[{}
    Asiatic               {>>,>>>>>.<<}     {]],]]]]].[{}

    left/middled          {=<<<<<<<}        {=[[[[[[[}
    right/middled         {=>>>>>>>}        {=]]]]]]]}`
    left/bottomed         {_<<<<<<<}        {_[[[[[[[}
    right/bottomed        {_>>>>>>>}        {_]]]]]]]}`

AUTHOR
======

Matthew Walton

Source: [https://github.com/raku-community-modules/Form](https://github.com/raku-community-modules/Form)

COPYRIGHT AND LICENSE
=====================

Copyright 2009 - 2012 Matthew Walton

Copyright 2013 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

