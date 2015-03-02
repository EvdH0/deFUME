package Portal::Page;
use strict;
use Error qw(:try);
use Portal::Error;
use Portal::PermissionError;
use Portal::ConfigError;
use Portal::Error;
use Portal::FileSizeError;
use Portal::DatabaseError;
use Portal::SessionExpiredError;
use HTML::Entities;
use CGI;
use Data::Dumper;
use JSON;

# Send off a report
my $mailer = '/usr/bin/Mail';

=item Portal::Page

## Render a page from a template, with DJANGO like syntax

# Render as whole page, including HTTP headers to STDOUT
  my $page=new Portal::Page("/path/filename",\%env);
  new Portal::Page()->stream(\*STDOUT)->header()->load("/path/filename")->render(\%env)

# Load and parse page, render later
  my $page = new Portal::Page()->load("/path/filename");
  print $page->render(\%env);
  print $page->render(\%otherenv);

# Render partial from buffers
  my $pagetext=new Portal::Page()->set("message")->render(\%env);
  print $pagetext;

# Render from buffers and email
  new Portal::Page()->set("message")->report(\%env);

# {{ <perlexpression> }}
# {% filter filterspec %}
# {% endfilter %}
# {% include file %}
# {% inject <perlexpression> %}
# {% if <perlexpression> %}
# {% elseif <perlexpression> %}
# {% endif %}
# {% for $var in <perlexpression> %}
# {% empty %}
# {% endfor %}
# {# some comment #}

Please notice that the concept of security is missing.
Anything goes, as to what may be evaluated. Untrusted users
should NOT be given access to write templates.

=cut

=item new

Create the class, load if specified. This is practical, since
pages may be pre-loaded and pre-parsed in the server, and rendered
at a later stage with varying environments

=cut

sub new
{

	# used for writing my $result=new Portal::Page($file,$arg1,$arg2..)
	my $self  = {};
	my $class = shift;
	$self = bless($self, $class);
	$self->{maxincludes} = 100;    # dirty hack to prevent infinite loops.
	my $file = shift;
	$self->{source}='/usr/opt/www/pub/CBS/services/MetaParser/visual/';
	local $| = 1;
	if (defined $file) {
		if (@_) {
			return $self->stream(\*STDOUT)->load($file)->render(@_);
		}else{
			return $self->load($file);
		}
	} else {
		$self->{path} = '.';
		return $self;
	}
}

sub json {
	my $rec=shift;
	my $flags={pretty=>1};
	return '{}' unless defined $rec;
	return to_json($rec,$flags);
}

=item stream

Specify the rendering to a stream

=cut

sub stream
{
	my $self = shift;
	$self->{stream} = shift;
	return $self;
}

=item header

Print out a HTML header

=cut

sub header
{
	my $self = shift;
	$self->streamout(CGI::header(@_));
	return $self;
}

=item filter

Static function, filters output according to filter rule

=cut

sub filter {
	my $text=shift;
	my $filter=shift;
	
	# TODO: implement filter rules 
	#  notagspace: eliminate spaces around tags.
	#  noindent: eliminate spaces after all newlines.
		
	return $text;
}

=item streamout

Emits output on stream. Must return text no matter what.

=cut

sub streamout {
	my $self=shift;
	my $text=shift;
	return $text unless exists $self->{stream};
	my $fh=$self->{stream}; 
	print $fh $text;
	return $text;
}

=item evaluate

Evaluate an expression relative to a given environment.
Please notice that the concept of security is missing.
Anything goes, as to what may be evaluated. The environment 
only supports one value per variable name - unlike perl. 
Any global variables and functions are also available.

=cut

sub evaluate
{
	my $__exp = shift;
	my $__env = shift;

	return '(undef)' unless defined $__exp;
	
	try {

		# Expand the environment inside the try block, to
		#   be able to expand the variables correct
		my $__val;
		my @__val;

		# We build up the entire eval string, with its own
		#  environment inherited from %{$__env}, and assign
		#  $__val or @__val the final result. The 'my' fields
		#  inside the eval are local to that eval.
		#  However! the expression still have access to the
		#  entirety of the rest of the perl environment so;
		#    no safety here!
		
		foreach my $var (keys %{$__env}) {
			$__val .= 'my $' . $var . '=$__env->{' . $var . '};';
		}

		if (wantarray()) {
			$__val.="\@__val=$__exp";
		} else {
			$__val.="\$__val=$__exp";
		}
		
		eval("$__val");
		throw Portal::ConfigError("Unable to assign value : $@ ($__val)" . Dumper($__env)) if $@;

		# Note: no updates to the environment are passed back there.
		return @__val if (wantarray());
		return $__val;
	  }
	  otherwise {
		my $e = shift;
		throw Portal::ConfigError("Error evaluating expression '$__exp' : $e");
	  };
}

=item processnode

Process a node parsed from the template (internal function)

