use Lumberjack;
unit class App::RakuCron::Rule does Iterable does Lumberjack::Logger;

my $range-year = DateTime.now.year..Inf;
my $range-month = 1 .. 12;
my $range-day   = 1 .. 31;
my $range-hour  = ^24;
my $range-min   = ^60;
my $range-sec   = ^60;

has $.id = ++$;
has Capture $.rule-params;

has $!last-run-datetime;

has @.year  = $range-year.min;
has @.month = $range-month.min;
has @.day   = $range-day.min;
has @.hour  = $range-hour.min;
has @.min   = $range-min.min;
has @.sec   = $range-sec.min;

has @.wday;
has &.last-run;
has $.d-secs;
has $.d-mins;
has $.d-hours;
has $.d-days;

has $.capture = \();
has &.proc;
has @!data-to-proc = &!proc.signature.params.grep(*.named).map: *.name.substr: 1;

method log-trace(*@msg) is hidden-from-backtrace {self.Lumberjack::Logger::log-trace: ["[$!id]", |@msg].join: " "}
method log-debug(*@msg) is hidden-from-backtrace {self.Lumberjack::Logger::log-debug: ["[$!id]", |@msg].join: " "}
method log-info(*@msg)  is hidden-from-backtrace {self.Lumberjack::Logger::log-info:  ["[$!id]", |@msg].join: " "}
method log-warn(*@msg)  is hidden-from-backtrace {self.Lumberjack::Logger::log-warn:  ["[$!id]", |@msg].join: " "}
method log-error(*@msg) is hidden-from-backtrace {self.Lumberjack::Logger::log-error: ["[$!id]", |@msg].join: " "}
method log-fatal(*@msg) is hidden-from-backtrace {self.Lumberjack::Logger::log-fatal: ["[$!id]", |@msg].join: " "}

method run(DateTime $time) {
    my %data = self!data-with-time($time){@!data-to-proc}:p;
    my Capture $args = \(|%data, |$!capture);
    CATCH {
       default {
           self.log-fatal: "Error while running process { &!proc.raku } with arguments { $args.raku }: ", $_
       }
    }
    LEAVE $!last-run-datetime = $time;
    my &proc = &!proc;
    self.log-trace: "running process { &!proc.raku } passing argumentss { $args.raku }";
    proc |$args
}

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
    die "Could not recognize { %pars.keys.head }: { %pars.values.head }";
}

method !data-with-time(DateTime $time --> Map()) {
    quietly
    :$time,
    rule         => self,
    last-run     => $!last-run-datetime // DateTime,
    year         => $time.year,
    month        => $time.month,
    day          => $time.day,
    hour         => $time.hour,
    min          => $time.minute,
    sec          => $time.second,
    |(
        |(
            delta-secs   => my Int() $dsecs  = $time - $!last-run-datetime,
            delta-mins   => my Int() $dmins  = $dsecs  div 60,
            delta-hours  => my Int() $dhours = $dmins  div 60,
            delta-days   => my Int() $ddays  = $dhours div 24,
        ) with $!last-run-datetime
    )
}

submethod TWEAK(|c (*%pars)) {
    fail "No time rule defined" unless %pars;

    $!rule-params = c;
    self.log-debug: "new rule instanciated:", $!rule-params.raku;

    my $now = DateTime.now;

    enum Units <sec min hour day month year>;
    my $first = [sec, min, hour, day, month, year].first: { %pars{.key}:exists }
    enum DeltaUnits <d-secs d-mins d-hours d-days>;
    $first //= [d-secs, d-mins, d-hours, d-days].first({ %pars{.key}:exists }) - 1;
    $first //= -1;

    my &rM = *.list.rotate: $now.month - 1;
    my &rd = *.list.rotate: $now.day   - 1;
    my &rh = *.list.rotate: $now.hour;
    my &rm = *.list.rotate: $now.minute;
    my &rs = *.list;

    CATCH {
        default {
            self.log-fatal: $_
        }
    }

    @!year  = %pars<year >:exists ?? transform-par(year  => %pars<year >) !! $first < year  ?? $range-year.list !! $range-year .min;
    @!month = %pars<month>:exists ?? transform-par(month => %pars<month>) !! $first < month ?? $range-month.&rM !! $range-month.min;
    @!day   = %pars<day  >:exists ?? transform-par(day   => %pars<day  >) !! $first < day   ?? $range-day.&rd   !! $range-day  .min;
    @!hour  = %pars<hour >:exists ?? transform-par(hour  => %pars<hour >) !! $first < hour  ?? $range-hour.&rh  !! $range-hour .min;
    @!min   = %pars<min  >:exists ?? transform-par(min   => %pars<min  >) !! $first < min   ?? $range-min.&rm   !! $range-min  .min;
    @!sec   = %pars<sec  >:exists ?? transform-par(sec   => %pars<sec  >) !! $first < sec   ?? $range-sec.&rs   !! $range-sec  .min;

    @!wday  = %pars<wday >:exists ?? transform-par(wday  => %pars<wday>) !! (1 .. 7).list;
}

multi method ACCEPTS(DateTime $time --> Bool:D) {
    my $wday = $time.day-of-week || 7;

    my Bool:D %b;
    %b<sec  > = @!sec  .first( $time.whole-second ).defined;
    %b<min  > = @!min  .first( $time.minute       ).defined;
    %b<hour > = @!hour .first( $time.hour         ).defined;
    %b<day  > = @!day  .first( $time.day          ).defined;
    %b<month> = @!month.first( $time.month        ).defined;
    %b<year > = @!year .first( $time.year         ).defined;
    %b<wday > = @!wday .first( $wday              ).defined;

    [&&] %b.values;
}

method delta-validations(DateTime $time --> Bool:D) {
    my Bool:D %b;
    %b<none>     = True;
    with $!last-run-datetime {
        %b<last-run> = &!last-run.($!last-run-datetime)                            with &!last-run;
        %b<d-secs>   = (my $secs = ($time - $!last-run-datetime).Int) >= $!d-secs  with $!d-secs  ;
        %b<d-mins>   = (my $mins = $secs div 60)                      >= $!d-mins  with $!d-mins  ;
        %b<d-hours>  = (my $hour = $mins div 60)                      >= $!d-hours with $!d-hours ;
        %b<d-days>   = (my $days = $hour div 24)                      >= $!d-days  with $!d-days  ;
    }

    self.log-trace: %b.raku;

    [&&] %b.values;
}

method Seq {
    sub create-datetime(
        UInt $year,
        UInt $month,
        UInt $day,
        UInt $hour,
        UInt $minute,
        UInt $second,
    ) is assoc<list> {
        DateTime.new:
          :timezone($*TZ),
          :$year, :$month,  :$day,
          :$hour, :$minute, :$second,
    }

    my $now = DateTime.now;
    ([X] @!year, @!month, @!day, @!hour, @!min, @!sec)
      .map({ try { create-datetime |$_ } // Empty })
      .toggle(:off, * >= $now)
      .toggle(:off, * >= DateTime.now)
      .grep(self)
}

method iterator { self.Seq.iterator }
