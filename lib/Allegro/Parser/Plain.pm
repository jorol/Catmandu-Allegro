package Allegro::Parser::Plain;
use strict;
use warnings;

our $VERSION = '0.01';

use charnames ':full';
use Carp qw(carp croak);

use Readonly;

Readonly my $SUBFIELD_INDICATOR => qq{\N{INFORMATION SEPARATOR ONE}};
Readonly my $END_OF_FIELD       => qq{\N{LINE FEED}};
Readonly my $END_OF_RECORD      => q{};

sub new {
    my $class = shift;
    my $file  = shift;

    my $self = {
        filename   => undef,
        rec_number => 0,
        reader     => undef,
    };

    # check for file or filehandle
    my $ishandle = eval { fileno($file); };
    if ( !$@ && defined $ishandle ) {
        $self->{filename} = scalar $file;
        $self->{reader}   = $file;
    }
    elsif ( -e $file ) {
        open $self->{reader}, '<:encoding(UTF-8)', $file
            or croak "cannot read from file $file\n";
        $self->{filename} = $file;
    }
    else {
        croak "file or filehande $file does not exists";
    }
    return ( bless $self, $class );
}


sub next {
    my $self = shift;
    local $/ = $END_OF_RECORD;
    if ( my $data = $self->{reader}->getline() ) {
        $self->{rec_number}++;
        my $record = _decode($data);

        # get last subfield from #00 as id
        my ($id) = map { $_->[-1] } grep { $_->[0] =~ '#00' } @{$record};
        return { _id => $id, record => $record };
    }
    return;
}


sub _decode {
    my $reader = shift;
    chomp($reader);

    my @record;

    my @fields = split($END_OF_FIELD, $reader);

    foreach my $field (@fields) {
        if (length($field) <= 4) {
            carp "incomplete field: \"$field\"";
            next,
        }

        my $tag = substr( $field, 0, 3 );
        my $ind = substr( $field, 3, 1 );
        my $data = substr( $field, 4 );

        # check for #2-digit tag
        if ($tag !~ m/^#[0-9]{2}$/xms) {
            carp "Invalid tag: \"$tag\"";
            next;
        }


        # check indicator
        # disabled, as exact form not clear        
        # if ($ind !~ m/^[0-9A-Za-z\s]$/xms) {
        #     carp "Invalid indicator: \"$ind\"";
        #     next;
        # }

        my @data_elements = split $SUBFIELD_INDICATOR, $data;

        push(
                @record,
                [   $tag,
                    $ind,
                    '_',
                    shift @data_elements,
                    map { substr( $_, 0, 1 ), substr( $_, 1 ) } @data_elements
                ]
            );
        }
    return \@record;    
}


1;

__END__

=head1 NAME

Allegro::Parser::Plain - Allegro plain format parser

=head1 SYNOPSIS

L<Allegro::Parser::Plain> is a parser for Allegro records, like:

    #00 z0010000
    #74 Berlin
    #8n Sozialistische Einheit
    #8o Hrsg. Organisationsausschuß SPD und KPD
    ...

L<Allegro::Parser::Plain> expects UTF-8 encoded files as input. Otherwise 
provide a filehande with a specified I/O layer.

    use Allegro::Parser::Plain;

    my $parser = Allegro::Parser::Plain->new( $filename );

    while ( my $record_hash = $parser->next() ) {
        # do something        
    }

=head1 Arguments

=over

=item C<file>

Path to file with Allegro records.

=item C<fh>

Open filehandle for file with Allegro records.

=back

=head1 METHODS

=head2 new($filename | $filehandle)

=head2 next()

Reads the next record from Allegro input stream. Returns a Perl hash.

=head2 _decode($record)

Deserialize a Allegro record to an ARRAY of ARRAYs.

=head1 SEE ALSO

L<Catmandu::Importer::Allegro>.

=head1 AUTHOR

Johann Rolschewski <jorol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut