package Class::Lite;
# Choose minimum perl interpreter version; delete the rest.
# Do you want to enforce the bugfix level?
#~ use 5.008008;   # 5.8.8     # 2006  # oldest sane version
#~ use 5.008009;   # 5.8.9     # 2008  # latest 5.8
#~ use 5.010001;   # 5.10.1    # 2009  # say, state, switch
#~ use 5.012003;   # 5.12.5    # 2011  # yada
#~ use 5.014002;   # 5.14.3    # 2012  # pop $arrayref, copy s///r
#~ use 5.016002;   # 5.16.2    # 2012  # __SUB__
use strict;
use warnings;
use version; our $VERSION = qv('v0.0.0');

# Alternate uses
#~ use Devel::Comments '###', ({ -file => 'debug.log' });                   #~

## use
#============================================================================#

#=========# CLASS METHOD
#~ my $self    = My::Class->new(@_);
#
#   Classic hashref-based-object constructor.
#   Passes any arguments to init().
#   
sub new {
    my $class   = shift;
    my $self    = {};
    bless ( $self => $class );
    $self->init(@_);
    return $self;
}; ## new

#=========# OBJECT METHOD
#~ $self->init(@_);
#
#   Abstract method does nothing. Override in your class.
#   
sub init {
    return shift;
}; ## init

#=========# EXTERNAL FUNCTION
#~ use Class::Lite qw| attr1 attr2 attr3 |;
#~ use Class::Lite qw|             # Simple base class with get/put accessors
#~     attr1
#~     attr2
#~     attr3
#~ |;
#
#   @
#   
sub import {
    return unless shift eq q{Class::Lite};
    my $caller      = caller;
    my $bridge      = qq{Class::Lite::$caller};
    
    # Do most work in the bridge class.    
    eval join qq{\n},
        qq* package $bridge;                                            *,
        qq* our  \@ISA;                                                 *,
        qq* push \@ISA, 'Class::Lite';                                  *,
        map {
            defined and ! ref and /^[^\W\d]\w*\z/s
                or die "Invalid accessor name '$_'";
              qq* sub get_$_ { return \$_[0]->{$_} };                   *
            . qq* sub put_$_ { \$_[0]->{$_} = \$_[1]; return \$_[0] };  *
        } @_,
    ;
    die "Failed to generate $bridge: $@" if $@;
    
    # Make caller inherit from bridge.
    eval join qq{\n},
        qq* package $caller;                                            *,
        qq* our  \@ISA;                                                 *,
        qq* push \@ISA, '$bridge';                                      *,
    ;
    die "Failed to generate $caller: $@" if $@;
    
    return 1;    
}; ## import

## END MODULE
1;
#============================================================================#
__END__

=head1 NAME

Class::Lite - Simple base class with get/put accessors

=head1 VERSION

This document describes Class::Lite version v0.0.0

=head1 SYNOPSIS

    package Toy::Class;
    use Class::Lite qw| foo bar baz |;              # make get/put accessors
    
    package Any::Class;
    use Toy::Class;
    my $toy     = Toy::Class->new;
    $toy->init(@_);                                 # does nothing; override
    $toy->put_foo(42);
    my $answer  = $toy->get_foo;
    
    use Class::Lite;                                # no accessors

=head1 DESCRIPTION

=over

I<< Nature's great masterpiece, an elephant, 
The only harmless great thing.  >> 
-- John Donne

=back

The hashref-based base class that does no more than it must. Your 
constructor and accessors are defined in a generated package so you can 
override them easily. 

=head1 Why?

Computer programmers are clever people who delight in evading restrictions.
Create an L<< inside-out|Class::Std >> (flyweight) class to enforce 
encapsulation and another fellow will L<< hack in|PadWalker >>. The only 
way to win the ancient game of locksmith and lockpick is never to begin. 
If someone misuses your class then it's not your responsibility. 
Hashref-based objects are traditional, well-understood, even expected in 
the Perl world; tools exist with which to work with them. 