=cut 

sub processnode
{
	my $self  = shift;
	my $nodes = shift;
	my $filter = shift;
	my $env   = shift;
	my $page;

	foreach my $node (@{$nodes}) {
		if ($node->{type} eq 'text') {
			$page .= $self->streamout(filter($node->{content},$filter));
		} elsif ($node->{type} eq 'if') {
			foreach my $branch (@{ $node->{branch} }) {
				if (evaluate($branch->{cond}, $env)) {
					$page .= $self->processnode($branch->{part}, $filter, $env);
					last;
				}
			}
		} elsif ($node->{type} eq 'include') {
			$page .= $self->processnode($node->{part}, $filter, $env);
		} elsif ($node->{type} eq 'filter') {
			$page .= $self->processnode($node->{part}, $node->{filter}, $env);
		} elsif ($node->{type} eq 'inject') {
			my $v = evaluate($node->{value}, $env);
			$page .= $self->streamout(filter($v,$filter));
		} elsif ($node->{type} eq 'value') {
			my $v = HTML::Entities::encode_entities(evaluate($node->{value}, $env), '<>&\"');
			$page .= $self->streamout(filter($v,$filter));
		} elsif ($node->{type} eq 'for') {
			my @list = evaluate($node->{list}, $env);
			if (!@list and exists $node->{empty}) {
				$page .= $self->processnode($node->{empty}->{part}, $filter, $env);
			} else {
				foreach my $i (@list) {
					next unless defined $i;
					my $dopush = exists($env->{ $node->{var} });
					my $istack;
					$istack = $env->{ $node->{var} } if ($dopush);
					$env->{ $node->{var} } = $i;
					$page .= $self->processnode($node->{part}, $filter, $env);
					$env->{ $node->{var} } = $istack if ($dopush);
				}
			}
			#warn("Endprocess $node->{type}\n");
		}
	}
	return $page;
}

=item render

Render the loaded and parsed page using a specififc environment.
Unlike regular perl, the environment allows only a single 

=cut

sub render
{
	my $self = shift;
	my %env;
	my $page;
	my $filter='';
	my @caller  = caller();
	
	throw Portal::SystemError("No template page loaded") unless defined($self->{page});

	# collect all variables and functions from argument array
	foreach my $arg (@_) {

		# we will ignore any arguments that are not hash refs
		next unless (ref($arg) eq 'HASH');
		
		foreach my $key (keys %{$arg}) {
			foreach my $reserved ('__val', '__exp', '_') {
				throw Portal::ConfigError("Illegal key '$reserved'") if ($key eq $reserved);
			}
			throw Portal::ConfigError("Illegal key '$key'") unless ($key =~ m/^[a-zA-Z_][a-zA-Z_0-9]*/);
			$env{$key} = $arg->{$key};
		}
	}

	try {
		$page = $self->processnode($self->{page}->{part}, $filter, \%env);
	}otherwise{
		my $e=shift;
		throw Portal::ConfigError("Problem rendering $self->{path} : $e at $caller[1] line $caller[2].\n"); 
	};
	#warn($page);
	return $page;
}

=item set

Set page source to buffer instead of loading

=cut

sub set
{
	my $self = shift;
	my $page = shift;
	return $self->parse($page);
}

=item top

Static: return top of array.

=cut

sub top
{
	return @_[-1];
}

