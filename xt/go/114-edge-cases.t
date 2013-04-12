use strict;
use warnings;
use Test::More;

#~ use Devel::Comments '###', ({ -file => 'debug.log' });                   #~

my $eval_err    ;
my $have        ;
my $want        ;
my $check       ;

# Construction
eval {
    BEGIN {
        package Module::Empty;
        use Class::Lite qw| attr1 attr2 attr3 |;
    }
};
$eval_err       = $@;

$check          = $eval_err ? $eval_err : 'use ok';
ok( ! $eval_err, $check );

$check          = 'wrongly import/subclass';
# Module::Empty inherited import() but that method short-circuits 
#   when called by ::Bear on the use-line. 
# So no ISA relationship is set, ::Bear does not inherit new(), 
#   and use-line args are discarded.
{
    package Module::Empty::Bear;
    use Module::Empty qw| foo bar baz |;
}
pass( $check );

$check          = 'new in wrongly import/subclass';
eval {
    my $self        = Module::Empty::Bear->new;
};
$eval_err       = $@;
$want           = qr/Can't locate object method/;
like( $eval_err, $want, $check );

$check          = 'rightly import';
#
BEGIN {
    package Module::Empty;
    sub import {
        ### @_
        shift;
        my $caller      = caller;
        my $imsym       = 'IMPORTS';
        no strict 'refs';
        push @{"${caller}::$imsym"}, @_;
        ### @_
        ### @Module::Empty::Cub::IMPORTS
    };
}
BEGIN {
    package Module::Empty::Cub;
    use Module::Empty qw| foo bar baz |;
}
pass( $check );

$check          = 'rightly import show imports';
$have           = \@Module::Empty::Cub::IMPORTS;
$want           = [qw| foo bar baz |];
is_deeply( $have, $want, $check );

### %INC
exit 0;

my $self;   # DUMMY

$check          = 'isa Class::Lite';
$have           = $self->isa('Class::Lite');
ok( $have, $check );

$check          = 'isa Class::Lite';
$have           = $self->isa('Class::Lite');
ok( $have, $check );

$check          = 'isa bridge';
$have           = $self->isa('Class::Lite::Module::Empty');
ok( $have, $check );

# Access
$check          = 'put_attr1';
$self->put_attr1('foo');
$have           = $self->{attr1};
$want           = 'foo';
is( $have, $want, $check );
$check          = 'get_attr1';
$have           = $self->get_attr1;
is( $have, $want, $check );

$check          = 'put_attr2';
$self->put_attr2(42.5);
$have           = $self->{attr2};
$want           = 42.5;
cmp_ok( $have, '==', $want, $check );
$check          = 'get_attr2';
$have           = $self->get_attr2;
cmp_ok( $have, '==', $want, $check );

$check          = 'put_attr3';
my $bazref      = [];
$self->put_attr3($bazref);
$have           = $self->{attr3};
$want           = $bazref;
is( $have, $want, $check );
$check          = 'get_attr3';
$have           = $self->get_attr3;
is( $have, $want, $check );



END {
    done_testing();
};
exit 0;

