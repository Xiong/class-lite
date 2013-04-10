use strict;
use warnings;
use Test::More;

my $eval_err    ;
my $have        ;
my $want        ;
my $check       ;

# Construction
eval q{
    package Acme::Teddy;
    use Class::Lite qw| attr1 ho-ge attr3 |;
};

$eval_err       = $@;
$want           = qr/Invalid accessor name/;
$check          = 'Invalid accessor name (ho-ge)';
like( $eval_err, $want, $check );
note($eval_err);

eval q{
    package Acme::Teddy::Bear;
    use Class::Lite ( 'attr1', '', 'attr3' );
};

$eval_err       = $@;
$want           = qr/Invalid accessor name/;
$check          = 'Invalid accessor name (empty string)';
like( $eval_err, $want, $check );
note($eval_err);

eval q{
    package Acme::Teddy::Bird;
    my $wing    = [];
    use Class::Lite ( 'attr1', $wing, 'attr3' );
};

$eval_err       = $@;
$want           = qr/Invalid accessor name/;
$check          = 'Invalid accessor name (aryref)';
like( $eval_err, $want, $check );
note($eval_err);

eval q{
    package Acme::Teddy::Toad;
    my $legs    = 'string';
    use Class::Lite ( 'attr1', $legs, 'attr3' );
};

$eval_err       = $@;
$want           = qr/Invalid accessor name/;
$check          = 'Invalid accessor name (variable)';
like( $eval_err, $want, $check );
note($eval_err);


exit 0;



END {
    done_testing();
};
exit 0;

