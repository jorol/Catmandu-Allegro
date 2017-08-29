package Catmandu::Importer::Allegro;

our $VERSION = '0.01';

use Catmandu::Sane;
use Moo;
use Allegro::Parser::Plain;

with 'Catmandu::Importer';

has type => ( is => 'ro', default => sub {'Plain'} );
has id   => ( is => 'ro', default => sub {'#00'} );

sub mab_generator {
    my $self = shift;

    my $file;
    my $type = lc($self->type);
    if ( $type eq 'plain' ) {
        $file =Allegro::Parser::Plain->new( $self->fh );
    }
    else {
        die "unknown format";
    }

    my $id = $self->id;

    sub {
        my $record = $file->next();
        return unless $record;
        return $record;
    };
}

sub generator {
    my ($self) = @_;
    
    my $type = lc($self->type);
    if ( $type =~ /plain$/ ) {
        return $self->mab_generator;
    }
    else {
        die "need Allegro Plain data";
    }
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Catmandu::Importer::Allegro - Package that imports Allegro data

=head1 SYNOPSIS

    use Catmandu::Importer::Allegro;

    my $importer = Catmandu::Importer::Allegro->new(file => "./t/plain.alg", type=> "plain");

    my $n = $importer->each(sub {
        my $hashref = $_[0];
        # ...
    });

To convert between Allegro syntax variants with the L<catmandu> command line client:

    catmandu convert Allegro --type raw to Allegro --type xml < plain.alg

=head1 Allegro

The parsed Allegro record is a HASH containing two keys '_id' containing the #00 field (or the system
identifier of the record) and 'record' containing an ARRAY of ARRAYs for every field:

 {
  'record' => [
                [
                    '001',
                    ' ',
                    '_',
                    'fol05882032 '
                ],
                [
                    245,
                    'a',
                    'a',
                    'Cross-platform Perl /',
                    'c',
                    'Eric F. Johnson.'
                ],
        ],
  '_id' => 'fol05882032'
 } 

=head1 METHODS

This module inherits all methods of L<Catmandu::Importer> and by this
L<Catmandu::Iterable>.

=head1 CONFIGURATION

In addition to the configuration provided by L<Catmandu::Importer> (C<file>,
C<fh>, etc.) the importer can be configured with the following parameters:

=over

=item type

Describes the Allegro syntax variant. Supported values (case ignored) include the
default value C<xml> for MABxml, C<disk> for human-readable Allegro serialization 
("Diskettenformat") or C<raw> for data-exchange Allegro serialization ("Bandformat").

=back

=head1 AUTHOR

Johann Rolschewski <jorol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
