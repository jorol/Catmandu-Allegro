#!/usr/bin/perl

use strict;
use warnings;
use warnings qw(FATAL utf8);
use utf8;

use Test::More;
use Catmandu::Importer::Allegro;
use Catmandu::Fix;

my $pkg;
BEGIN {
    $pkg = 'Catmandu::Fix::Bind::allegro_each';
    use_ok $pkg;
}
require_ok $pkg;

my $fixer = Catmandu::Fix->new(fixes => [q|
    do allegro_each()
        if allegro_match('#8o.','\d+-[\dxX]')
            add_field(zdb,true)
        end
    end
|]);

my $importer = Catmandu::Importer::Allegro->new( file => './t/files/plain.alg', type => "PLAIN" );
my $record = $fixer->fix($importer->first);

ok exists $record->{record}, 'created a allegro record';
is $record->{zdb}, 'true', 'created field from condition';

done_testing;