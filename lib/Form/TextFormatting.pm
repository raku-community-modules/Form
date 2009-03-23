module Form::TextFormatting;

enum Justify <left right centre full>;
enum Alignment <top middle bottom>;

sub chop_first_word(Str $source is rw) returns Str {
	if $source ~~ / ^^ (\S+) \s* (.*) $$ / {
		my $word = ~$/[0];
		$source = ~$/[1];
		return $word;
	}
	else {
		return '';
	}
}

sub fit_in_width(Str $text, Int $width) returns Array of Str {

	my $fitted = '';
	my $remainder = $text;
	my $word;
	
	while $word = chop_first_word($remainder) {
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

	return (trim_ending_whitespace($fitted), $remainder);
}


sub unjustified_wrap(Str $text, Int $width) returns Array of Str {
	my $rem = $text;
	my $line;

	my @array = gather loop {
		($line, $rem) = fit_in_width($rem, $width);
		# we have to force a copy here or take will end up with the same value
		# every single time! This might be a rakudo issue, or a spec issue
		# or just expected behaviour
		my $t = $line;
		take $t;
		$rem or last;
	};

	return @array;
}

sub trim_ending_whitespace(Str $line) {
	return $line.subst(/ <ws> $$ /, '');
}

# vim: ft=perl6 ts=4 sw=4 noexpandtab
