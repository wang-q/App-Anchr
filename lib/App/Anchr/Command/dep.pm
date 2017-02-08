package App::Anchr::Command::dep;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => 'check or install dependances';

sub opt_spec {
    return ( [ 'install', 'install dependances', ], { show_defaults => 1, } );
}

sub usage_desc {
    return "anchr dep [options]";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} != 0 ) {
        my $message = "This command need no input files.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    if ( IPC::Cmd::can_run("bash") ) {
        print "*OK*: find [bash] in \$PATH\n";
    }
    else {
        print "*Failed*: can't find [bash] in \$PATH\n";
        exit 1;
    }

    if ( IPC::Cmd::can_run("brew") ) {
        print "*OK*: find [brew] in \$PATH\n";
    }
    else {
        print "*Failed*: can't find [brew] in \$PATH\n";
        exit 1;
    }

    if ( IPC::Cmd::can_run("cpanm") ) {
        print "*OK*: find [cpanm] in \$PATH\n";
    }
    else {
        print "*Failed*: can't find [cpanm] in \$PATH\n";
        exit 1;
    }

    if ( $opt->{install} ) {

    }
    else {
        my $sh = File::ShareDir::dist_file( 'App-Anchr', 'check_dep.sh' );
        if ( IPC::Cmd::run( [ "bash", $sh ] ) ) {
            print "*OK*: all dependances present\n";
            exit 0;
        }
    }

}

1;
