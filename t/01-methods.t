#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Test::NaiveStubs';

my $obj = Test::NaiveStubs->new( module => 'Test::NaiveStubs' );
isa_ok $obj, 'Test::NaiveStubs';

is $obj->name, 'test-naivestubs.t', 'name';

my $methods = $obj->gather_methods();
my $expected = {
    _build_name => undef,
    module => undef,
    create_test => undef,
    gather_methods => undef,
    name => undef,
    new => undef,
    unit_test => undef,
};
is_deeply $methods, $expected, 'gather_methods';

my $text = $obj->unit_test('new');
$expected = 'use_ok "Test::NaiveStubs";'
    . "\n\n"
    . 'my $obj = ' . $obj->module . '->new;'
    . "\n"
    . 'isa_ok $obj, "' . $obj->module . '";';
is $text, $expected, 'unit_test';

$text = $obj->unit_test('gather_methods');
$expected = 'ok $obj->can("gather_methods"), "gather_methods";';
is $text, $expected, 'unit_test';

$text = $obj->unit_test('module');
$expected = 'ok $obj->can("module"), "module";';
is $text, $expected, 'unit_test';

unlink $obj->name;

$obj->create_test;
ok -e $obj->name, 'create_test';

my $data = do { local $/; <DATA> };
open my $fh, '<', $obj->name or die "Can't read " . $obj->name . ": $!";
my $content = do { local $/; <$fh> };
is $data, $content, 'test content';

unlink $obj->name;

done_testing();

__DATA__
use strict;
use warnings;

use Test::More;

use_ok "Test::NaiveStubs";

my $obj = Test::NaiveStubs->new;
isa_ok $obj, "Test::NaiveStubs";

ok $obj->can("create_test"), "create_test";

ok $obj->can("gather_methods"), "gather_methods";

ok $obj->can("module"), "module";

ok $obj->can("name"), "name";

ok $obj->can("unit_test"), "unit_test";

done_testing();
