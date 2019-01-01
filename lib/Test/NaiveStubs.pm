package Test::NaiveStubs;

# ABSTRACT: Generate test stubs for methods

our $VERSION = '0.0100';

use Moo;
use strictures 2;
use namespace::clean;

use Class::Sniff;

=head1 SYNOPSIS

  use Test::NaiveStubs;
  my $tns = Test::NaiveStubs->new(
    class => 'Foo::Bar',
    name  => 't/foo-bar.t',
  );

=head1 DESCRIPTION

A C<Test::NaiveStubs> generates test stubs for methods.

=head1 ATTRIBUTES

=head2 class

The class name to use in the test generation.

=cut

has class => (
    is => 'ro',
);

=head2 name

The test output file name.

=cut

has name => (
    is => 'ro',
);

=head1 METHODS

=head2 new()

  $tns = Test::NaiveStubs->new(%arguments);

Create a new C<Test::NaiveStubs> object.

=head2 gather_subs()

Return the methods of the given B<class> as a hash reference.

=cut

sub gather_subs {
    my ($self) = @_;

    my $sniff = Class::Sniff->new({ class => $self->class });
    my @methods = $sniff->methods;
    my %methods;
    @methods{@methods} = undef;

    return \%methods;
}

=head2 unit_test

Return the text of a method unit test.

=cut

sub unit_test {
    my ($self, $subroutine) = @_;

    my $test = '';

    if ( $subroutine eq 'new' ) {
        $test = '$obj = ' . $self->class . '->new();'
            . "\n"
            . 'isa_ok $obj, "' . $self->class . '";';
    }
    else {
        $test = 'ok $obj->' . $subroutine . ', "' . $subroutine . '";';
    }

    return $test;
}

=head2 create_test

Create a test file with unit tests for each method.

=cut

sub create_test {
    my ($self) = @_;

    open my $fh, '>', $self->name or die "Can't write " . $self->name . ": $!";

    my $text =<<"END";
use strict;
use warnings;

use Test::More;

END

    my $subs = $self->gather_subs;

    if ( exists $subs->{new} ) {
        delete $subs->{new};
        my $test = $self->unit_test('new');
        $text .= "$test\n\n";
    }

    for my $sub ( sort keys %$subs ) {
        my $test = $self->unit_test($sub);
        $text .= "$test\n\n";
    }

    print $fh $text;
}

1;
__END__

=head1 SEE ALSO

L<Moo>

L<Class::Sniff>

=cut
