package PERLANCAR::Parse::Arithmetic::NoHash;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

my ($match_top,
    $match_add, $match_op_add,
    $match_mult, $match_op_mult,
    $match_pow,
);

use Exporter qw(import);
our @EXPORT_OK = qw(parse_arithmetic);

sub parse_arithmetic {
    state $RE =
        qr{
              (?&TOP)
              (?{
                  $match_top = $^R;
              })

              (?(DEFINE)

                  (?<TOP>
                      ^\s* (?&EXPR) \s*$
                  )

                  (?<EXPR>
                      (?&MULT_EXPR)
                      (?{
                          $match_add = $^R
                      })
                      (?: \s* ([+-])
                          (?{
                              $match_op_add = $^N;
                          })
                          \s* (?&MULT_EXPR)
                          (?{
                              $match_add = $match_op_add eq '+' ? $match_add + $^R : $match_add - $^R;
                          })
                          )*
                  )

                  (?<MULT_EXPR>
                      (?&POW_EXPR)
                      (?{
                          $match_mult = $^R;
                      })
                      (?: \s* ([*/])
                          (?{
                              $match_op_mult = $^N;
                          }) \s*
                          (?&POW_EXPR)
                          (?{
                              $match_mult = $match_op_mult eq '*' ? $match_mult * $^R : $match_mult / $^R;
                          })
                          )*
                  )

                  (?<POW_EXPR>
                      (?&TERM)
                      (?{
                          $match_pow = [$^R];
                      })
                      (?: \s* \*\* \s* (?&TERM)
                          (?{
                              unshift @$match_pow, $^R;
                          })
                      )*
                      (?{
                          # because ** is right-to-left, we collect first then
                          # apply from right to left
                          my $res = $match_pow->[0];
                          for (1..$#{$match_pow}) {
                              $res = $match_pow->[$_] ** $res;
                          }
                          $res;
                      })
                  )

                  (?<TERM>
                      \( \s* (?&EXPR)
                      (?{
                          $^R;
                      })
                      \s* \)
                  |   (?&LITERAL)
                      (?{
                          $^R;
                      })
                  )

                  (?<LITERAL>
                      (-?(?:\d+|\d*\.\d+))
                      (?{
                          $^N;
                      })
                  )
              )
      }x;
    $_[0] =~ $RE or return undef;
    $match_top;
}

1;
# ABSTRACT: Parse arithmetic expmatchsion

=head1 SYNOPSIS

 use PERLANCAR::Parse::Arithmetic::NoHash qw(parse_arithmetic);
 say parse_arithmetic('1 + 2 * 3'); # => 7


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 parse_arithmetic
