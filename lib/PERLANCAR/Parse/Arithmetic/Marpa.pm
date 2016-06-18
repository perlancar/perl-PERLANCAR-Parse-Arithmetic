package PERLANCAR::Parse::Arithmetic::Marpa;

# DATE
# VERSION

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
:start               ::= expr

expr                 ::= literal
                       | '(' expr ')'                    action=>paren assoc=>group
                      || expr '**' expr                  action=>pow   assoc=>right
                      || expr '*' expr                   action=>mult
                       | expr '/' expr                   action=>div
                      || expr '+' expr                   action=>add
                       | expr '-' expr                   action=>subtract

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
                $_[0] + $_[2];
            },
            subtract => sub {
                my $h = shift;
                $_[0] - $_[2];
            },
            mult => sub {
                my $h = shift;
                $_[0] * $_[2];
            },
            div => sub {
                my $h = shift;
                $_[0] / $_[2];
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
        trace_values    => $ENV{DEBUG},
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
