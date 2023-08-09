unit class App::RakuCron::Rule;

my $range-year = 2000..Inf;
my $range-month = 1 .. 12;
my $range-day   = 1 .. 31;
my $range-hour  = ^24;
my $range-min   = ^60;
my $range-sec   = ^60;

has @.year  = $range-year.min;
has @.month = $range-month.min;
has @.day   = $range-day.min;
has @.hour  = $range-hour.min;
has @.min   = $range-min.min;
has @.sec   = $range-sec.min;

has @.wday;

has &.proc;

my %months =
    Jan       => 1,  January   => 1,
    Feb       => 2,  February  => 2,
    Mar       => 3,  March     => 3,
    Apr       => 4,  April     => 4,
    May       => 5,
    Jun       => 6,  June      => 6,
    Jul       => 7,  July      => 7,
    Aug       => 8,  August    => 8,
    Sep       => 9,  September => 9,
    Oct       => 10, October   => 10,
    Nov       => 11, November  => 11,
    Dec       => 12, December  => 12,
;
my %wdays =
    Sun => 1, Sunday    => 1,
    Mon => 2, Monday    => 2,
    Tue => 3, Tuesday   => 3,
    Wed => 4, Wednesday => 4,
    Thu => 5, Thursday  => 5,
    Fri => 6, Friday    => 6,
    Sat => 7, Saturday  => 7,
;

multi transform-par(UInt :$year!  where $range-year)            { 2000                           }
multi transform-par(UInt :$year!  where ^100)                   { 2000 + $year                   }
multi transform-par(:&year!)                                    { $range-year.grep(&year).list   }
multi transform-par(Whatever :$year!)                           { $range-year.list               }
multi transform-par(UInt :$month! where $range-month)           { $month                         }
multi transform-par(Str  :$month! where { %months{$_}:exists }) { %months{ $month }              }
multi transform-par(:&month!)                                   { $range-month.grep(&month).list }
multi transform-par(Whatever :$month!)                          { $range-month.list              }
multi transform-par(UInt :$day!   where $range-day)             { $day                           }
multi transform-par(:&day!)                                     { $range-day.grep(&day).list     }
multi transform-par(Whatever :$day!)                            { $range-day.list                }
multi transform-par(UInt :$hour!  where $range-hour)            { $hour                          }
multi transform-par(:&hour!)                                    { $range-hour.grep(&hour).list   }
multi transform-par(Whatever :$hour!)                           { $range-hour.list               }
multi transform-par(UInt :$min!   where $range-min)             { $min                           }
multi transform-par(:&min!)                                     { $range-min.grep(&min).list     }
multi transform-par(Whatever :$min!)                            { $range-min.list                }
multi transform-par(UInt :$sec!   where $range-sec)             { $sec                           }
multi transform-par(:&sec!)                                     { $range-sec.grep(&sec).list     }
multi transform-par(Whatever :$sec!)                            { $range-sec.list                }
multi transform-par(UInt :$wday!  where 1 .. 7)                 { $wday                          }
multi transform-par(:&wday!)                                    { (1 .. 7).grep(&wday).list      }
multi transform-par(Whatever :$wday!)                           { (1 .. 7).list                  }
multi transform-par(Str  :$wday!  where { %wdays{$_}:exists })  { %wdays{ $wday }                }

multi transform-par(*%pars where { .values.head ~~ Positional }) {
    %pars.values.head.map: { transform-par |%( %pars.keys.head => $_ ) }
}
multi transform-par(*%pars where { .values.head !~~ Positional }) {
    die "Could not recognize { %pars.keys.head }: { %pars.values.head }"
}

submethod TWEAK(*%pars) {
    fail "No time rule defined" unless %pars;

    enum Units <sec min hour day month year>;
    my $first = [sec, min, hour, day, month, year].first: { %pars{.key}:exists }

    @!year  = %pars<year >:exists ?? transform-par(year  => %pars<year >) !! $first < year  ?? $range-year .list !! $range-year .min;
    @!month = %pars<month>:exists ?? transform-par(month => %pars<month>) !! $first < month ?? $range-month.list !! $range-month.min;
    @!day   = %pars<day  >:exists ?? transform-par(day   => %pars<day  >) !! $first < day   ?? $range-day  .list !! $range-day  .min;
    @!hour  = %pars<hour >:exists ?? transform-par(hour  => %pars<hour >) !! $first < hour  ?? $range-hour .list !! $range-hour .min;
    @!min   = %pars<min  >:exists ?? transform-par(min   => %pars<min  >) !! $first < min   ?? $range-min  .list !! $range-min  .min;
    @!sec   = %pars<sec  >:exists ?? transform-par(sec   => %pars<sec  >) !! $first < sec   ?? $range-sec  .list !! $range-sec  .min;

    @!wday  = %pars<wday >:exists ?? transform-par(wday  => %pars<wday>) !! (1 .. 7).list;
}
