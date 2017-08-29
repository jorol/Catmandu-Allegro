requires 'perl', '5.008005';

requires 'Carp', '0';
requires 'Catmandu', '1.0601';
requires 'Readonly', '0';

on test => sub {
    requires 'Test::More', '0.96';
};
