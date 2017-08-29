package Catmandu::Fix::Bind::allegro_each;

our $VERSION = '0.01';

use Moo;
use Catmandu::Util;

with 'Catmandu::Fix::Bind';

has done => (is => 'ro');

sub unit {
    my ($self,$data) = @_;
    $self->{done} = 0;
    $data;
}

sub bind {
    my ($self,$mvar,$func,$name,$fixer) = @_;

    return $mvar if $self->done;

    my $rows = $mvar->{record} // [];

    my @new = ();

    for my $row (@{$rows}) {

        $mvar->{record} = [$row];

        my $fixed = $fixer->fix($mvar);

        push @new , @{$fixed->{record}} if defined($fixed) && exists $fixed->{record};
    }

    $mvar->{record} = \@new if exists $mvar->{record};

    $self->{done} = 1;

    $mvar;
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Catmandu::Fix::Bind::allegro_each - a binder that loops over Allegro fields

=head1 SYNOPSIS

    # Only add matching fields
    do allegro_each()
        if allegro_match(...)
            allegro_map(...)
        end
    end

    # Delete  fields
    do allegro_each()
        if allegro_match(...)
            reject()
        end
    end

=head1 DESCRIPTION

The allegro_each binder will iterate over each individual allegor-C field and execute the fixes only in context over each individual field.

If a allegro-C record contains:

    #8o 6.10.1845: $ªDerª Bote$z2017384-2
    #8o11.4.1866: $ªDerª Bote vom Geising$z1318084-8
    #8o21.10.1878: $ªDerª Bote vom Geising und Mglitzthal-Zeitung$z1318091-5
    #8o33.6.1941: $Mglitztal- und Geising-Bote$z2077400-X

then the fix

    do allegro_each()
        allegro_map("#8oz",id.$append)
    end

will have the same effect as

    allegro_map("#8oz",id.$append)

because C<allegro_map> by default loops over all repeated Allegro fields. But the C<allegro_each> bind has the advantage to process fields in 
context. E.g. to only map fields where the subfield $ doesn't contain '' 
you can write:

    do allegro_each()
        if allegro_match("#00","^z")
            add_field("format","serial")
        end
    end

=head1 SEE ALSO

L<Catmandu::Fix::Bind>

=head1 AUTHOR

Johann Rolschewski <jorol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
