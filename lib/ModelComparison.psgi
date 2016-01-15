use ModelComparison::ModelComparisonImpl;

use ModelComparison::ModelComparisonServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = ModelComparison::ModelComparisonImpl->new;
    push(@dispatch, 'ModelComparison' => $obj);
}


my $server = ModelComparison::ModelComparisonServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
