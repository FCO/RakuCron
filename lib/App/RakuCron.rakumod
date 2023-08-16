use Configuration;

use App::RakuCron::Rules;

sub EXPORT {
    generate-exports App::RakuCron::Rules;
}


sub run-start(App::RakuCron::Rules $rules, Promise $prom = Promise.kept) is export {
    without $*running {
        PROCESS::<$running> = False;
    }
    start {
        await $prom;
        $*running = True;
        DATE: for $rules.next-datetimes -> DateTime $time {
            await Promise.at: $time.Instant;
            for $rules.jobs-should-run-at: $time {
                last DATE unless $*running;
                next unless .delta-validations: $time;
                .run($time)
            }
        }
    }
}

=begin pod

=head1 NAME

App::RakuCron - Is a cron-like system and module configured in Raku

=head1 SYNOPSIS

=begin code :lang<bash>

rcron -e '.run-at: :5hours, :Mon, :Wed, :Fri, { say "running a job" }'

=end code

=head1 DESCRIPTION

It's still on early stages of development, everything may change!
App::RakuCron is a cron like system and module written and configured in Raku.
It runs as the user that called it and runs in foreing ground (at least for now).

It uses the L<Configuration raku module|https://github.com/FCO/Configuration>
You can run it with a configuration file (by convention using the C<.rakuconfig> extension, but not required) (as seen on L<./examples/1.rakuconfig>).
Or as string (with C<-e> flag as shown on synopsis)

It can also be used as a module:

=begin code :lang<raku>

use App::RakuCron;

run-start config {
    .run-at: :minutes(* %% 5), :business-days, { say "run on every divisible by 5 minutes on business days" }
}

=end code

=head1 C<.run-at>

C<.run-at> is the most important method, it configures a new job. It can receive many different adverbs:

=head2 :$y | :$year | :$years

Defines what year (or years) the job should run on, if nothing else is defined, it will run on the first second of that year(s).
It expects an Int, a List, a Range or a Callable

=head2 :$m | :$month | :$months
=head2 :January | :january | :Jan | :$jan
=head2 :February | :fabruary | :Feb | :$feb
=head2 :March | :march | :Mar | :$mar
=head2 :April | :april | :Apr | :$apr
=head2 :May | :$may
=head2 :June | :june | :Jun | :$jun
=head2 :July | :july | :Jul | :$jul
=head2 :August | :august | :Aug | :$aug
=head2 :September | :september |:Sep | :$sep
=head2 :October | :october | :Oct | :$oct
=head2 :November | :november | :Nov | :$nov
=head2 :December | :december | :Dec | :$dec

Defines what month (or months) the job should run on, if nothing else is defined, it will run on the first second of that month(s).
It expects an Int, a List, a Range or a Callable

=head2 :$d | :$day | :$days

Defines what day (or days) the job should run on, if nothing else is defined, it will run on the first second of that day(s).
It expects an Int, a List, a Range or a Callable

=head2 :$h | :$hour | :$hours

Defines what hour (or hours) the job should run on, if nothing else is defined, it will run on the first second of that day(s).
It expects an Int, a List, a Range or a Callable

=head2 :$min | :$mins | :$minute | :$minutes

Defines what minute (or minutes) the job should run on, if nothing else is defined, it will run on the first second of that minute(s).
It expects an Int, a List, a Range or a Callable

=head2 :$sec | :$secs | :$second | :$seconds

Defines what second (or seconds) the job should run on.
It expects an Int, a List, a Range or a Callable

=head2 :$week-days | :$week-day | :$weekdays | :$weekday | :$w-days | :$w-day | :$wdays | :$wday
=head2 :Sundays | :sundays | :Sunday | :sunday | :Sun | :sun
=head2 :Mondays | :mondays | :Monday | :monday | :Mon | :mon
=head2 :Tuesdays | :tuesdays | :Tuesday | :tuesday | :Tue | :tue
=head2 :Wednesdays | :wednesdays | :Wednesday | :wednesday | :Wed | :wed
=head2 :Thursdays | :thursdays | :Thursday | :Thursday | :Thu | :thu
=head2 :Fridays | :fridays | :Friday | :friday | :Fri | :fri
=head2 :Saturdays | :saturdays | :Saturday | :saturday | :Sat | :sat
=head2 :business-days | :business-day | :b-days | :b-day | :bdays | :bday
=head2 :weekend

Defines what week day (or week days) the job should run on.
It expects an Int, a List, a Range or a Callable

=head2 :&last-run

Defines a Callable that will receives a DateTime object as the only parameter and return a Bool meaning it it should run the job or not.

=head2 :$delta-seconds | :$delta-secs | :$delta | :$d-seconds | :$d-sec | :$d-secs
=head2 :$delta-minute | :$delta-mins | :$d-minutes | :$d-min | :$d-mins
=head2 :$delta-hour | :$delta-hours | :$d-hour | :$$d-hours
=head2 :$delta-day | :$delta-days | :$d-day | :$d-days
=head2 :$delta-month | :$delta-monthss | :$d-month | :$d-months
=head2 :$delta-year | :$delta-years | :$d-year | :$d-years

Defined the minimum time a job should have ran before running it again

=head2 :$last-day-of-month,

Runs a job at the last day of the month

=head2 :$st-of-the-month | :$nd-of-the-month | :$rd-of-the-month | :$th-of-the-month ) ) ),
=head2 :$st-last-of-the-month | :$nd-last-of-the-month | :$rd-last-of-the-month( $th-last-of-the-month ) ) ),

Defines it should on the nth first or last occurrence of that rule on the month

=head2 :year-before | :$years-before
=head2 :year-after | :$years-after
=head2 :month-before | :$months-before
=head2 :month-after | :$months-after
=head2 :day-before | :$days-before
=head2 :day-after | :$days-after
=head2 :hour-before | :$hours-before
=head2 :hour-after | :$hours-after
=head2 :min-before | :$minute-before | :$minutes-before | :$mins-before
=head2 :min-after | :$minute-after | :$minutes-after | :$mins-after
=head2 :sec-before | :$second-before | :$seconds-before | :$secs-before
=head2 :sec-after | :$second-after | :$seconds-after | :$secs-after

Run the job some time after or before the specified time

=head1 AUTHOR

Fernando Corrêa <fernando.correa@humanstate.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Fernando Corrêa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
