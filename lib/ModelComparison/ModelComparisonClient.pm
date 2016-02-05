package ModelComparison::ModelComparisonClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

ModelComparison::ModelComparisonClient

=head1 DESCRIPTION


A KBase module: ModelComparison


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => ModelComparison::ModelComparisonClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 compare_models

  $return = $obj->compare_models($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ModelComparison.ModelComparisonParams
$return is a ModelComparison.ModelComparisonResult
ModelComparisonParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a string
	mc_name has a value which is a string
	model_refs has a value which is a reference to a list where each element is a ModelComparison.Model_ref
	protcomp_ref has a value which is a ModelComparison.Protcomp_ref
	pangenome_ref has a value which is a ModelComparison.Pangenome_ref
Model_ref is a string
Protcomp_ref is a string
Pangenome_ref is a string
ModelComparisonResult is a reference to a hash where the following keys are defined:
	mc_ref has a value which is a string

</pre>

=end html

=begin text

$params is a ModelComparison.ModelComparisonParams
$return is a ModelComparison.ModelComparisonResult
ModelComparisonParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a string
	mc_name has a value which is a string
	model_refs has a value which is a reference to a list where each element is a ModelComparison.Model_ref
	protcomp_ref has a value which is a ModelComparison.Protcomp_ref
	pangenome_ref has a value which is a ModelComparison.Pangenome_ref
Model_ref is a string
Protcomp_ref is a string
Pangenome_ref is a string
ModelComparisonResult is a reference to a hash where the following keys are defined:
	mc_ref has a value which is a string


=end text

=item Description

Compare models

=back

=cut

 sub compare_models
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compare_models (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compare_models:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compare_models');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ModelComparison.compare_models",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'compare_models',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compare_models",
					    status_line => $self->{client}->status_line,
					    method_name => 'compare_models',
				       );
    }
}
 
  

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "ModelComparison.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'compare_models',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method compare_models",
            status_line => $self->{client}->status_line,
            method_name => 'compare_models',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for ModelComparison::ModelComparisonClient\n";
    }
    if ($sMajor == 0) {
        warn "ModelComparison::ModelComparisonClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 bool

=over 4



=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 reaction_id

=over 4



=item Description

Reaction ID
@id external


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Feature_id

=over 4



=item Description

Genome feature ID
@id external


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Family_id

=over 4



=item Description

Feature family ID
@id external


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Model_ref

=over 4



=item Description

Reference to metabolic model
@id ws KBaseFBA.FBAModel


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Genome_ref

=over 4



=item Description

Reference to KBase genome
@id ws KBaseGenomes.Genome


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Pangenome_ref

=over 4



=item Description

Reference to a Pangenome object in the workspace
@id ws KBaseGenomes.Pangenome


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Protcomp_ref

=over 4



=item Description

Reference to a Proteome Comparison object in the workspace
@id ws GenomeComparison.ProteomeComparison


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Reaction_ref

=over 4



=item Description

Reference to a reaction object in a biochemistry
@id subws KBaseBiochem.Biochemistry.reactions.[*].id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Compound_ref

=over 4



=item Description

Reference to a compound object
@id subws KBaseBiochem.Biochemistry.compounds.[*].id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Compartment_ref

=over 4



=item Description

Reference to a compartment object
@id subws KBaseBiochem.Biochemistry.compartments.[*].id


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ModelComparisonModel

=over 4



=item Description

ModelComparisonModel object: this object holds information about a model in a model comparison


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
model_ref has a value which is a ModelComparison.Model_ref
genome_ref has a value which is a ModelComparison.Genome_ref
model_similarity has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 5 items:
	0: (common_reactions) an int
	1: (common_compounds) an int
	2: (common_biomasscpds) an int
	3: (common_families) an int
	4: (common_gpr) an int

scientific_name has a value which is a string
taxonomy has a value which is a string
reactions has a value which is an int
families has a value which is an int
compounds has a value which is an int
biomasscpds has a value which is an int
biomasses has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
model_ref has a value which is a ModelComparison.Model_ref
genome_ref has a value which is a ModelComparison.Genome_ref
model_similarity has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 5 items:
	0: (common_reactions) an int
	1: (common_compounds) an int
	2: (common_biomasscpds) an int
	3: (common_families) an int
	4: (common_gpr) an int

scientific_name has a value which is a string
taxonomy has a value which is a string
reactions has a value which is an int
families has a value which is an int
compounds has a value which is an int
biomasscpds has a value which is an int
biomasses has a value which is an int


=end text

=back



=head2 ModelComparisonFamily

=over 4



=item Description

ModelComparisonFamily object: this object holds information about a protein family across a set of models


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
family_id has a value which is a ModelComparison.Family_id
function has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
family_model_data has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 2 items:
	0: (present) a ModelComparison.bool
	1: a reference to a list where each element is a ModelComparison.reaction_id


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
family_id has a value which is a ModelComparison.Family_id
function has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
family_model_data has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 2 items:
	0: (present) a ModelComparison.bool
	1: a reference to a list where each element is a ModelComparison.reaction_id



=end text

=back



=head2 ModelComparisonReaction

=over 4



=item Description

ModelComparisonReaction object: this object holds information about a reaction across all compared models


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
reaction_ref has a value which is a ModelComparison.Reaction_ref
name has a value which is a string
equation has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
reaction_model_data has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 4 items:
	0: (present) a ModelComparison.bool
	1: (direction) a string
	2: a reference to a list where each element is a reference to a list containing 4 items:
			0: a ModelComparison.Feature_id
			1: a ModelComparison.Family_id
			2: (conservation) a float
			3: (missing) a ModelComparison.bool
	
	3: (gpr) a string


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
reaction_ref has a value which is a ModelComparison.Reaction_ref
name has a value which is a string
equation has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
reaction_model_data has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 4 items:
	0: (present) a ModelComparison.bool
	1: (direction) a string
	2: a reference to a list where each element is a reference to a list containing 4 items:
			0: a ModelComparison.Feature_id
			1: a ModelComparison.Family_id
			2: (conservation) a float
			3: (missing) a ModelComparison.bool
	
	3: (gpr) a string



=end text

=back



=head2 ModelComparisonCompound

=over 4



=item Description

ModelComparisonCompound object: this object holds information about a compound across a set of models


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
compound_ref has a value which is a ModelComparison.Compound_ref
name has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
model_compound_compartments has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a reference to a list containing 2 items:
	0: a ModelComparison.Compartment_ref
	1: (charge) a float


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
compound_ref has a value which is a ModelComparison.Compound_ref
name has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
model_compound_compartments has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a reference to a list containing 2 items:
	0: a ModelComparison.Compartment_ref
	1: (charge) a float



=end text

=back



=head2 ModelComparisonBiomassCompound

=over 4



=item Description

ModelComparisonBiomassCompound object: this object holds information about a biomass compound across a set of models


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
compound_ref has a value which is a ModelComparison.Compound_ref
name has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
model_biomass_compounds has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a reference to a list containing 2 items:
	0: a ModelComparison.Compartment_ref
	1: (coefficient) a float


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
compound_ref has a value which is a ModelComparison.Compound_ref
name has a value which is a string
number_models has a value which is an int
fraction_models has a value which is a float
core has a value which is a ModelComparison.bool
model_biomass_compounds has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a reference to a list containing 2 items:
	0: a ModelComparison.Compartment_ref
	1: (coefficient) a float



=end text

=back



=head2 ModelComparisonParams

=over 4



=item Description

ModelComparisonParams object: a list of models and optional pangenome and protein comparison; mc_name is the name for the new object.

@optional protcomp_ref pangenome_ref


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a string
mc_name has a value which is a string
model_refs has a value which is a reference to a list where each element is a ModelComparison.Model_ref
protcomp_ref has a value which is a ModelComparison.Protcomp_ref
pangenome_ref has a value which is a ModelComparison.Pangenome_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a string
mc_name has a value which is a string
model_refs has a value which is a reference to a list where each element is a ModelComparison.Model_ref
protcomp_ref has a value which is a ModelComparison.Protcomp_ref
pangenome_ref has a value which is a ModelComparison.Pangenome_ref


=end text

=back



=head2 ModelComparison

=over 4



=item Description

ModelComparison object: this object holds information about a comparison of multiple models

@optional protcomp_ref pangenome_ref
@metadata ws core_reactions as Core reactions
@metadata ws core_compounds as Core compounds
@metadata ws core_families as Core families
@metadata ws core_biomass_compounds as Core biomass compounds
@metadata ws name as Name
@metadata ws id as ID
@metadata ws length(models) as Number models
@metadata ws length(reactions) as Number reactions
@metadata ws length(compounds) as Number compounds
@metadata ws length(families) as Number families
@metadata ws length(biomasscpds) as Number biomass compounds


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
core_reactions has a value which is an int
core_compounds has a value which is an int
core_families has a value which is an int
core_biomass_compounds has a value which is an int
protcomp_ref has a value which is a ModelComparison.Protcomp_ref
pangenome_ref has a value which is a ModelComparison.Pangenome_ref
models has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonModel
reactions has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonReaction
compounds has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonCompound
families has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonFamily
biomasscpds has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonBiomassCompound

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a string
name has a value which is a string
core_reactions has a value which is an int
core_compounds has a value which is an int
core_families has a value which is an int
core_biomass_compounds has a value which is an int
protcomp_ref has a value which is a ModelComparison.Protcomp_ref
pangenome_ref has a value which is a ModelComparison.Pangenome_ref
models has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonModel
reactions has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonReaction
compounds has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonCompound
families has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonFamily
biomasscpds has a value which is a reference to a list where each element is a ModelComparison.ModelComparisonBiomassCompound


=end text

=back



=head2 ModelComparisonResult

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
mc_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
mc_ref has a value which is a string


=end text

=back



=cut

package ModelComparison::ModelComparisonClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
