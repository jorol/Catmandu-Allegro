use strict;
use warnings;
use Test::More;

use Catmandu;
use Catmandu::Fix;
use Catmandu::Importer::Allegro;

my $fixer = Catmandu::Fix->new(fixes => [
	'allegro_map("#00", "leader")',
	'allegro_map("#89[Z]", "id")',
	'allegro_map("#8n", "title")',
    'allegro_map("#8o[ ]z", "parallel_title")',
    'allegro_map("#8oz", "parallel_titles.$append")',
	'allegro_map("#93_", "coverage")',
	'remove_field("record")',
	'remove_field("_id")']);
my $importer = Catmandu::Importer::Allegro->new(file => "./t/files/plain.alg", type=> "PLAIN");
my $records = $fixer->fix($importer)->to_array();

ok $records->[0]->{'leader'} eq 'z0000264', 'fix tag';
ok $records->[0]->{'title'} =~ m/Bote vom Geising$/, 'fix alphanumeric tag';
ok $records->[0]->{'id'} eq '1318084-8', 'fix tag and indicator';
ok $records->[0]->{'parallel_title'} eq '2017384-2', 'fix tag, indicator, subfield';
is_deeply $records->[0]->{'parallel_titles'}, ['2017384-2', '1318084-8', '1318091-5', '2077400-X' ], 'fix tag, subfield append';
ok $records->[0]->{'coverage'} eq '14', 'fix tag main field';

done_testing;