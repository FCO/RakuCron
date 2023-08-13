use Configuration;
use App::RakuCron::Rule;
use MergeOrderedSeqs;
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
    :years( :y( :$year ) ),
    :months( :m( :$month )),
    :days( :d( :$day) ),
    :hours( :h( :$hour ) ),
    :minutes( :minute( :mins( :$min ) ) ),
    :seconds( :second( :secs( :$sec ) ) ),

    :week-day( :w-day( :$wday ) ),
    :&last-run,
    :delta-seconds(:delta-secs(   :delta( :d-seconds( :$d-secs  ) ) ) ),
    :delta-minute( :delta-mins(           :d-minutes( :$d-mins  )   ) ),
    :delta-hour(   :delta-hours(                      :$d-hours     ) ),
    :delta-day(    :delta-days(                       :$d-days      ) ),
    :$capture,
    *%pars where { $_ == 0 || die "Params not recognized: %pars.keys()" },
) {
    %*DATA<rules>.push: App::RakuCron::Rule.new:
        |(:id($_)       with $id      ),
        |(:year($_)     with $year    ),
        |(:month($_)    with $month   ),
        |(:day($_)      with $day     ),
        |(:hour($_)     with $hour    ),
        |(:min($_)      with $min     ),
        |(:sec($_)      with $sec     ),
        |(:wday($_)     with $wday    ),
        |(:last-run($_) with &last-run),
        |(:d-secs($_)   with $d-secs  ),
        |(:d-mins($_)   with $d-mins  ),
        |(:d-hours($_)  with $d-hours ),
        |(:d-days($_)   with $d-days  ),
        |(:capture($_)  with $capture ),
        :&proc
    ;
}

multi method run-at(+@values, *%pars) {
    my @current = @values.shift<>;

    my &proc = @current.pop if @current.tail ~~ Callable;
    &proc  //= @values.pop  if @values.tail  ~~ Callable;

    for @current -> Capture \c {
        self.run-at: |%pars, |c, |@values, |($_ with &proc)
    }
}

method jobs-should-run-at(DateTime $time) {
    @!rules.grep: { $time ~~ $_ }
}

method next-datetimes {
    merge-ordered-seqs(@!rules).squish
}
