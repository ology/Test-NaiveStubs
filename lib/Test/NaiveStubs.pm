package Test::NaiveStubs;

# ABSTRACT: Generate test stubs for methods and functions

our $VERSION = '0.0503';

use Moo;
use strictures 2;
use namespace::clean;

use Class::Sniff;

=head1 SYNOPSIS

  use Foo::Bar;
  use Test::NaiveStubs;

  my $tns = Test::NaiveStubs->new(
    module => 'Foo::Bar',
    name   => 't/foo-bar.t',
  );

  $tns->create_test;

  # Or on the command-line:

  # perl -MData::Dumper -MFoo::Bar -MTest::NaiveStubs -E \
  #   '$tns = Test::NaiveStubs->new(module => "Foo::Bar"); $tns->gather_subs; say Dumper $tns->subs'

  # perl -MFoo::Bar -MTest::NaiveStubs -E \
  #   '$tns = Test::NaiveStubs->new(module => "Foo::Bar"); $tns->create_test'

=head1 DESCRIPTION

C<Test::NaiveStubs> generates a test file of stubs exercising all the methods or
functions of the given B<module>.

Unfortunately L<Class::Sniff> returns any I<imported> methods as well as the ones
in the B<module> you have given.  So you will have to remove those lines from
the generated test file by hand.

For a more powerful alternative, check out L<Test::StubGenerator>.

=head1 ATTRIBUTES

=head2 module

  $module = $tns->module;

The module name to use in the test generation.  This is a required attribute.

=cut

has module => (
    is       => 'ro',
    required => 1,
);

=head2 name

  $name = $tns->name;

The test output file name.  If not given in the constructor, the filename is
created from the B<module>.  So C<Foo::Bar> would be converted to C<foo-bar.t>.

=cut

has name => (
    is      => 'ro',
    builder => 1,
);

sub _build_name {
    my ($self) = @_;
    ( my $name = $self->module ) =~ s/::/-/g;
    $name = lc $name;
    return "$name.t";
}

=head2 subs

  $subs = $tns->subs;

The subroutines in the given B<module>.  This is a computed attribute and as
such, constructor arguments will be ignored.

=cut

has subs => (
    is       => 'rw',
    init_arg => undef,
);

=head1 METHODS

=head2 new()

  $tns = Test::NaiveStubs->new(%arguments);

Create a new C<Test::NaiveStubs> object.

=head2 gather_subs()

  $tns->gather_subs;

Set the B<subs> attribute to the subroutines of the given B<module> (as well as
imported methods) as a hash reference.

=cut

sub gather_subs {
    my ($self) = @_;

    my $sniff = Class::Sniff->new({ class => $self->module });
    my @subs = $sniff->methods;
    my %subs;
    @subs{@subs} = undef;

    $self->subs( \%subs );
}

=head2 unit_test()

  $test = $tns->unit_test($method);

Return the text of a unit test as described below in B<create_test>.

=cut

sub unit_test {
    my ($self, $subroutine) = @_;

    my $test = '';

    if ( $subroutine eq 'new' ) {
        $test = 'use_ok "' . $self->module . '";'
            . "\n\n"
            . 'my $obj = ' . $self->module . '->new;'
            . "\n"
            . 'isa_ok $obj, "' . $self->module . '";';
    }
    elsif ( grep { $_ eq 'new' } keys %{ $self->subs } ) {
        $test = 'ok $obj->can("' . $subroutine . '"), "' . $subroutine . '";';
    }
    else {
        $test = "ok $subroutine(), " . '"' . $subroutine . '";';
    }

    return $test;
}

=head2 create_test()

  $tns->create_test;

Create a test file with unit tests for each method.

A C<new> method is extracted and processed first with C<use_ok>, object
instantiation, followed by C<isa_ok>.  Then each seen method is returned as
an ok can("method") assertion.  If no C<new> method is present, an C<ok> with
the subroutine is produced.

=cut

sub create_test {
    my ($self) = @_;

    open my $fh, '>', $self->name or die "Can't write " . $self->name . ": $!";

    my $text =<<'END';
use strict;
use warnings;

use Test::More;

END

    # Set the subs attribute
    $self->gather_subs;

    if ( exists $self->subs->{new} ) {
        my $test = $self->unit_test('new');
        $text .= "$test\n\n";
    }

    for my $sub ( sort keys %{ $self->subs } ) {
        next if $sub =~ /^_/;
        next if $sub eq 'new';
        my $test = $self->unit_test($sub);
        $text .= "$test\n\n";
    }

    $text .= 'done_testing();
';

    print $fh $text;
}

1;
__END__

=head1 SEE ALSO

L<Moo>

L<Class::Sniff>

=cut
