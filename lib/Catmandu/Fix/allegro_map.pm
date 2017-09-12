package Catmandu::Fix::allegro_map;


our $VERSION = '0.12';

use Catmandu::Sane;
use Carp qw(confess);
use Moo;
use Catmandu::Fix::Has;

has allegro_path  => ( fix_arg => 1 );
has path      => ( fix_arg => 1 );
has record    => ( fix_opt => 1 );
has split     => ( fix_opt => 1 );
has join      => ( fix_opt => 1 );
has value     => ( fix_opt => 1 );
has pluck     => ( fix_opt => 1 );

sub emit {
    my ( $self, $fixer ) = @_;
    my $path       = $fixer->split_path( $self->path );
    my $record_key = $fixer->emit_string( $self->record // 'record' );
    my $join_char  = $fixer->emit_string( $self->join // '' );
    my $allegro_path  = $self->allegro_path;

    my $field_regex;
    my ( $field, $ind, $subfield_regex, $from, $to );

    if ( $allegro_path
        =~ /(#\S{2})(\[(.)\])?([_a-zA-Z0-9]+)?(\/(\d+)(-(\d+))?)?/ )
    {
        $field          = $1;
        $ind            = $3;
        $subfield_regex = defined $4 ? "[$4]" : "[_A-Za-z0-9]";
        $from           = $6;
        $to             = $8;
    }
    else {
        confess "invalid allegroc path";
    }

    $field_regex = $field;
    $field_regex =~ s/\*/./g;

    my $var  = $fixer->var;
    my $vals = $fixer->generate_var;
    my $perl = $fixer->emit_declare_vars( $vals, '[]' );

    $perl .= $fixer->emit_foreach(
        "${var}->{${record_key}}",
        sub {
            my $var  = shift;
            my $v    = $fixer->generate_var;
            my $perl = "";

            $perl .= "next if ${var}->[0] !~ /${field_regex}/;";

            if (defined $ind) {
                $perl .= "next if (!defined ${var}->[1] || ${var}->[1] ne '${ind}');";
            }

            if ( $self->value ) {
                $perl .= $fixer->emit_declare_vars( $v,
                    $fixer->emit_string( $self->value ) );
            }
            else {
                my $i = $fixer->generate_var;
                my $add_subfields = sub {
                    my $start = shift;
                    if ($self->pluck) {
                        # Treat the subfield_regex as a hash index
                        my $pluck = $fixer->generate_var;
                        return 
                        "my ${pluck}  = {};" .
                        "for (my ${i} = ${start}; ${i} < \@{${var}}; ${i} += 2) {".
                            "push(\@{ ${pluck}->{ ${var}->[${i}] } }, ${var}->[${i} + 1]);" .
                        "}" .
                        "for my ${i} (split('','${subfield_regex}')) { " .
                            "push(\@{${v}}, \@{ ${pluck}->{${i}} }) if exists ${pluck}->{${i}};" .
                        "}";
                    }
                    else {
                        # Treat the subfield_regex as regex that needs to match the subfields
                        return 
                        "for (my ${i} = ${start}; ${i} < \@{${var}}; ${i} += 2) {".
                            "if (${var}->[${i}] =~ /${subfield_regex}/) {".
                                "push(\@{${v}}, ${var}->[${i} + 1]);".
                            "}".
                        "}";
                    }
                };
                $perl .= $fixer->emit_declare_vars( $v, "[]" );
                $perl .= $add_subfields->(2);
                $perl .= "if (\@{${v}}) {";
                if ( !$self->split ) {
                    $perl .= "${v} = join(${join_char}, \@{${v}});";
                    if ( defined( my $off = $from ) ) {
                        my $len = defined $to ? $to - $off + 1 : 1;
                        $perl .= "if (eval { ${v} = substr(${v}, ${off}, ${len}); 1 }) {";
                    }
                }
                $perl .= $fixer->emit_create_path(
                    $fixer->var,
                    $path,
                    sub {
                        my $var = shift;
                        if ( $self->split ) {
                            "if (is_array_ref(${var})) {"
                                . "push \@{${var}}, ${v};"
                                . "} else {"
                                . "${var} = [${v}];" . "}";
                        }
                        else {
                            "if (is_string(${var})) {"
                                . "${var} = join(${join_char}, ${var}, ${v});"
                                . "} else {"
                                . "${var} = ${v};" . "}";
                        }
                    }
                );
                if ( defined($from) ) {
                    $perl .= "}";
                }
                $perl .= "}";
            }
            $perl;
        }
    );

    $perl;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Catmandu::Fix::allegro_map - copy Allegro values of one field to a new field

=head1 SYNOPSIS

    # Copy all #8o into the my.title hash
    allegro_map('#8o','my.title');

    # Copy the #93$b$c$d subfields into the my.coverage hash
    allegro_map('#93bcd','my.coverage');

    # Copy the #93$b$c$d subfields into the my.coverage array
    allegro_map('#93bcd','my.coverage.$append');
    
    # Copy the #99n characters 0-7 into the my.date hash
    allegro_map('#99[n]_/0-7','my.date');

=head1 SEE ALSO

L<Catmandu::Fix>

=head1 AUTHOR

Johann Rolschewski <jorol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
