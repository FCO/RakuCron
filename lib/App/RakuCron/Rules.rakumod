use Configuration;
use App::RakuCron::Rule;
use MergeOrderedSeqs;
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
    :&last-run,
    :delta-seconds(:delta-secs( :delta( :d-seconds( :$d-secs ) ) ) ),
    :$capture,
    *%pars where { $_ == 0 || die "Params not recognized: %pars.keys()" },
) {
    %*DATA<rules>.push: App::RakuCron::Rule.new:
        |(:year($_)     with $year    ),
        |(:month($_)    with $month   ),
        |(:day($_)      with $day     ),
        |(:hour($_)     with $hour    ),
        |(:min($_)      with $min     ),
        |(:sec($_)      with $sec     ),
        |(:wday($_)     with $wday    ),
        |(:last-run($_) with &last-run),
        |(:d-secs($_)   with $d-secs  ),
        |(:capture($_)  with $capture ),
        :&proc
    ;
}

method jobs-should-run-at(DateTime $time) {
    @!rules.grep: { $time ~~ $_ }
}

method next-datetimes {
    merge-ordered-seqs(@!rules).squish
}
