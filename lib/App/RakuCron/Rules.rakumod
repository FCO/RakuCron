use Configuration;
use App::RakuCron::Rule;
use Lumberjack;
unit class App::RakuCron::Rules does Configuration::Node does Lumberjack::Logger;

has App::RakuCron::Rule @.rules;

method log-level is rw {
    App::RakuCron::Rule.log-level
}

method TWEAK(|) {
    self.log-debug: "New rules loaded."
}

multi method run-at(
    &proc,
    :name(:$id),

    :$on,
    :$off,

    :years( :y( :$year ) ),
    :months( :m( :$month )) is copy,
    :days( :d( :$day) ),
    :hours( :h( :$hour ) ),
    :minutes( :minute( :mins( :$min ) ) ),
    :seconds( :second( :secs( :$sec ) ) ),

    :week-days(:week-day( :weekdays( :weekday( :w-days( :w-day( :wdays( :$wday ) ) ) ) ) ) ) is copy,

    :Sundays(    :sundays(    :Sunday(    :sunday(    :Sun( :$sun ) ) ) ) ),
    :Mondays(    :mondays(    :Monday(    :monday(    :Mon( :$mon ) ) ) ) ),
    :Tuesdays(   :tuesdays(   :Tuesday(   :tuesday(   :Tue( :$tue ) ) ) ) ),
    :Wednesdays( :wednesdays( :Wednesday( :wednesday( :Wed( :$wed ) ) ) ) ),
    :Thursdays(  :thursdays(  :Thursday(  :thursday(  :Thu( :$thu ) ) ) ) ),
    :Fridays(    :fridays(    :Friday(    :friday(    :Fri( :$fri ) ) ) ) ),
    :Saturdays(  :saturdays(  :Saturday(  :saturday(  :Sat( :$sat ) ) ) ) ),

    :January(  :january(  :Jan( :$jan ) ) ),
    :February( :fabruary( :Feb( :$feb ) ) ),
    :March(    :march(    :Mar( :$mar ) ) ),
    :April(    :april(    :Apr( :$apr ) ) ),
    :May(                       :$may     ),
    :June(     :june(     :Jun( :$jun ) ) ),
    :July(     :july(     :Jul( :$jul ) ) ),
    :August(   :august(   :Aug( :$aug ) ) ),
    :September(:september(:Sep( :$sep ) ) ),
    :October(  :october(  :Oct( :$oct ) ) ),
    :November( :november( :Nov( :$nov ) ) ),
    :December( :december( :Dec( :$dec ) ) ),

    :&last-run,
    :delta-seconds(:delta-secs(   :delta( :d-seconds( :d-sec(   :$d-secs   ) ) ) ) ),
    :delta-minute( :delta-mins(           :d-minutes( :d-min(   :$d-mins   )   ) ) ),
    :delta-hour(   :delta-hours(                      :d-hour(  :$d-hours  )     ) ),
    :delta-day(    :delta-days(                       :d-day(   :$d-days   )     ) ),
    :delta-month(  :delta-monthss(                    :d-month( :$d-months )     ) ),
    :delta-year(   :delta-years(                      :d-year(  :$d-years  )     ) ),

    :$last-day-of-month,
    :business-days( :business-day( :b-days( :b-day( :bdays( :$bday ) ) ) ) ),
    :$weekend,

    :st-of-the-month( :nd-of-the-month( :rd-of-the-month( :$th-of-the-month ) ) ),
    :st-last-of-the-month( :nd-last-of-the-month( :rd-last-of-the-month( :$th-last-of-the-month ) ) ),

    :year-before(                                   :$years-before      ),
    :year-after(                                    :$years-after       ),
    :month-before(                                  :$months-before     ),
    :month-after(                                   :$months-after      ),
    :day-before(                                    :$days-before       ),
    :day-after(                                     :$days-after        ),
    :hour-before(                                   :$hours-before      ),
    :hour-after(                                    :$hours-after       ),
    :min-before(   :minute-before( :minutes-before( :$mins-before   ) ) ),
    :min-after(    :minute-after(  :minutes-after(  :$mins-after    ) ) ),
    :sec-before(   :second-before( :seconds-before( :$secs-before   ) ) ),
    :sec-after(    :second-after(  :seconds-after(  :$secs-after    ) ) ),

    :year-running(                                      :$years-running      ),
    :month-running(                                     :$months-running     ),
    :day-running(                                       :$days-running       ),
    :hour-running(                                      :$hours-running      ),
    :min-running(   :minute-running( :minutes-running(  :$mins-running   ) ) ),
    :sec-running(   :second-running(  :seconds-running( :$secs-running   ) ) ),

    :$capture,
    *%pars where { $_ == 0 || die "Params not recognized: %pars.keys()" },
) {
    my %wday-vars =
      |(:$sun with $sun),
      |(:$mon with $mon),
      |(:$tue with $tue),
      |(:$wed with $wed),
      |(:$thu with $thu),
      |(:$fri with $fri),
      |(:$sat with $sat),
    ;

    my %month-vars =
        |(:$jan with $jan),
        |(:$feb with $feb),
        |(:$mar with $mar),
        |(:$apr with $apr),
        |(:$may with $may),
        |(:$jun with $jun),
        |(:$jul with $jul),
        |(:$aug with $aug),
        |(:$sep with $sep),
        |(:$oct with $oct),
        |(:$nov with $nov),
        |(:$dec with $dec),
    ;

    die "day can't be defined along with last-day-of-month"       if $day.defined  && $last-day-of-month.defined;
    die "week-day can't be defined along with business-day"       if $wday.defined && $bday;
    die "weekend can't be defined along with business-day"        if $wday.defined && $weekend;
    die "incompatible ways of defining weekdays"                  if $wday.defined && %wday-vars;
    die "incompatible ways of defining weekdays and not weekdays" if ?%wday-vars.values.any && !%wday-vars.values.any;
    die "incompatible ways of defining months"                    if $month.defined && %month-vars;
    die "incompatible ways of defining months and not months"     if ?%month-vars.values.any && !%month-vars.values.any;

    if %wday-vars {
        $wday = <Sun Mon Tue Wed Thu Fri Sat>.grep({
            %wday-vars{.lc}:exists
            ?? %wday-vars.values.head
            !! !%wday-vars.values.head
        }).list
    }

    if %month-vars {
        $month = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>.grep({
            %month-vars{.lc}:exists
            ?? %month-vars.values.head
            !! !%month-vars.values.head
        }).list
    }

    %*DATA<rules>.push: my $rule = App::RakuCron::Rule.new:
        |(:id($_)                   with $id                   ),
        |(:on($on)                  with $on                   ),
        |(:on(!$off)                with $off                  ),
        |(:year($_)                 with $year                 ),
        |(:month($_)                with $month                ),
        |(:day($_)                  with $day                  ),
        |(:hour($_)                 with $hour                 ),
        |(:min($_)                  with $min                  ),
        |(:sec($_)                  with $sec                  ),
        |(:wday($_)                 with $wday                 ),
        |(:last-run($_)             with &last-run             ),
        |(:d-secs($_)               with $d-secs               ),
        |(:d-mins($_)               with $d-mins               ),
        |(:d-hours($_)              with $d-hours              ),
        |(:d-days($_)               with $d-days               ),
        |(:d-months($_)             with $d-months             ),
        |(:d-years($_)              with $d-years              ),
        |(:last-day-of-month($_)    with $last-day-of-month    ),
        |(:capture($_)              with $capture              ),

        |(:wday(2..6)               if   $bday                 ),
        |(:wday(1, 7)               if   $weekend              ),

        |(:th-or-rev(-$_)           with $th-of-the-month      ),
        |(:th-or-rev($_)            with $th-last-of-the-month ),

        |(:drift(%(:years($_)))     with $years-before         ),
        |(:drift(%(:years(-$_)))    with $years-after          ),
        |(:drift(%(:months($_)))    with $months-before        ),
        |(:drift(%(:months(-$_)))   with $months-after         ),
        |(:drift(%(:days($_)))      with $days-before          ),
        |(:drift(%(:days(-$_)))     with $days-after           ),
        |(:drift(%(:hours($_)))     with $hours-before         ),
        |(:drift(%(:hours(-$_)))    with $hours-after          ),
        |(:drift(%(:minutes($_)))   with $mins-before          ),
        |(:drift(%(:minutes(-$_)))  with $mins-after           ),
        |(:drift(%(:seconds($_)))   with $secs-before          ),
        |(:drift(%(:seconds(-$_)))  with $secs-after           ),

        |(:wait(%(:years($_)))     with $years-running         ),
        |(:wait(%(:months($_)))    with $months-running        ),
        |(:wait(%(:days($_)))      with $days-running          ),
        |(:wait(%(:hours($_)))     with $hours-running         ),
        |(:wait(%(:minutes($_)))   with $mins-running          ),
        |(:wait(%(:seconds($_)))   with $secs-running          ),

        :&proc
    ;
    $rule
}

multi method run-at(+@values [$, |], *%pars) {
    my @current = @values.shift<>;

    my &proc = @current.pop if @current.tail ~~ Callable;
    &proc  //= @values.pop  if @values.tail  ~~ Callable;

    for @current -> Capture \c {
        self.run-at: |%pars, |c, |@values, |($_ with &proc)
    }
}
