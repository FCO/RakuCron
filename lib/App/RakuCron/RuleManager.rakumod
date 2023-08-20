use App::RakuCron::Rule;
use App::RakuCron::Rules;
unit class App::RakuCron::RuleManager;

has App::RakuCron::Rule %.rules handles *;
has Promise             $.running;

method keyof { Str }
method of    { App::RakuCron::Rule }

multi method del-rule(Str $id) {
    %!rules{$id}:delete
}

multi method add-rules(App::RakuCron::Rule $rule) {
    # TODO: validate if that rule already exists
    %!rules{$rule.id} = $rule
}

multi method add-rules(App::RakuCron::Rules $_) {
    my %rules = .rules.map: { .id => $_ }
    for %!rules.keys -> Str $key {
        $.del-rule: $key
    }
    $.add-rules: $_ for .rules
}

method jobs-should-run-at(DateTime $time) {
    %!rules.values.grep: { $time ~~ $_ }
}

method running-rules {
    %!rules.values.grep: { .on }
}

method next-datetimes {
    supply for DateTime.now.truncated-to("seconds"), *.later(:1seconds) ... * -> DateTime $time {
        emit $time if $time ~~ @.running-rules.any
    }
}

method start {
    $!running = start react {
        ENTER done unless @.running-rules;
        whenever $.next-datetimes -> DateTime $time {
            LEAVE done unless @.running-rules;
            await Promise.at: $time.Instant;
            for @.jobs-should-run-at: $time {
                next unless .delta-validations: $time;
                .run($time);
            }
        }
    }
}