Similarly, C<< Class::Lite >> provides no read-only accessors. If your client 
developer wants to alter an attribute he will; you may as well provide a 
method for the purpose. You might warn against the practice by overriding 
the default method: 

    sub put_foo {
        warn q{Please don't write to the 'foo' attribute.};
        my $self    = shift;
        return $self->SUPER::put_foo(@_);
    };

B<< set >> is too similar to B<< get >> in one way, not enough in another. 
Also B<< set >> is one of those heavily overloaded words, like "love" or 
"data", that I prefer to avoid using at all. I say B<< put >> is equally 
short, clearer in intent, not easily misread for B<< get >>; and the first 
character's descender points in the opposite direction.

I belong to the school that eschews single-method "mutator" accessors. 

I have long defined C<< init() >> as a shortcut method to fill up a new 
object; but this is a blatant violation of encapsulation, no matter who 
does it. No more. 

If accessors are defined in your calling package then you will raise a 
warning if you attempt to redefine them; if they are defined in 
C<< Class::Lite >> itself then they will be available to all that inherit 
from it. So your accessors are defined in an intermediate package 
generated at compile-time. 

=head1 USE-LINE

    package Toy::Class;
    use Class::Lite qw| foo bar baz |;              # make get/put accessors
    use Class::Lite;                                # no accessors

Makes C<< Class::Lite >> a base class for Toy::Class. If arguments are 
given then simple get and put accessors will be created in caller's 
namespace for each argument. 

=head1 CLASS METHOD 

=head2 new()

    my $obj = Class::Lite->new(@_);

Blesses an anonymous hash reference into the given class 
which inherits from Class::Lite. Passes all its args to init(). 

=head1 OBJECT METHOD 

=head2 init()

    my $obj = $old->init(@_);

This abstract method does nothing at all and returns its object. 
You may wish to override it in your class. 

=head1 INHERITED FUNCTION 

    import(@_);

Called by use() as usual and does all the work. If called from any class 
other than Class::Lite, returns without doing anything. 

Since this is merely inherited you may define your own import() with impunity.

=head1 GENERATED METHODS 

Accessor methods are generated for each argument on the use-line. 
They all do just what you'd expect. No type checking is done. 

    $self   = $self->put_attr($foo);
    $foo    = $self->get_attr;

Put accessors return the object. Get accessors discard any arguments.

=head1 SEE ALSO

L<< Object::Tiny|Object::Tiny >>

=head1 INSTALLATION

This module is installed using L<< Module::Build|Module::Build >>. 

=head1 DIAGNOSTICS

=over

=item C<< Invalid accessor name... >>

You passed something horrible on the use-line. Valid arguments to 
C<< import >> need to be valid Perl identifiers. If you have in your class 
some C<< '-$/' >> attribute (which is a valid hash key) then you'll have to 
write your own accessors for it. You won't be able to call them, for example, 
C<< get_-$/() >>.

=item C<< Failed to generate (package) >>

Something evil happened while doing the heavy lifting: getting into your package, getting into the bridge package, setting up the ISA relationships, or defining requested accessors. This should never happen and isn't your fault. Please make a bug report. 

=item C<< some error message >>

Some explanation. 

=item C<< some error message >>

Some explanation. 

=back

=head1 CONFIGURATION AND ENVIRONMENT

None. 

=head1 DEPENDENCIES

There are no non-core dependencies. 

=begin html

<!--

=end html

L<< version|version >> 0.99 E<10> E<8> E<9>
Perl extension for Version Objects

=begin html

-->

<DL>

<DT>    <a href="http://search.cpan.org/perldoc?version" 
            class="podlinkpod">version</a> 0.99 
<DD>    Perl extension for Version Objects

</DL>

=end html

This module should work with any version of perl 5.8.8 and up. 
However, you may need to upgrade some core modules. 

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

This is an early release. Reports and suggestions will be warmly welcomed. 

Please report any issues to: 
L<< https://github.com/Xiong/class-lite/issues >>.

=head1 DEVELOPMENT

This project is hosted on GitHub at: 
L<< https://github.com/Xiong/class-lite >>. 

=head1 THANKS

Adam Kennedy (ADAMK) for L<< Object::Tiny|Object::Tiny >>,  on which much of 
this module's code is based. 

=head1 AUTHOR

Xiong Changnian C<< <xiong@cpan.org> >>

=head1 LICENSE

Copyright (C) 2013 
Xiong Changnian C<< <xiong@cpan.org> >>

This library and its contents are released under Artistic License 2.0:

L<< http://www.opensource.org/licenses/artistic-license-2.0.php >>

=cut




