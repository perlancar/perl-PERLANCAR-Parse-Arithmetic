package PERLANCAR::Parse::Arithmetic::Marpa;

use 5.010001;
use strict;
use warnings;

use MarpaX::Simple qw(gen_parser);

use Exporter qw(import);
our @EXPORT_OK = qw(parse_arithmetic);

sub parse_arithmetic {
    state $parser = gen_parser(
        grammar => <<'_',
:default             ::= action=>::first
lexeme default         = latm=>1
:start               ::= top

top                  ::= expr
expr                 ::= mult_expr
                       | expr op_add expr                action=>add
mult_expr            ::= pow_expr
                       | mult_expr op_mult mult_expr     action=>mult
pow_expr             ::= term
# XXX right assoc doesn't seem to work?
                       | pow_expr '**' pow_expr          action=>pow assoc=>right
term                 ::= '(' expr ')'                    action=>paren
                       | literal

op_add                 ~ [+-]
op_mult                ~ [*/]
literal                ~ digits
                       | sign digits
                       | digits '.' digits
                       | sign digits '.' digits
digits                 ~ [\d]+
sign                   ~ [+-]
:discard               ~ ws
ws                     ~ [\s]+
_
        actions => {
            add => sub {
                my $h = shift;
                $_[1] eq '+' ? $_[0] + $_[2] : $_[0] - $_[2];
            },
            mult => sub {
                my $h = shift;
                $_[1] eq '*' ? $_[0] * $_[2] : $_[0] / $_[2];
            },
            pow => sub {
                my $h = shift;
                $_[0] ** $_[2];
            },
            paren => sub {
                my $h = shift;
                $_[1];
            },
        },
        trace_terminals => $ENV{DEBUG},
        trace_values => $ENV{DEBUG},
    );

    $parser->($_[0]);
}

1;
# ABSTRACT: Parse arithmetic expression (Marpa version)

=head1 SYNOPSIS

 use PERLANCAR::Parse::Arithmetic qw(parse_arithmetic);
 say parse_arithmetic('1 + 2 * 3'); # => 7


=head1 DESCRIPTION

This is a temporary module.


=head1 FUNCTIONS

=head2 parse_arithmetic
