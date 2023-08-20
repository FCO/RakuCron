use Configuration;
use App::RakuCron::Rules;
use App::RakuCron::RuleManager;

sub EXPORT {
    generate-exports App::RakuCron::Rules;
}

sub rcron-manager(App::RakuCron::Rules $rules?) is export {
    my App::RakuCron::RuleManager $manager .= new;
    $manager.add-rules: $_ with $rules;
    $manager.start
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

await rcron-manager config {
    .run-at: :minutes(* %% 5), :business-days, { say "run on every divisible by 5 minutes on business days" }
}

=end code

=head1 C<.run-at>

C<.run-at> is the most important method, it configures a new job. It can receive many different adverbs:

=head3 :$y | :$year | :$years

Defines what year (or years) the job should run on, if nothing else is defined, it will run on the first second of that year(s).
It expects an Int, a List, a Range or a Callable

=head3 :$m | :$month | :$months
=head3 :January | :january | :Jan | :$jan
=head3 :February | :fabruary | :Feb | :$feb
=head3 :March | :march | :Mar | :$mar
=head3 :April | :april | :Apr | :$apr
=head3 :May | :$may
=head3 :June | :june | :Jun | :$jun
=head3 :July | :july | :Jul | :$jul
=head3 :August | :august | :Aug | :$aug
=head3 :September | :september |:Sep | :$sep
=head3 :October | :october | :Oct | :$oct
=head3 :November | :november | :Nov | :$nov
=head3 :December | :december | :Dec | :$dec

Defines what month (or months) the job should run on, if nothing else is defined, it will run on the first second of that month(s).
It expects an Int, a List, a Range or a Callable

=head3 :$d | :$day | :$days

Defines what day (or days) the job should run on, if nothing else is defined, it will run on the first second of that day(s).
It expects an Int, a List, a Range or a Callable

=head3 :$h | :$hour | :$hours

Defines what hour (or hours) the job should run on, if nothing else is defined, it will run on the first second of that day(s).
It expects an Int, a List, a Range or a Callable

=head3 :$min | :$mins | :$minute | :$minutes

Defines what minute (or minutes) the job should run on, if nothing else is defined, it will run on the first second of that minute(s).
It expects an Int, a List, a Range or a Callable

=head3 :$sec | :$secs | :$second | :$seconds

Defines what second (or seconds) the job should run on.
It expects an Int, a List, a Range or a Callable

=head3 :$week-days | :$week-day | :$weekdays | :$weekday | :$w-days | :$w-day | :$wdays | :$wday
=head3 :Sundays | :sundays | :Sunday | :sunday | :Sun | :sun
=head3 :Mondays | :mondays | :Monday | :monday | :Mon | :mon
=head3 :Tuesdays | :tuesdays | :Tuesday | :tuesday | :Tue | :tue
=head3 :Wednesdays | :wednesdays | :Wednesday | :wednesday | :Wed | :wed
=head3 :Thursdays | :thursdays | :Thursday | :Thursday | :Thu | :thu
=head3 :Fridays | :fridays | :Friday | :friday | :Fri | :fri
=head3 :Saturdays | :saturdays | :Saturday | :saturday | :Sat | :sat
=head3 :business-days | :business-day | :b-days | :b-day | :bdays | :bday
=head3 :weekend

Defines what week day (or week days) the job should run on.
It expects an Int, a List, a Range or a Callable

=head3 :&last-run

Defines a Callable that will receives a DateTime object as the only parameter and return a Bool meaning it it should run the job or not.

=head2 :$delta-seconds | :$delta-secs | :$delta | :$d-seconds | :$d-sec | :$d-secs
=head2 :$delta-minute | :$delta-mins | :$d-minutes | :$d-min | :$d-mins
=head2 :$delta-hour | :$delta-hours | :$d-hour | :$$d-hours
=head2 :$delta-day | :$delta-days | :$d-day | :$d-days
=head2 :$delta-month | :$delta-monthss | :$d-month | :$d-months
=head2 :$delta-year | :$delta-years | :$d-year | :$d-years

Defined the minimum time a job should have ran before running it again

=head3 :$last-day-of-month,

Runs a job at the last day of the month

=head3 :$st-of-the-month | :$nd-of-the-month | :$rd-of-the-month | :$th-of-the-month ) ) ),
=head3 :$st-last-of-the-month | :$nd-last-of-the-month | :$rd-last-of-the-month( $th-last-of-the-month ) ) ),

Defines it should on the nth first or last occurrence of that rule on the month

=head3 :year-before | :$years-before
=head3 :year-after | :$years-after
=head3 :month-before | :$months-before
=head3 :month-after | :$months-after
=head3 :day-before | :$days-before
=head3 :day-after | :$days-after
=head3 :hour-before | :$hours-before
=head3 :hour-after | :$hours-after
=head3 :min-before | :$minute-before | :$minutes-before | :$mins-before
=head3 :min-after | :$minute-after | :$minutes-after | :$mins-after
=head3 :sec-before | :$second-before | :$seconds-before | :$secs-before
=head3 :sec-after | :$second-after | :$seconds-after | :$secs-after

Run the job some time after or before the specified time

=head1 AUTHOR

Fernando Corrêa <fernando.correa@humanstate.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Fernando Corrêa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
