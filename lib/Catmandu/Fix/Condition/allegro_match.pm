package Catmandu::Fix::Condition::allegro_match;

our $VERSION = '0.01';

use Catmandu::Sane;
use Catmandu::Fix::allegro_map;
use Catmandu::Fix::Condition::all_match;
use Catmandu::Fix::set_field;
use Catmandu::Fix::remove_field;
use Moo;
use Catmandu::Fix::Has;

with 'Catmandu::Fix::Condition';

has allegro_path => ( fix_arg => 1 );
has value    => ( fix_arg => 1 );

sub emit {
    my ( $self, $fixer, $label ) = @_;

    my $perl;

    my $tmp_var = '_tmp_' . int( rand(9999) );
    my $allegro_map
        = Catmandu::Fix::allegro_map->new( $self->allegro_path, "$tmp_var.\$append" );
    $perl .= $allegro_map->emit( $fixer, $label );

    my $all_match = Catmandu::Fix::Condition::all_match->new( "$tmp_var.*",
        $self->value );
    my $remove_field = Catmandu::Fix::remove_field->new($tmp_var);

    my $pass_fixes = $self->pass_fixes;
    my $fail_fixes = $self->fail_fixes;

    $all_match->pass_fixes( [ $remove_field, @$pass_fixes ] );
    $all_match->fail_fixes( [ $remove_field, @$fail_fixes ] );

    $perl .= $all_match->emit( $fixer, $label );

    $perl;
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Catmandu::Fix::Condition::allegro_match - Conditionals on Allegro fields

=head1 SYNOPSIS

    # allegro_match(ALLEGRO_PATH,REGEX)

    if allegro_match('#89Z','\d+-[\dxX]')
    add_field('zdb','true')
    end

=head1 DESCRIPTION

Read our Wiki pages at L<https://github.com/LibreCat/Catmandu/wiki/Fixes> 
for a complete overview of the Fix language.

=head1 NAME

Catmandu::Fix::Condition::allegro_match - Conditionals on PICA fields

=head1 SEE ALSO

L<Catmandu::Fix>

=head1 AUTHOR

Johann Rolschewski <jorol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
