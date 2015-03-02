package Portal::Error;
use base qw(Error::Simple);
sub show {
	my $e=shift;
	print Dumper($e);
}

1;
