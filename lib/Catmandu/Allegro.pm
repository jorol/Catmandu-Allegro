package Catmandu::Allegro;

our $VERSION = '0.01';

use strict;
use warnings;


1; # End of Catmandu::Allegro

__END__

=pod

=encoding UTF-8

=head1 NAME

Catmandu::Allegro - Catmandu modules for working with Allegro data.

=begin markdown

[![Build Status](https://travis-ci.org/jorol/Catmandu-Allegro.png)](https://travis-ci.org/jorol/Catmandu-Allegro)
[![Coverage Status](https://coveralls.io/repos/jorol/Catmandu-Allegro/badge.png?branch=devel)](https://coveralls.io/r/jorol/Catmandu-Allegro?branch=devel)
[![Kwalitee Score](http://cpants.cpanauthors.org/dist/Catmandu-Allegro.png)](http://cpants.cpanauthors.org/dist/Catmandu-Allegro)
[![CPAN version](https://badge.fury.io/pl/Catmandu-Allegro.png)](http://badge.fury.io/pl/Catmandu-Allegro)

=end markdown

=head1 DESCRIPTION

Catmandu::Allegro provides methods to work with Allegero data within the 
L<Catmandu> framework. See L<Catmandu::Introduction> and 
L<http://librecat.org/> for an introduction into Catmandu.

=head1 CATMANDU MODULES

=over

=item * L<Catmandu::Importer::Allegro>

=item * L<Catmandu::Fix::allegro_map>

=item * L<Catmandu::Fix::Bind::allegro_each>

=item * L<Catmandu::Fix::Condition::allegro_match>

=back

=head1 INTERNAL MODULES

Parser and writer for Allegro data.

=over

=item * L<Allegro::Parser::Plain>

=back

=head1 AUTHOR

Johann Rolschewski <jorol@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
