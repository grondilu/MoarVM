package Config::dyncall;
use strict;
use warnings;

sub system_or_die {
    my @cmd = @_;
    system( @cmd ) == 0
        or die "Command failed (status $?): @cmd\n";
}

sub configure {
    my %config = @_;
    
    my $make = $config{'make'};
    if ($^O =~ /MSWin32/) {
        if ($make eq 'nmake') {
            system_or_die('@cd 3rdparty\dyncall && Configure.bat >NUL 2>NUL' . (`cl 2>&1` =~ /x64/ ? ' /target-x64' : ''));
            return (%config,
                dyncall_build => 'cd 3rdparty\dyncall && nmake /F Nmakefile'
            );
        }
        else {
            return (excuse => "Don't know how to build dyncall on Windows without Microsoft toolchain");
        }
    }
    else {
        my $target_args = '';
        # heuristic according to
        # https://github.com/perl6/nqp/issues/100#issuecomment-18523608
        if ($^O eq 'darwin' && qx/ld 2>&1/ =~ /inferred architecture x86_64/) {
            $target_args = " --target-x64";
        }
        system_or_die('cd 3rdparty/dyncall && sh configure' . $target_args);
        $config{'dyncall_build'} =
            "cd 3rdparty/dyncall && BUILD_DIR=. $make"
            . ($^O eq 'netbsd' ? " -f BSDmakefile" : "");
        return %config;
    }
}

sub can_run {
    my $try = shift;
    my $out = `$try 2>&1`;
    return defined $out && $out ne '';
}

'Yeti';
