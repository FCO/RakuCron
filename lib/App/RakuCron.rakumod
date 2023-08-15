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

App::RakuCron - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use App::RakuCron;

=end code

=head1 DESCRIPTION

App::RakuCron is ...

=head1 AUTHOR

Fernando Corrêa <fernando.correa@humanstate.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2023 Fernando Corrêa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
