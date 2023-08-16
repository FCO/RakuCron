[![Actions Status](https://github.com/FCO/RakuCron/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/RakuCron/actions)

NAME
====

App::RakuCron - Is a cron-like system and module configured in Raku

SYNOPSIS
========

```bash
rcron -e '.run-at: :5hours, :Mon, :Wed, :Fri, { say "running a job" }'
```

DESCRIPTION
===========

It's still on early stages of development, everything may change! App::RakuCron is a cron like system and module written and configured in Raku. It runs as the user that called it and runs in foreing ground (at least for now).

It uses the [Configuration raku module](https://github.com/FCO/Configuration) You can run it with a configuration file (by convention using the `.rakuconfig` extension, but not required) (as seen on [./examples/1.rakuconfig](./examples/1.rakuconfig)). Or as string (with `-e` flag as shown on synopsis)

It can also be used as a module:

```raku
use App::RakuCron;

run-start config {
    .run-at: :minutes(* %% 5), :business-days, { say "run on every divisible by 5 minutes on business days" }
}
```

`.run-at`
=========

`.run-at` is the most important method, it configures a new job. It can receive many different adverbs:

:$y | :$year | :$years
----------------------

Defines what year (or years) the job should run on, if nothing else is defined, it will run on the first second of that year(s). It expects an Int, a List, a Range or a Callable

:$m | :$month | :$months :January | :january | :Jan | :$jan :February | :fabruary | :Feb | :$feb :March | :march | :Mar | :$mar :April | :april | :Apr | :$apr :May | :$may :June | :june | :Jun | :$jun :July | :july | :Jul | :$jul :August | :august | :Aug | :$aug :September | :september |:Sep | :$sep :October | :october | :Oct | :$oct :November | :november | :Nov | :$nov :December | :december | :Dec | :$dec
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Defines what month (or months) the job should run on, if nothing else is defined, it will run on the first second of that month(s). It expects an Int, a List, a Range or a Callable

:$d | :$day | :$days
--------------------

Defines what day (or days) the job should run on, if nothing else is defined, it will run on the first second of that day(s). It expects an Int, a List, a Range or a Callable

:$h | :$hour | :$hours
----------------------

Defines what hour (or hours) the job should run on, if nothing else is defined, it will run on the first second of that day(s). It expects an Int, a List, a Range or a Callable

:$min | :$mins | :$minute | :$minutes
-------------------------------------

Defines what minute (or minutes) the job should run on, if nothing else is defined, it will run on the first second of that minute(s). It expects an Int, a List, a Range or a Callable

:$sec | :$secs | :$second | :$seconds
-------------------------------------

Defines what second (or seconds) the job should run on. It expects an Int, a List, a Range or a Callable

:$week-days | :$week-day | :$weekdays | :$weekday | :$w-days | :$w-day | :$wdays | :$wday :Sundays | :sundays | :Sunday | :sunday | :Sun | :sun :Mondays | :mondays | :Monday | :monday | :Mon | :mon :Tuesdays | :tuesdays | :Tuesday | :tuesday | :Tue | :tue :Wednesdays | :wednesdays | :Wednesday | :wednesday | :Wed | :wed :Thursdays | :thursdays | :Thursday | :Thursday | :Thu | :thu :Fridays | :fridays | :Friday | :friday | :Fri | :fri :Saturdays | :saturdays | :Saturday | :saturday | :Sat | :sat :business-days | :business-day | :b-days | :b-day | :bdays | :bday :weekend
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Defines what week day (or week days) the job should run on. It expects an Int, a List, a Range or a Callable

:&last-run
----------

Defines a Callable that will receives a DateTime object as the only parameter and return a Bool meaning it it should run the job or not.

:$delta-seconds | :$delta-secs | :$delta | :$d-seconds | :$d-sec | :$d-secs :$delta-minute | :$delta-mins | :$d-minutes | :$d-min | :$d-mins :$delta-hour | :$delta-hours | :$d-hour | :$$d-hours :$delta-day | :$delta-days | :$d-day | :$d-days :$delta-month | :$delta-monthss | :$d-month | :$d-months :$delta-year | :$delta-years | :$d-year | :$d-years
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Defined the minimum time a job should have ran before running it again

:$last-day-of-month,
--------------------

Runs a job at the last day of the month

:$st-of-the-month | :$nd-of-the-month | :$rd-of-the-month | :$th-of-the-month ) ) ), :$st-last-of-the-month | :$nd-last-of-the-month | :$rd-last-of-the-month( $th-last-of-the-month ) ) ),
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Defines it should on the nth first or last occurrence of that rule on the month

:year-before | :$years-before :year-after | :$years-after :month-before | :$months-before :month-after | :$months-after :day-before | :$days-before :day-after | :$days-after :hour-before | :$hours-before :hour-after | :$hours-after :min-before | :$minute-before | :$minutes-before | :$mins-before :min-after | :$minute-after | :$minutes-after | :$mins-after :sec-before | :$second-before | :$seconds-before | :$secs-before :sec-after | :$second-after | :$seconds-after | :$secs-after
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Run the job some time after or before the specified time

AUTHOR
======

Fernando Corrêa <fernando.correa@humanstate.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2023 Fernando Corrêa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

