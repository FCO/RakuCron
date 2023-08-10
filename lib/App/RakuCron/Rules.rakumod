use Configuration;
use App::RakuCron::Rule;
unit class App::RakuCron::Rules does Configuration::Node;

has App::RakuCron::Rule @.rules;

method run-at(
    &proc,
    :years( :y( :$year ) ),
    :months( :m( :$month )),
    :days( :d( :$day) ),
    :hours( :h( :$hour ) ),
    :minutes( :minute( :mins( :$min ) ) ),
    :seconds( :second( :secs( :$sec ) ) ),

    :week-day( :w-day( :$wday ) ),
) {
    %*DATA<rules>.push: App::RakuCron::Rule.new:
        |(:year($_)  with $year ),
        |(:month($_) with $month),
        |(:day($_)   with $day  ),
        |(:hour($_)  with $hour ),
        |(:min($_)   with $min  ),
        |(:sec($_)   with $sec  ),
        |(:wday($_)  with $wday ),
        :&proc
    ;
}

method jobs-should-run-at(DateTime $time) {
    @!rules.grep({ $time ~~ $_ }).map: *.proc
}
