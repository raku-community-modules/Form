unit module Form::NumberFormatting;

use Form::TextFormatting;

our sub obtain-number-parts(Real $number) {
    my $ints = $number.Int;
    my $fractions = $number - $ints;

    # it's much easier if we have this as an integer as it's rendered separately to the ints
    $fractions.=abs;
    $fractions *= 10 while $fractions.Int != $fractions;

    ($ints, $fractions);
}

# vim: expandtab shiftwidth=4
