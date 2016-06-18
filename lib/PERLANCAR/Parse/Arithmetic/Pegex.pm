package PERLANCAR::Parse::Arithmetic::Pegex;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Pegex;

use Exporter qw(import);
our @EXPORT_OK = qw(parse_arithmetic);

my $grammar = <<'...';
# Precedence Climbing grammar:
expr: add-sub
add-sub: mul-div+ % /- ( [ '+-' ])/
mul-div: power+ % /- ([ '*/' ])/
power: token+ % /- '**' /
token: /- '(' -/ expr /- ')'/ | number
number: /- ( '-'? DIGIT+ '.'? DIGIT* )/
...

{
    package
        Calculator;
    use base 'Pegex::Tree';

    sub gotrule {
        my ($self, $list) = @_;
        return $list unless ref $list;

        # Right associative:
        if ($self->rule eq 'power') {
            while (@$list > 1) {
                my ($a, $b) = splice(@$list, -2, 2);
                push @$list, $a ** $b;
            }
        }
        # Left associative:
        else {
            while (@$list > 1) {
                my ($a, $op, $b) = splice(@$list, 0, 3);
                unshift @$list,
                    ($op eq '+') ? ($a + $b) :
                    ($op eq '-') ? ($a - $b) :
                    ($op eq '*') ? ($a * $b) :
                    ($op eq '/') ? ($a / $b) :
                    die;
            }
        }
        return @$list;
    }
}

sub parse_arithmetic {
    pegex($grammar, 'Calculator')->parse($_[0]);
}

1;
# ABSTRACT: Parse arithmetic expression (Pegex version)

=head1 SYNOPSIS

 use PERLANCAR::Parse::Pegex qw(parse_arithmetic);
 say parse_arithmetic('1 + 2 * 3'); # => 7


=head1 DESCRIPTION

This is a temporary module.


=head1 FUNCTIONS

=head2 parse_arithmetic
