use strict;
use warnings;
use Test::More;
use utf8;

use Allegro::Parser::Plain;

note 'Allegro::Parser::Plain'; 
{
    my $parser = Allegro::Parser::Plain->new('./t/files/plain.alg');
    is ref($parser), "Allegro::Parser::Plain", "parse from file";
    my $record = $parser->next;
    ok $record->{_id} eq 'z0000264', 'record _id';
    ok $record->{record}->[0][0] eq '#00', 'tag from first field';
    is_deeply $record->{record}->[10], ['#94', ' ', '_', '14', 'b', '1845 - 1848, 28.9.; 1866 - 1933; 1941, 3.6. - 1945, 5.5.(L)'], 'field with subfield';
    is_deeply $record->{record}->[13], ['#99', 'n', '_', '20130115/14:57:17'], 'field with indicator';

    ok $parser->next()->{_id} eq 'z0000200', 'next record';
}

done_testing;
