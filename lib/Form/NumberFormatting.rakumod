unit module Form::NumberFormatting;

use Form::TextFormatting;

our sub format-with-thousands(Str $n, Str $sep, $groups) {
    my @digits = $n.comb.reverse;
    my @parts;
    my $i = 0;
    while @digits {
        my $size = $groups[$i] // $groups[*-1];
        my @chunk = @digits.splice(0, $size);
        @parts.unshift(@chunk.reverse.join);
        $i++ if $i < $groups.end;
    }
    @parts.join($sep)
}

our sub parse-number(Str $s, Str $decimal-marker = '.') {
    my $normalised = $decimal-marker eq '.' ?? $s !! $s.subst($decimal-marker, '.', :g);
    $normalised ~~ /^ \s* <[+\-]>? \d+ ['.' \d+]? \s* $/ ?? $normalised.Real !! Nil
}

our sub obtain-number-parts(Real $number) {
    my $ints = $number.Int;
    my $fractions = $number - $ints;

    # it's much easier if we have this as an integer as it's rendered separately to the ints
    $fractions.=abs;
    $fractions *= 10 while $fractions.Int != $fractions;

    ($ints, $fractions);
}

# vim: expandtab shiftwidth=4
