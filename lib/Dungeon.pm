package Dungeon;

use v5.42;
use warnings;
use Carp qw( croak );

use Dancer2;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::Syntax::GetPost;
use Dancer2::Plugin::Syntax::ParamKeywords;
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::CryptPassphrase;

#
# Multitenancy magic!
#
hook 'before' => sub {
    if( my $username = session->read( 'user' ) ) {
        my $user = database( 'registry' )->quick_select(
            'users',
            { username => $username }
        );
        if( defined $user and $user->{ is_active } ) {
            var user => $user;

            debug "Connecting to tenant $username";
            my $tenant_dbh = database({ driver => 'SQLite', database => "var/db/${username}.db" });
            var tenant_dbh => $tenant_dbh;
        } else {
            session user => undef;
            redirect uri_for 'login';
        }
    }
};

#
# App content handled here!
#
get '/' => sub {
    render( 'index' );
};

get '/dashboard' => needs login => sub {
    my $tenant_dbh = var 'tenant_dbh';
    my $last = var('tenant_dbh')->query(
        'SELECT * FROM encounters ORDER BY encounter_id DESC LIMIT 1'
    )->hash;
    render( 'dashboard' );
};

get '/profile' => needs login => sub {
    my $user       = var 'user';
    my $tenant_dbh = var 'tenant_dbh';

    render( 'profile', { user => $user } );
};

#
# Authentication stuff
#
get '/login' => sub {
    template( 'login', { }, { layout => undef } );
};

post '/login' => sub {
    my $username = body_param( 'username' ) // '';
    my $password = body_param( 'password' ) // '';
    debug "Attempting to log in $username";

    my $user = database( 'registry' )->quick_select(
        'users',
        { username => $username }
    );

    if( defined $user and $user->{ is_active } and verify_password( $password, $user->{ password } )) {
        app->change_session_id;
        session user => $username;
        info "User $username logged in successfully";
        my $redirect_url = query_params( 'redirect_url' ) // '/';
        push_response_header 'HX-Redirect' => uri_for( $redirect_url );
    } else {
        if( not defined $user or not $user->{ is_active }) {
            # Failure conditions happen faster than a successful login. This gives
            # attackers information about what is happening behind the scenes. Run a
            # fake password check to flatten the timing curve.
            # Might need to update this if we change the argon params later. Consider
            # pregenerating this hash in prepare_app.
            verify_password( 'foobar', '$argon2id$v=19$m=65536,t=2,p=1$M/KquUs0lr1gphmvbqHazQ$Zfnzm5a1OO0LU8UdrRkxgmgaj0su3JeX01MVOYI2DFM' );
        }

        if( not defined $user ) {
            warning "Login attempt for invalid user $username";
        } elsif( not $user->{ is_active } ) {
            warning "Login attempt from $username, but user is inactive";
        } else {
            warning "Failed login attempt from $username";
        }
        status 401;
        return 'Invalid username or password.';
    }
};

any '/logout' => sub {
    my $username = session->read( 'user' );
    debug "Logging out $username...";
    if( defined $username ){
        app->destroy_session;
        info "User $username logged out successfully";
    }
    if( request_header( 'HX-Request' ) ) {
        push_response_header 'HX-Redirect' => uri_for( '/' );
        return '';
    }

    # We shouldn't get here, but if so, send us back to our start page
    redirect uri_for '/';
};

get '/access-denied' => sub {
    app->destroy_session;
    template 'access-denied', { }, { layout => undef };
};

#
# If this is an htmx request, return *only* the template content,
# else return the page and the layout.
#
sub render( $template, $args = {} ) {
    croak "render(): No template specified!" unless $template;

    my $options = { layout => config->{ layout }};
    if( request_header( 'HX-Request' ) ) {
        $options = { layout => undef };
        debug 'Request is ajax, not rendering a layout'
    }

    my $html = template( $template, $args, $options );
    return $html;
}

#
# Additional magical template processing
#
hook before_template_render => sub( $tokens ) {
    my $user = var 'user';
    $tokens->{ user } = $user;
};

#
# Don't leave the tenant hanging. Clean up tenant connections.
#
hook after => sub {
    my $tenant_dbh = var 'tenant_dbh';
    if ( $tenant_dbh->{ Active } ) {
        my $user = var 'user';
        debug 'Disconnecting from tenant ' . $user->{ username };
        $tenant_dbh->disconnect;
    }
};

true;
