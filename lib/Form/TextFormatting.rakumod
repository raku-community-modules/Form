unit module Form::TextFormatting;

sub chop-first-word(Str $source is rw) returns Str {
    if $source ~~ / ^^ (\S+) \s* (.*) $$ / {
        my $word = ~$/[0];
        $source = ~$/[1];
        $word
    }
    else {
        ''
    }
}

our sub fit-in-width(Str $text, Int $width) {

    my Str $fitted = '';
    my Str $remainder = $text;
    my Str $word;
    
    while $word = chop-first-word($remainder) {
        if $fitted.chars + $word.chars <= $width {
            $fitted ~= $word;
            if $fitted.chars < $width {
                $fitted ~= ' ';
            }
            else {
                # done - no room for a space means no
                # room for another word
                last;
            }
        }
        else {
            # won't fit - put the word back
            $remainder = "$word $remainder";
            last;
        }
    }

    # final check - did we fit anything in?
    # if the word is too long, we have to split it
    if $fitted eq '' {
        $fitted = $remainder.substr(0, $width);
        $remainder.=substr($width);
    }

    (trim-ending-whitespace($fitted), $remainder)
}


our sub unjustified-wrap(Str $text, Int $width) {
    my $rem = $text;
    my $line;

    my @array = gather while $rem {
        ($line, $rem) = fit-in-width($rem, $width);
        # we have to force a copy here or take will end up with the same value
        # every single time! This might be a rakudo issue, or a spec issue
        # or just expected behaviour
        my $t = $line;
        take $t;
    };

    @array
}

sub trim-ending-whitespace(Str $line) returns Str {
    $line.subst(/ <ws> $$ /, '')
}

our sub left-justify(Str $line, Int $width, Str $space = ' ') returns Str {
    if $line.chars < $width {
        return $line ~ (($space x ($width - $line.chars) / $space.chars));
    }

    $line.substr(0, $width)
}

our sub right-justify(Str $line, Int $width, Str $space = ' ') returns Str {
    if $line.chars < $width {
        return ($space x (($width - $line.chars) / $space.chars)) ~ $line;
    }

    $line.substr($line.chars - $width, $width)
}

our sub centre-justify(Str $line, Int $width, Str $space = ' ') returns Str {
    if $line.chars < $width {
        my Int $to-add = $width - $line.chars;
        my Int $before = $to-add div 2;
        my Int $after = $before + $to-add % 2;
        $before div= $space.chars;
        $after div= $space.chars;
        return ($space x $before) ~ $line ~ ($space x $after);
    }

    $line.substr(0, $width)
}

our sub full-justify(Str $line, Int $width, Str $space = ' ') {
    # TODO need a justify algorithm
    # for now, do something entirely unsatisfactory
    if $line.chars < $width {
        my Str @words = $line.words;
        my $words = @words.elems;
        my Str @spaces = $space xx ($words - 1);

        my $words-width = [+] @words.map: *.chars;
        my $spaces-width = [+] @spaces.map: *.chars;

        my $act-space = 0;
        while $words-width + $spaces-width < $width
        {

            @spaces[$act-space++] ~= $space;

            $spaces-width = [+] @spaces.map({ .chars });
            $act-space = 0 if $act-space == @spaces.elems;
        }
        # We add empty elem to make zip operation work here
        @spaces.push('');
        (@words Z~ @spaces).flat.join
    }
    else {
        $line.substr(0, $width)
    }
}

# vim: expandtab shiftwidth=4
