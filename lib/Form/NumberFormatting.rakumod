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

our sub obtain-number-parts(Real $number, Int $decimals) {
    my $factor   = 10 ** $decimals;
    my $rounded  = ($number * $factor).round / $factor;
    my $ints     = $rounded.Int;
    my $frac     = (($rounded.abs - $ints.abs) * $factor).round.Int;
    my $frac-str = sprintf('%0' ~ $decimals ~ 'd', $frac);
    ($ints, $frac-str);
}

# vim: expandtab shiftwidth=4
