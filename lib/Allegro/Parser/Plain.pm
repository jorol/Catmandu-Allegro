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

        # get last subfield from 001 as id
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

        # check for a 3-digit numeric tag
        if ($tag !~ m/^#[0-9]{2}$/xms) {
            carp "Invalid tag: \"$tag\"";
            next;
        }

        # check if indicator is an single alphabetic character
        if ($ind !~ m/^[0-9A-Za-z\s]$/xms) {
            carp "Invalid indicator: \"$ind\"";
            next;
        }

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

allegrc::Parser::Plain - Plain allegro-C format parser

=head2 DESCRIPTION

...

=cut
