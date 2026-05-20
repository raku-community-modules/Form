use Form::TextFormatting;
use Form::NumberFormatting;
use Form::Types;

# RAKUDO: Field is now a class, because overriding multis doesn't
# work correctly from roles
our class Form::Field::Field {
    has Bool $.block is rw;
    has Int $.width is rw;
    has $.alignment is rw;
    has $.data is rw;

    multi method format(@data) {
        my @output;
        for @data -> $datum {
            @output.push(self.format($datum));
        }
        @output
    }

    method align(@lines, $height) {
        if @lines.elems < $height {
            my @extra = (' ' x $.width) xx ($height - @lines.elems);
            given $.alignment {
                when Alignment::top {
                    (@lines, @extra).flat
                }
                when Alignment::bottom {
                    (@extra, @lines).flat
                }
                default {
                    my @top = (' ' x $.width) xx (@extra.elems div 2);
                    my @bottom = @top;
                    @extra.elems % 2 and @bottom.push(' ' x $.width);
                    (@top, @lines, @bottom).flat
                }
            }
        }
        elsif @lines.elems > $height {
            # TODO: we may need to be cleverer about which alignments
            @lines[^$height]
        }
        else {
            @lines
        }
    }
}

our class Form::Field::Text is Form::Field::Field {
    has $.justify is rw;

    multi method format(Any $data where { !($_ ~~ Positional) }) {
        self.format(~$data)
    }

    multi method format(Str $data) {
        my @lines = Form::TextFormatting::unjustified-wrap(~$data, $.width);

        $.block or @lines = @lines[^1];

        my Callable $justify-function;
        if $.justify == Justify::left {
            $justify-function = &Form::TextFormatting::left-justify;
        }
        elsif $.justify == Justify::right {
            $justify-function = &Form::TextFormatting::right-justify;
        }
        elsif $.justify == Justify::centre {
            $justify-function = &Form::TextFormatting::centre-justify;
        }
        else {
            $justify-function = &Form::TextFormatting::full-justify;
        }

        @lines.map: { $justify-function($_, $.width, ' ') }
    }
}

our class Form::Field::Numeric is Form::Field::Field {
    has Int $.ints-width;
    has Int $.fracs-width;
    has Str $.decimal-marker = '.';
    has Str $.thousands-sep  = '';
    has $.group-sizes        = [];

    multi method format(Real $data) {
        my ($ints, $frac-str) = Form::NumberFormatting::obtain-number-parts(+$data, $.fracs-width);
        my $ints-str = do if $.thousands-sep {
            my $sign = +$ints < 0 ?? '-' !! '';
            $sign ~ Form::NumberFormatting::format-with-thousands(~$ints.abs, $.thousands-sep, $.group-sizes)
        } else {
            ~$ints
        };
        return [ '#' x $.ints-width ~ $.decimal-marker ~ '#' x $.fracs-width ] if $ints-str.chars > $.ints-width;
        my $int-fmt  = Form::TextFormatting::right-justify($ints-str, $.ints-width);
        my $frac-fmt = Form::TextFormatting::left-justify($frac-str, $.fracs-width);
        [ $int-fmt ~ $.decimal-marker ~ $frac-fmt ]
    }

    multi method format(Any $data where { !($_ ~~ Positional) }) {
        my $n = try Form::NumberFormatting::parse-number(~$data, $.decimal-marker);
        $n.defined ?? self.format($n) !! ['?' x $.ints-width ~ $.decimal-marker ~ '?' x $.fracs-width]
    }
}

our class Form::Field::Verbatim is Form::Field::Field {
    multi method format(Str $data) {
        my @lines = $data.split("\n");
        $.block or @lines = @lines[^1];
        for @lines -> $line is rw {
            $line = Form::TextFormatting::left-justify($line, $.width, ' ');
        }

        @lines
    }
}

# vim: expandtab shiftwidth=4
