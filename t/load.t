use strict;
use Test::More;

use_ok 'Allegro::Parser::Plain';
use_ok 'Catmandu::Allegro';
use_ok 'Catmandu::Importer::Allegro';
use_ok 'Catmandu::Fix::allegro_map';
use_ok 'Catmandu::Fix::Bind::allegro_each';
use_ok 'Catmandu::Fix::Condition::allegro_match';

done_testing;