#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Test::NaiveStubs';

my $obj = Test::NaiveStubs->new(
    class => 'Test::NaiveStubs',
    name  => 't/test.t',
);
isa_ok $obj, 'Test::NaiveStubs';

my $subs = $obj->gather_subs();
my $expected = {
    class => undef,
    create_test => undef,
    gather_subs => undef,
    name => undef,
    new => undef,
    unit_test => undef,
};
is_deeply $subs, $expected, 'subs';

my $text = $obj->unit_test('new');
$expected = '$obj = ' . $obj->class . '->new();' . "\n" . 'isa_ok $obj, "' . $obj->class . '";';
is $text, $expected, 'unit_test';

$text = $obj->unit_test('gather_subs');
$expected = 'ok $obj->gather_subs, "gather_subs";';
is $text, $expected, 'unit_test';

$text = $obj->unit_test('class');
$expected = 'ok $obj->class, "class";';
is $text, $expected, 'unit_test';

my $file = 't/test.t';
$obj->create_test;
ok -e $file, 'create_test';

my $data = do { local $/; <DATA> };
open my $fh, '<', $file or die "Can't read $file: $!";
my $content = do { local $/; <$fh> };
is $data, $content, 'test content';

done_testing();

__DATA__
use strict;
use warnings;

use Test::More;

$obj = Test::NaiveStubs->new();
isa_ok $obj, "Test::NaiveStubs";

ok $obj->class, "class";

ok $obj->create_test, "create_test";

ok $obj->gather_subs, "gather_subs";

ok $obj->name, "name";

ok $obj->unit_test, "unit_test";

