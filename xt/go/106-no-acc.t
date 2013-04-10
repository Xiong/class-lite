use strict;
use warnings;
use Test::More;

my $eval_err    ;
my $have        ;
my $want        ;
my $check       ;

# Construction
eval {
    package Acme::Teddy;
    use Class::Lite;
};

{
    package Acme::Teddy::Bear;
    use parent 'Acme::Teddy';
}

$eval_err       = $@;

$check          = $eval_err ? $eval_err : 'use ok';
ok( ! $eval_err, $check );

$check          = 'new parent';
my $self        = Acme::Teddy->new;
$have           = ref $self;
$want           = 'Acme::Teddy';
is( $have, $want, $check );

$check          = 'parent isa Class::Lite';
$have           = $self->isa('Class::Lite');
ok( $have, $check );

$check          = 'parent isa bridge';
$have           = $self->isa('Class::Lite::Acme::Teddy');
ok( $have, $check );

$check          = 'new child';
my $woot        = Acme::Teddy::Bear->new;
$have           = ref $woot;
$want           = 'Acme::Teddy::Bear';
is( $have, $want, $check );

$check          = 'child isa Class::Lite';
$have           = $woot->isa('Class::Lite');
ok( $have, $check );

$check          = 'child isa bridge';
$have           = $woot->isa('Class::Lite::Acme::Teddy');
ok( $have, $check );

$check          = 'child isa parent';
$have           = $woot->isa('Acme::Teddy');
ok( $have, $check );



END {
    done_testing();
};
exit 0;

