use strict;
use warnings;
use Test::Exception;
use Test::More;

use Catmandu;
use Catmandu::Importer::Allegro;

note 'Catmandu::Importer::Allegro Plain';
{
    my $importer = Catmandu::Importer::Allegro->new(
        file => './t/files/plain.alg',
        type => 'Plain'
    );
    my $records = $importer->to_array;
    is scalar @{$records}, 10, 'got records';
    is $records->[0]->{record}->[0]->[3], 'z0000264', 'got record value';
}

done_testing;
