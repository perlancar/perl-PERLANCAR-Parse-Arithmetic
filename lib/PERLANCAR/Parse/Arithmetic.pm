package PERLANCAR::Parse::Arithmetic;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

my %match;

use Exporter qw(import);
our @EXPORT_OK = qw(parse_arithmetic);

sub parse_arithmetic {
    state $RE =
        qr{
              (?&TOP)
              (?{
                  $match{top} = $^R;
              })

              (?(DEFINE)

                  (?<TOP>
                      ^\s* (?&EXPR) \s*$
                  )

                  (?<EXPR>
                      (?&MULT_EXPR)
                      (?{
                          $match{add} = $^R
                      })
                      (?: \s* ([+-])
                          (?{
                              $match{op_add} = $^N;
                          })
                          \s* (?&MULT_EXPR)
                          (?{
                              $match{add} = $match{op_add} eq '+' ? $match{add} + $^R : $match{add} - $^R;
                          })
                          )*
                  )

                  (?<MULT_EXPR>
                      (?&POW_EXPR)
                      (?{
                          $match{mult} = $^R;
                      })
                      (?: \s* ([*/])
                          (?{
                              $match{op_mult} = $^N;
                          }) \s*
                          (?&POW_EXPR)
                          (?{
                              $match{mult} = $match{op_mult} eq '*' ? $match{mult} * $^R : $match{mult} / $^R;
                          })
                          )*
                  )

                  (?<POW_EXPR>
                      (?&TERM)
                      (?{
                          $match{pow} = [$^R];
                      })
                      (?: \s* \*\* \s* (?&TERM)
                          (?{
                              unshift @{$match{pow}}, $^R;
                          })
                      )*
                      (?{
                          # because ** is right-to-left, we collect first then
                          # apply from right to left
                          my $res = $match{pow}[0];
                          for (1..$#{$match{pow}}) {
                              $res = $match{pow}[$_] ** $res;
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
    $match{top};
}

1;
# ABSTRACT: Parse arithmetic expmatchsion

=head1 SYNOPSIS

 use PERLANCAR::Parse::Arithmetic qw(parse_arithmetic);
 say parse_arithmetic('1 + 2 * 3'); # => 7


=head1 DESCRIPTION

This is a temporary module.


=head1 FUNCTIONS

=head2 parse_arithmetic
