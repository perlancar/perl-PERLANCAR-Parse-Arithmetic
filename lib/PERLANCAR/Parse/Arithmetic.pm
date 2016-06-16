package PERLANCAR::Parse::Arithmetic;

use 5.010001;
use strict;
use warnings;

my ($opr, %res);

use Exporter qw(import);
our @EXPORT_OK = qw(parse_arithmetic);

sub parse_arithmetic {
    state $RE =
        qr{
              (?&TOP)
              (?{
                  $res{top} = $^R;
              })

              (?(DEFINE)

                  (?<TOP>
                      ^\s* (?&EXPR) \s*$
                  )

                  (?<EXPR>
                      (?&MULT_EXPR)
                      (?{
                          $res{add} = $^R
                      })
                      (?: \s* ([+-])
                          (?{
                              $opr = $^N;
                          })
                          \s* (?&MULT_EXPR)
                          (?{
                              $res{add} = $opr eq '+' ? $res{add} + $^R : $res{add} - $^R;
                          })
                          )*
                  )

                  (?<MULT_EXPR>
                      (?&POW_EXPR)
                      (?{
                          $res{mult} = $^R;
                      })
                      (?: \s* ([*/])
                          (?{
                              $opr = $^N;
                          }) \s*
                          (?&POW_EXPR)
                          (?{
                              $res{mult} = $opr eq '*' ? $res{mult} * $^R : $res{mult} / $^R;
                          })
                          )*
                  )

                  (?<POW_EXPR>
                      (?&TERM)
                      (?{
                          $res{pow} = [$^R];
                      })
                      (?: \s* \*\* \s* (?&TERM)
                          (?{
                              unshift @{$res{pow}}, $^R;
                          })
                      )*
                      (?{
                          # because ** is right-to-left, we collect first then
                          # apply from right to left
                          my $res = $res{pow}[0];
                          for (1..$#{$res{pow}}) {
                              $res = $res{pow}[$_] ** $res;
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
    %res = ();
    $_[0] =~ $RE or return undef;
    $res{top};
}

1;
# ABSTRACT: Parse arithmetic expression

=head1 DESCRIPTION

 use PERLANCAR::Parse::Arithmetic qw(parse_arithmetic);
 say parse_arithmetic('1 + 2 * 3'); # => 7


=head1 DESCRIPTION

This is a temporary module.


=head1 FUNCTIONS

=head2 parse_arithmetic
