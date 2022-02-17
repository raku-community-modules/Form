use Form::TextFormatting;
use Form::Grammar;
use Form::Actions;
use Form::Field;

sub form(*@args --> Str) is export {
	my @lines;
	my $result = '';

	my $actions = Form::Actions.new;

	while @args.elems {
		my $format = @args.shift;
		my $f = Form::Grammar.parse($format, :actions($actions));
		$f or die "form: error: argument '$format' is not a valid format string";
		my $nonliteral-field-count = $f.ast.grep( { $_ ~~ Form::Field::Field } ).elems;
		if @args.elems < $nonliteral-field-count {
			die "Insufficient number of data arguments ({@args.elems}) provided for format template '$format' which requires $nonliteral-field-count";
		}

		my @data;
		for ^$nonliteral-field-count {
			@data.push(@args.shift);
		}

		my @formatted;

		for @($f.ast) {
			when Str {
				@formatted.push([$_]);
			}
			when Form::Field::Field {
				@formatted.push([.format(@data.shift)]);
			}
		}

		my $most-lines = ([max] @formatted.map: *.elems);
		# RAKUDO: used to use $flines is rw and just overwrite in place that way
		# But it doesn't seem to work at the moment
		for (@($f.ast) Z (0..*)) -> ($field, $index) {
			if @formatted[$index].elems < $most-lines {
				if $field ~~ Form::Field::Field {
					@formatted[$index] = $field.align(@formatted[$index], $most-lines);
				}
				elsif $field ~~ Str {
					@formatted[$index] = $field xx $most-lines;
				}
			}
		}

		for ^$most-lines -> $line-number {
			my $line;
			for @formatted {
				$line ~= $_[$line-number];
			}
			$result ~= $line ~ "\n";
		}
	}

	$result
}

=begin pod

=head1 NAME

Form - A Raku implementation of Perl-style string formatting

=head1 SYNOPSIS

=begin code :lang<raku>

use Form;

=end code

=head1 DESCRIPTION

An implementation of Perl's Form module, as described by Exegesis 7 and
Damian Conway's Perl6::Form module.

This is a WORK IN PROGRESS and most likely doesn't work at any given time.

=head1 AUTHOR

Matthew Walton

Source can be located at: https://github.com/raku-community-modules/Form .
Comments and Pull Requests are welcome.

=head1 TODO

=item DOCUMENTATION
=item Data specified as lists
=item Numeric fields with decimal separator and justification
=item Numeric fields with thousands separators and justification
=item Currencies
=item Rendering of Complex numbers (currently restricted to Real)
=item Everything else

=head1 COPYRIGHT AND LICENSE

Copyright 2009 - 2012 Matthew Walton

Copyright 2013 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
