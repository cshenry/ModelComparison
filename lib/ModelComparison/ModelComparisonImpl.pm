package ModelComparison::ModelComparisonImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

ModelComparison

=head1 DESCRIPTION

A KBase module: ModelComparison

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Config::IniFiles;
use Data::Dumper;
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    
    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('ModelComparison','workspace-url');
    die "no workspace-url defined" unless $wsInstance;
    
    $self->{'workspace-url'} = $wsInstance;
    
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 compare_models

  $return = $obj->compare_models($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ModelComparison.ModelComparisonParams
$return is a ModelComparison.ModelComparisonResult
ModelComparisonParams is a reference to a hash where the following keys are defined:
	models has a value which is a reference to a list where each element is a ModelComparison.Model_ref
	protcomp_ref has a value which is a ModelComparison.Protcomp_ref
	pangenome_ref has a value which is a ModelComparison.Pangenome_ref
Model_ref is a string
Protcomp_ref is a string
Pangenome_ref is a string
ModelComparisonResult is a reference to a hash where the following keys are defined:
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
ModelComparisonModel is a reference to a hash where the following keys are defined:
	id has a value which is a string
	model_ref has a value which is a ModelComparison.Model_ref
	genome_ref has a value which is a ModelComparison.Genome_ref
	model_similarity has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 5 items:
		0: (common_reactions) an int
		1: (common_compounds) an int
		2: (common_biomasscpds) an int
		3: (common_families) an int
		4: (common_gpr) an int

	name has a value which is a string
	taxonomy has a value which is a string
	reactions has a value which is an int
	families has a value which is an int
	compounds has a value which is an int
	biomasscpds has a value which is an int
	biomasses has a value which is an int
Genome_ref is a string
ModelComparisonReaction is a reference to a hash where the following keys are defined:
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

Reaction_ref is a string
bool is an int
Feature_id is a string
Family_id is a string
ModelComparisonCompound is a reference to a hash where the following keys are defined:
	id has a value which is a string
	compound_ref has a value which is a ModelComparison.Compound_ref
	name has a value which is a string
	number_models has a value which is an int
	fraction_models has a value which is a float
	core has a value which is a ModelComparison.bool
	model_compound_compartments has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a reference to a list containing 2 items:
		0: a ModelComparison.Compartment_ref
		1: (charge) a float

Compound_ref is a string
Compartment_ref is a string
ModelComparisonFamily is a reference to a hash where the following keys are defined:
	id has a value which is a string
	family_id has a value which is a ModelComparison.Family_id
	function has a value which is a string
	number_models has a value which is an int
	fraction_models has a value which is a float
	core has a value which is a ModelComparison.bool
	family_model_data has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 2 items:
		0: (present) a ModelComparison.bool
		1: a reference to a list where each element is a ModelComparison.reaction_id

reaction_id is a string
ModelComparisonBiomassCompound is a reference to a hash where the following keys are defined:
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

$params is a ModelComparison.ModelComparisonParams
$return is a ModelComparison.ModelComparisonResult
ModelComparisonParams is a reference to a hash where the following keys are defined:
	models has a value which is a reference to a list where each element is a ModelComparison.Model_ref
	protcomp_ref has a value which is a ModelComparison.Protcomp_ref
	pangenome_ref has a value which is a ModelComparison.Pangenome_ref
Model_ref is a string
Protcomp_ref is a string
Pangenome_ref is a string
ModelComparisonResult is a reference to a hash where the following keys are defined:
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
ModelComparisonModel is a reference to a hash where the following keys are defined:
	id has a value which is a string
	model_ref has a value which is a ModelComparison.Model_ref
	genome_ref has a value which is a ModelComparison.Genome_ref
	model_similarity has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 5 items:
		0: (common_reactions) an int
		1: (common_compounds) an int
		2: (common_biomasscpds) an int
		3: (common_families) an int
		4: (common_gpr) an int

	name has a value which is a string
	taxonomy has a value which is a string
	reactions has a value which is an int
	families has a value which is an int
	compounds has a value which is an int
	biomasscpds has a value which is an int
	biomasses has a value which is an int
Genome_ref is a string
ModelComparisonReaction is a reference to a hash where the following keys are defined:
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

Reaction_ref is a string
bool is an int
Feature_id is a string
Family_id is a string
ModelComparisonCompound is a reference to a hash where the following keys are defined:
	id has a value which is a string
	compound_ref has a value which is a ModelComparison.Compound_ref
	name has a value which is a string
	number_models has a value which is an int
	fraction_models has a value which is a float
	core has a value which is a ModelComparison.bool
	model_compound_compartments has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a reference to a list containing 2 items:
		0: a ModelComparison.Compartment_ref
		1: (charge) a float

Compound_ref is a string
Compartment_ref is a string
ModelComparisonFamily is a reference to a hash where the following keys are defined:
	id has a value which is a string
	family_id has a value which is a ModelComparison.Family_id
	function has a value which is a string
	number_models has a value which is an int
	fraction_models has a value which is a float
	core has a value which is a ModelComparison.bool
	family_model_data has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 2 items:
		0: (present) a ModelComparison.bool
		1: a reference to a list where each element is a ModelComparison.reaction_id

reaction_id is a string
ModelComparisonBiomassCompound is a reference to a hash where the following keys are defined:
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



=item Description

Compare models

=back

=cut

sub compare_models
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to compare_models:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_models');
    }

    my $ctx = $ModelComparison::ModelComparisonServer::CallContext;
    my($return);
    #BEGIN compare_models

    my @model_refs = @{$params->{models}};
    print "@model_refs\n";
    my $protcomp_ref = $params->{protcomp_ref};
    my $pangenome_ref = $params->{pangenome_ref};
    $return = {};
    #END compare_models
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to compare_models:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'compare_models');
    }
    return($return);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
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
model_ref has a value which is a ModelComparison.Model_ref
genome_ref has a value which is a ModelComparison.Genome_ref
model_similarity has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 5 items:
	0: (common_reactions) an int
	1: (common_compounds) an int
	2: (common_biomasscpds) an int
	3: (common_families) an int
	4: (common_gpr) an int

name has a value which is a string
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
model_ref has a value which is a ModelComparison.Model_ref
genome_ref has a value which is a ModelComparison.Genome_ref
model_similarity has a value which is a reference to a hash where the key is a string and the value is a reference to a list containing 5 items:
	0: (common_reactions) an int
	1: (common_compounds) an int
	2: (common_biomasscpds) an int
	3: (common_families) an int
	4: (common_gpr) an int

name has a value which is a string
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

ModelComparisonParams object: a list of models and optional pangenome and protein comparison

@optional protcomp_ref pangenome_ref


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
models has a value which is a reference to a list where each element is a ModelComparison.Model_ref
protcomp_ref has a value which is a ModelComparison.Protcomp_ref
pangenome_ref has a value which is a ModelComparison.Pangenome_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
models has a value which is a reference to a list where each element is a ModelComparison.Model_ref
protcomp_ref has a value which is a ModelComparison.Protcomp_ref
pangenome_ref has a value which is a ModelComparison.Pangenome_ref


=end text

=back



=head2 ModelComparisonResult

=over 4



=item Description

ModelComparisonResult object: this object holds information about a comparison of multiple models

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



=cut

1;
