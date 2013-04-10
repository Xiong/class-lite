use strict;
use warnings;
use Test::More;

sub me { note join q{ }, 'Current package: ', scalar caller };
my $eval_err    ;
my $have        ;
my $want        ;
my $check       ;
me;

eval {
    package Acme::Teddy;
    use Class::Lite qw| attr1 attr2 attr3 |;
};

$eval_err       = $@;

$check          = $eval_err ? $eval_err : 'use ok';
me;
ok( ! $eval_err, $check );

$check          = 'new';
my $self        = Acme::Teddy->new;
$have           = ref $self;
$want           = 'Acme::Teddy';
is( $have, $want, $check );

$check          = 'isa Class::Lite';
$have           = $self->isa('Class::Lite');
ok( $have, $check );

$check          = 'isa bridge';
$have           = $self->isa('Class::Lite::Acme::Teddy');
ok( $have, $check );



$check          = 'put_attr1';


END {
    done_testing();
};
exit 0;

