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

A C<Test::NaiveStubs> generates a test file of stubs for exercising all the
methods (not functions) of a given B<class>.

For a more powerful alternative, check out L<Test::StubGenerator>.

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
    is      => 'ro',
    default => sub { 't/test.t' },
);

=head1 METHODS

=head2 new()

  $tns = Test::NaiveStubs->new(%arguments);

Create a new C<Test::NaiveStubs> object.

=head2 gather_methods()

  $methods = $tns->gather_methods;

Return the methods of the given B<class> as a hash reference.

=cut

sub gather_methods {
    my ($self) = @_;

    my $sniff = Class::Sniff->new({ class => $self->class });
    my @methods = $sniff->methods;
    my %methods;
    @methods{@methods} = undef;

    return \%methods;
}

=head2 unit_test()

  $test = $tns->unit_test($method);

Return the text of a method unit test.

=cut

sub unit_test {
    my ($self, $subroutine) = @_;

    my $test = '';

    if ( $subroutine eq 'new' ) {
        $test = 'use_ok "' . $self->class . '";';
            . "\n\n"
            . 'my $obj = ' . $self->class . '->new;'
            . "\n"
            . 'isa_ok $obj, "' . $self->class . '";';
    }
    else {
        $test = 'ok $obj->' . $subroutine . ', "' . $subroutine . '";';
    }

    return $test;
}

=head2 create_test()

  $tns->create_test;

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

    my $methods = $self->gather_methods;

    if ( exists $methods->{new} ) {
        delete $methods->{new};
        my $test = $self->unit_test('new');
        $text .= "$test\n\n";
    }

    for my $method ( sort keys %$methods ) {
        my $test = $self->unit_test($method);
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
