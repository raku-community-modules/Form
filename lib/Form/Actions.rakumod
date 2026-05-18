use Form::Field;
use Form::Types;

sub thou-info(Str $int-part, Str $bracket) {
    my $sep = $int-part.comb.first({ $_ ne $bracket });
    return ('', []) unless $sep.defined;
    my $groups = [$int-part.split($sep).map(*.chars).reverse];
    ($sep, $groups)
}

class Form::Actions {

    method centred_field($/) {
        make $/.hash.values.[0].ast;
    }

    method centred_block_field($/) {
        make Form::Field::Text.new(
        	:justify(Justify::centre),
        	:block(Bool::True),
        	:width((~$/).chars + 2)
        );
    }

    method centred_line_field($/) {
        make Form::Field::Text.new(
        	:justify(Justify::centre),
        	:block(Bool::False),
        	:width((~$/).chars + 2)
        );
    }

    method fully_justified_field($/) {
        make $/.hash.values.[0].ast;
    }

    method justified_line_field($/) {
        make Form::Field::Text.new(
        	:justify(Justify::full),
        	:block(Bool::False),
        	:width((~$/).chars + 2)
        );
    }

    method justified_block_field($/) {
        make Form::Field::Text.new(
        	:justify(Justify::full),
        	:block(Bool::True),
        	:width((~$/).chars + 2)
        );
    }

    method right_justified_line_field($/) {
        make Form::Field::Text.new(
        	:justify(Justify::right),
        	:block(Bool::False),
        	:width((~$/).chars + 2)
        );
    }

    method right_justified_block_field($/) {
        make Form::Field::Text.new(
        	:justify(Justify::right),
        	:block(Bool::True),
        	:width((~$/).chars + 2)
        );
    }

    method left_justified_line_field($/) {
        make Form::Field::Text.new(
            :justify(Justify::left),
            :block(Bool::False),
            :width((~$/).chars + 2)
        );
    }

    method left_justified_block_field($/) {
        make Form::Field::Text.new(
        	:justify(Justify::left),
        	:block(Bool::True),
        	:width((~$/).chars + 2)
        );
    }
    
    method right_justified_field($/) {
        make $/.hash.values.[0].ast;
    }

    method left_justified_field($/) {
        make $/.hash.values.[0].ast;
    }

    method numeric_field($/) {
        make $/.hash.values.[0].ast;
    }

    method numeric_block_field($/) {
        my ($thou-sep, $groups) = thou-info(~$<int-part>, ']');
        make Form::Field::Numeric.new(
            :block(Bool::True),
            :width((~$/).chars + 2),
            :ints-width($<int-part>.chars + 1),
            :fracs-width($<frac-part>.chars + 1),
            :decimal-marker(~$<decimal>),
            :thousands-sep($thou-sep),
            :group-sizes($groups)
        );
    }

    method numeric_line_field($/) {
        my ($thou-sep, $groups) = thou-info(~$<int-part>, '>');
        make Form::Field::Numeric.new(
            :block(Bool::False),
            :width((~$/).chars + 2),
            :ints-width($<int-part>.chars + 1),
            :fracs-width($<frac-part>.chars + 1),
            :decimal-marker(~$<decimal>),
            :thousands-sep($thou-sep),
            :group-sizes($groups)
        );
    }

    method verbatim_field($/) {
        make $/.hash.values.[0].ast;
    }

    method verbatim_line_field($/) {
        make Form::Field::Verbatim.new(
        	:block(Bool::False),
        	:width((~$/).chars + 2)
        );
    }
    
    method verbatim_block_field($/) {
        make Form::Field::Verbatim.new(
        	:block(Bool::True),
        	:width((~$/).chars + 2)
        );
    }

    method aligned_field($/) {
        make $/.hash.values.[0].ast;
    }

    method centre_aligned_field($/) {
        my $f = $/<aligned_field>.ast;
        $f.alignment = Alignment::centre;
        make $f;
    }

    method bottom_aligned_field($/) {
        my $f = $/<aligned_field>.ast;
        $f.alignment = Alignment::bottom;
        make $f;
    }

    method top_aligned_field($/) {
        my $f = $/<aligned_field>.ast;
        $f.alignment = Alignment::top;
        make $f;
    }

    method field($/?) {
        make $/.hash.values.[0].ast;
    }

    method field_or_literal($/) {
        make $/.hash.values.[0].ast;
    }

    method literal($/) {
        make ~$/;
    }

    method TOP($/) {
        # gather, in order, the sequence of <literal> and <field> matches
        # make a list of those
        # What we do is iterate through the submatches and pull out the result objects into an array
        # Might as well do it lazily
        # The question is, is this the right way to get the list of submatches
        # since $/[0] etc. work, $/ in list context should be that list...
        my @matches = gather for @( $/<field_or_literal> ) -> $m {
            take $m.ast; 
        }
        
        make @matches;
    }
}

# vim: expandtab shiftwidth=4