# parse content
sub parse
{
	my $self  = shift;
	my $page  = shift;
	my @parts = split(/(\{\%.*?\%\}|\{\{.*?\}\}|\{\#.*?\#\})/, $page);
#	my $root  = { type => 'root', page => $page };
	my $root  = { type => 'root' };
	my @stack;
	push @stack, $root;

	throw Portal::SystemError("Page already parsed") if exists ($self->{page});

	foreach my $part (@parts) {
		my $node;
		if ($part =~ m/^\{\%\s+(include)\s+(.*?)\s+\%\}$/) {
			my $node = { type => $1, file => $2 };

			# Load data here
			$self->{includes}++;
			throw Portal::ConfigError("Too many includes including $node->{file}")
			  if ($self->{includes} > $self->{maxincludes});

			$node->{file} =~ s/^['"](.*)['"]$/$1/;

			# Shortcircuit the object here, just get the parsed structure
			#  structure needs to be balanced within each file, but
			#  thats a reasonable limitation anyway
			$node->{part} = Portal::Page->new($node->{file})->{page}->{part};
			push @{ $root->{part} }, $node;

		} elsif ($part =~ m/^\{\%\s+(inject)\s+(.*?)\s+\%\}$/) {
			my $node = { type => $1, value => $2 };
			push @{ $root->{part} }, $node;
		} elsif ($part =~ m/^\{\{\s+(.*?)\s+\}\}$/) {
			my $node = { type => 'value', value => $1 };
			push @{ $root->{part} }, $node;
		} elsif ($part =~ m/^\{\%\s+(if)\s+(.*?)\s+\%\}$/) {

			# Add the top if-node to the current root
			my $ifnode = { type => $1, branch => [] };
			push @{ $root->{part} }, $ifnode;
			push @stack, $ifnode;

			# Add the branch to the if-node and the stack
			my $node = { type => 'branch', cond => $2, parent => $ifnode };
			push @{ $ifnode->{branch} }, $node;
			push @stack, $node;
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(elsif)\s+(.*?)\s+\%\}$/) {
			my $node = { type => 'branch', cond => $2 };
			throw Portal::ConfigError("elsif not in if" . Dumper($stack[0])) if ($root->{type} ne 'branch');
			$node->{parent} = $root->{parent};
			push @{ $root->{parent}->{branch} }, $node;
			pop @stack;    # pop the last branch
			push @stack, $node;
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(else)\s+\%\}$/) {
			my $node = { type => 'branch', cond => 1 };
			throw Portal::ConfigError("else not in if" . Dumper($stack[0])) if ($root->{type} ne 'branch');
			push @{ $root->{parent}->{branch} }, $node;
			pop @stack;    # pop the last branch
			push @stack, $node;    # push else branch
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(endif)\s+\%\}$/) {
			throw Portal::ConfigError("endif not in if" . Dumper($stack[0])) if ($root->{type} ne 'branch');
			pop @stack;            # pop the last branch
			pop @stack;            # pop the if;
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(for)\s+\$([a-zA-Z_][a-zA-Z_0-9]*)\s+in\s+(.*?)\s+\%\}$/) {
			my $node = { type => $1, var => $2, list => $3 };
			push @{ $root->{part} }, $node;
			push @stack, $node;
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(filter)\s+(.*?)\s+\%\}$/) {
			my $node = { type => $1, filter => $2 };
			push @{ $root->{part} }, $node;
			push @stack, $node;
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(empty)\s+\%\}$/) {
			my $node = { type => $1 };
			throw Portal::ConfigError("empty not in for" . Dumper($stack[0])) if ($root->{type} ne 'for');
			$root->{empty} = $node;
			pop @stack;            # pop for node
			push @stack, $node;    # add empty node
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(endfor)\s+\%\}$/) {
			throw Portal::ConfigError("endfor not in for" . Dumper($stack[0]))
			  if ($root->{type} ne 'for' and $root->{type} ne 'empty');
			pop @stack;
			$root = top @stack;
		} elsif ($part =~ m/^\{\%\s+(endfilter)\s+\%\}$/) {
			throw Portal::ConfigError("endfor not in filter" . Dumper($stack[0]))
			  if ($root->{type} ne 'filter');
			pop @stack;
			$root = top @stack;
		} elsif ($part =~ m/^\{\#\s+(.*?)\s+\#\}$/) {
			my $node = { type => 'comment', comment => $1 };
			push @{ $root->{part} }, $node;

			# ignore ?
		} else {
			$node = { type => 'text', content => $part };
			push @{ $root->{part} }, $node;
		}
	}

	throw Portal::ConfigError("Unclosed $root->{type} in document" . Dumper($stack[0]))
	  if ($root->{type} ne 'root');
	$self->{page} = $root;
	return $self;
}

=item load

Load a template file, and parse its structure. Store the result in the 'page' structure - ready for rendering.

=cut

sub load
{
	my $self = shift;
	my $file = shift;
	my $page;
	
	$self->{path} = $file;
	throw Portal::ConfigError("Illegal template name $self->{path}") if ( $self->{path} =~ /^\//);
	throw Portal::ConfigError("Illegal template name $self->{path}") if ( $self->{path} =~ /\.\./);
	$self->{path} = "$self->{source}/$file";

	open(FILE, '<', $self->{path}) or throw Portal::ConfigError("Unable to open template file $self->{path} : $!");
	while (<FILE>) { $page .= $_; }
	close(FILE) or throw Portal::ConfigError("Unable to close template file $self->{path} : $!");

	$self->{path} = $file;
	return $self->parse($page);
}

# render the page as an email, and send it.
sub report
{
	my $self    = shift;
	my $email   = shift;
	my $subject = shift;
	my $message = $self->render(@_);
	open(MAIL, "|-", "$mailer -s '$subject' $email")
	  or throw Portal::SystemError("Unable to open Mail to $email : $!");
	print MAIL "Message from Portal:\n\n";
	print MAIL "$message\n\n--Portal\n";
	close(MAIL) or throw Portal::SystemError("Unable to send mail to $email : $!");
	return $self;
}

# static error function
sub error
{
	my $message = HTML::Entities::encode(shift);
	print STDOUT CGI::header(-nph => 0)
	  . CGI::start_html('Portal internal error')
	  . CGI::h1('We have problems')
	  . CGI::p('The message returned is:')
	  . CGI::pre($message)
	  . CGI::end_html();
}

1;

