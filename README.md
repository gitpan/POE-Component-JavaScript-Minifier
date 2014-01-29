# NAME

POE::Component::JavaScript::Minifier - non-blocking wrapper around JavaScript::Minifier with URI fetching abilities

# SYNOPSIS

    use strict;
    use warnings;

    use POE qw/Component::JavaScript::Minifier/;

    my $poco = POE::Component::JavaScript::Minifier->spawn;

    POE::Session->create( package_states => [ main => [qw(_start results)] ], );

    $poe_kernel->run;

    sub _start {
        $poco->minify({
            event   => 'results',
            uri     => 'http://zoffix.com/main.js',
            outfile => 'out.js',
        });
    }

    sub results {
        if ( $_[ARG0]->{error} ) {
            print "Error: $_[ARG0]->{error}\n";
        }
        else {
            print "Minified JS: $_[ARG0]->{outfile}\n";
        }
        $poco->shutdown;
    }

    # Using event based interface is also possible of course.

# DESCRIPTION

The module is a non-blocking wrapper around [JavaScript::Minifier](https://metacpan.org/pod/JavaScript::Minifier), which provides interface to
strip useless spaces from JavaScript code. The wrapper also provides additional functionality to
fetch JavaScript from URI.

# CONSTRUCTOR

## `spawn`

    my $poco = POE::Component::JavaScript::Minifier->spawn;

    POE::Component::JavaScript::Minifier->spawn(
        alias => 'mini',
        ua_args => { timeout => 30 },
        options => {
            debug => 1,
            trace => 1,
            # POE::Session arguments for the component
        },
        debug => 1, # output some debug info
    );

The `spawn` method returns a
POE::Component::JavaScript::Minifier object. It takes a few arguments,
_all of which are optional_. The possible arguments are as follows:

### `alias`

    ->spawn( alias => 'mini' );

__Optional__. Specifies a POE Kernel alias for the component.

### `ua_args`

    ->spawn( ua_args => { timeout => 30 }, );

__Optional__. Takes a hashref as an argument that will be directly dereferenced into
[LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)'s constructor when `uri` argument in `minify` event/method is used
as input. __Defaults to:__ empty hashref.

### `options`

    ->spawn(
        options => {
            trace => 1,
            default => 1,
        },
    );

__Optional__.
A hashref of POE Session options to pass to the component's session.

### `debug`

    ->spawn(
        debug => 1
    );

When set to a true value turns on output of debug messages. __Defaults to:__
`0`.

# METHODS

## `minify`

    $poco->minify( {
            event       => 'event_for_output',
            uri         => 'http://zoffix.com/main.js',
            outfile     => 'minified.js',
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

Takes a hashref as an argument, does not return a sensible return value.
See `minify` event's description for description and list of all accepted arguments.

## `session_id`

    my $poco_id = $poco->session_id;

Takes no arguments. Returns component's session ID.

## `shutdown`

    $poco->shutdown;

Takes no arguments. Shuts down the component.

# ACCEPTED EVENTS

## `minify`

    $poe_kernel->post( mini => minify => {
            event       => 'event_for_output',
            uri         => 'http://zoffix.com/main.js',
            outfile     => 'minified.js', # optional,
            copyright   => 'BSD License', # optional
            stripDebug  => 1,             # optional
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

    # or

    $poe_kernel->post( mini => minify => {
            event       => 'event_for_output',
            infile      => 'in.js',
            outfile     => 'minified.js', # optional
            copyright   => 'BSD License', # optional
            stripDebug  => 1,             # optional
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

    # or

    $poe_kernel->post( mini => minify => {
            event       => 'event_for_output',
            in          => 'var x = 2;',
            outfile     => 'minified.js', # optional
            copyright   => 'BSD License', # optional
            stripDebug  => 1,             # optional
            _blah       => 'pooh!',
            session     => 'other',
        }
    );

Instructs the component to strip useless spaces from JavaScript code. Takes a hashref as an
argument, the possible keys/value of that hashref are as follows:

### `event`

    { event => 'results_event', }

__Mandatory__. Specifies the name of the event to emit when results are
ready. See OUTPUT section for more information.

### `in`

    { in => 'var x = 2;' }

__Optional__. One of the methods to give input. Takes a string with JavaScript code to
"minify" as an argument.

### `uri`

    { uri => 'http://zoffix.com/main.js' }

__Optional__. One of the methods to give input. Takes a URI as a value that will be fetched
and serve as JavaScript code to "minify".

### `infile`

    { infile => 'in.js' }

__Optional__. One of the methods to give input. Takes a filename as an argument. The
file will be opened and the filehandle will be given to `minify()` function of
[JavaScript::Minifier](https://metacpan.org/pod/JavaScript::Minifier) to serve as JavaScript code to "minify".

### `outfile`

    { outfile => 'minified.js' }

__Optional__. When specified, the "minified" JavaScript code will be written to the file, filename
of which you specify in `outfile` argument. Note: file will be created if does not exist and
completely destroyed without a warning if it does exist. If not specified the
minified JavaScript code will be passed to the output event handler (see below).

### `copyright` and `stripDebug`

    {
        copyright   => 'BSD License',
        stripDebug  => 1,
    }

Both are __optional__. Function exactly the same as they do in `minify()` sub of
[JavaScript::Minifier](https://metacpan.org/pod/JavaScript::Minifier). See documentation for [JavaScript::Minifier](https://metacpan.org/pod/JavaScript::Minifier) for more information.

### `session`

    { session => 'other' }

    { session => $other_session_reference }

    { session => $other_session_ID }

__Optional__. Takes either an alias, reference or an ID of an alternative
session to send output to.

### user defined

    {
        _user    => 'random',
        _another => 'more',
    }

__Optional__. Any keys starting with `_` (underscore) will not affect the
component and will be passed back in the result intact.

## `shutdown`

    $poe_kernel->post( mini => 'shutdown' );

Takes no arguments. Tells the component to shut itself down.

# OUTPUT

    $VAR1 = {
        'out' => 'var x=2;',
        'in' => 'var x = 2;',
        '_blah' => 'foos'
    };

The event handler set up to handle the event which you've specified in
the `event` argument to `minify()` method/event will receive input
in the `$_[ARG0]` in a form of a hashref. The possible keys/value of
that hashref are as follows:

## `out`

    { 'out' => 'var x=2;', }

Unless `outfile` was specified as an argument to `minify` event/method, the `out` key
will be present and its value will be minified JavaScript code.

## `error`

    { 'error' => 'infile error [No such file or directory]' }

If an error occurred, the `error` key will be present and its value will be description
of an error. The error could be errors during opening input or output files as well as
network errors when `uri` argument was given to `minify` event/method.

## `in`, `uri` and `infile`

    { 'in' => 'var x = 2;', }

Depending on how you are giving the input to `minify` event/method, the key you specify in
`minify` event/method will be present in the output.

### `copyright` and `stripDebug`

    {
        'copyright'  => 'BSD License',
        'stripDebug' => 1,
    }

If you specified `copyright` or `stripDebug` options to `minify()` event/method, the values
you specified will be intact in the output.

## user defined

    { '_blah' => 'foos' }

Any arguments beginning with `_` (underscore) passed into the `minify()`
event/method will be present intact in the result.

# SEE ALSO

[POE](https://metacpan.org/pod/POE), [JavaScript::Minifier](https://metacpan.org/pod/JavaScript::Minifier)

# REPOSITORY

Fork this module on GitHub:
[https://github.com/zoffixznet/POE-Component-JavaScript-Minifier](https://github.com/zoffixznet/POE-Component-JavaScript-Minifier)

# BUGS

To report bugs or request features, please use
[https://github.com/zoffixznet/POE-Component-JavaScript-Minifier/issues](https://github.com/zoffixznet/POE-Component-JavaScript-Minifier/issues)

If you can't access GitHub, you can email your request
to `bug-POE-Component-JavaScript-Minifier at rt.cpan.org`

# AUTHOR

Zoffix Znet <zoffix at cpan.org>
([http://zoffix.com/](http://zoffix.com/), [http://haslayout.net/](http://haslayout.net/))

# LICENSE

You can use and distribute this module under the same terms as Perl itself.
See the `LICENSE` file included in this distribution for complete
details.
