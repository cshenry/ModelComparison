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
	workspace has a value which is a string
	mc_name has a value which is a string
	model_refs has a value which is a reference to a list where each element is a ModelComparison.Model_ref
	protcomp_ref has a value which is a ModelComparison.Protcomp_ref
	pangenome_ref has a value which is a ModelComparison.Pangenome_ref
Model_ref is a string
Protcomp_ref is a string
Pangenome_ref is a string
ModelComparisonResult is a reference to a hash where the following keys are defined:
	report_name has a value which is a string
	report_ref has a value which is a string
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
	report_name has a value which is a string
	report_ref has a value which is a string
	mc_ref has a value which is a string


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

    if (!exists $params->{'model_refs'}) {
        die "Parameter model_refs is not set in input arguments";
    } elsif (@{$params->{model_refs}} < 2) {
	die "Must select at least two models to compare";
    }

    my $mc_name = $params->{mc_name};
    my @model_refs = @{$params->{model_refs}};
    my $protcomp_ref = $params->{protcomp_ref};
    my $pangenome_ref = $params->{pangenome_ref};
    $return = {};

    if (!exists $params->{'workspace'}) {
        die "Parameter workspace is not set in input arguments";
    }
    my $workspace_name=$params->{'workspace'};
    my $token=$ctx->token;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    my $provenance = [{}];
    $provenance = $ctx->provenance if defined $ctx->provenance;

    my @models;
    foreach my $model_ref (@model_refs) {
	my $model=undef;
	eval {
	    $model=$wsClient->get_objects([{ref=>$model_ref}])->[0]{data};
	    $model->{model_ref} = $model_ref;
	    push @models, $model;
	    push @{$provenance->[0]->{'input_ws_objects'}}, $model_ref;
	};
	if ($@) {
	    die "Error loading model from workspace:\n".$@;
	}
    }

    my $protcomp;
    if (defined $protcomp_ref) {
	eval {
	    $protcomp=$wsClient->get_objects([{ref=>$protcomp_ref}])->[0]{data};
	    push @{$provenance->[0]->{'input_ws_objects'}}, $protcomp_ref;
	};
	if ($@) {
	    die "Error loading protein comparison from workspace:\n".$@;
	}
    }

    my $pangenome;
    if (defined $pangenome_ref) {
	eval {
	    $pangenome=$wsClient->get_objects([{ref=>$pangenome_ref}])->[0]{data};
	    push @{$provenance->[0]->{'input_ws_objects'}}, $pangenome_ref;
	};
	if ($@) {
	    die "Error loading pangenome from workspace:\n".$@;
	}
    }

    print "All data loaded from workspace\n";

    # PREPARE MODEL INFO
    my %mcpd_refs; # hash from modelcompound_refs to their data
    my %ftr2model; # hash from gene feature ids to the models they are in
    my %ftr2reactions;

    foreach my $model (@models) {
	print "Processing model ", $model->{id}, "\n";
	foreach my $cmp (@{$model->{modelcompartments}}) {
	    $model->{cmphash}->{$cmp->{id}} = $cmp;
	}
	foreach my $cpd (@{$model->{modelcompounds}}) {
	    $cpd->{cmpkbid} = pop @{[split "/", $cpd->{modelcompartment_ref}]};
	    $cpd->{cpdkbid} = pop @{[split "/", $cpd->{compound_ref}]};
	    if (! defined $cpd->{name}) {
		$cpd->{name} = $cpd->{id};
	    }
	    $cpd->{name} =~ s/_[a-zA-z]\d+$//g;
	    
	    $model->{cpdhash}->{$cpd->{id}} = $cpd;
	    if ($cpd->{cpdkbid} ne "cpd00000") {
		$model->{cpdhash}->{$cpd->{$cpd->{cpdkbid}."_".$cpd->{cmpkbid}}} = $cpd;
	    }
	}
	foreach my $rxn (@{$model->{modelreactions}}) {
	    $rxn->{rxnkbid} = pop @{[split "/", $rxn->{reaction_ref}]};
	    $rxn->{cmpkbid} = pop @{[split "/", $rxn->{modelcompartment_ref}]};
	    $rxn->{dispid} = $rxn->{id};
	    $rxn->{dispid} =~ s/_[a-zA-z]\d+$//g;
	    $rxn->{dispid} .= "[".$rxn->{cmpkbid}."]";
	    if ($rxn->{name} eq "CustomReaction") {
		$rxn->{name} = $rxn->{id};
	    }
	    $rxn->{name} =~ s/_[a-zA-z]\d+$//g;
	    $model->{rxnhash}->{$rxn->{id}} = $rxn;
	    if ($rxn->{rxnkbid} ne "rxn00000") {
		$model->{rxnhash}->{$rxn->{rxnkbid}."_".$rxn->{cmpkbid}} = $rxn;
		if ($rxn->{rxnkbid}."_".$rxn->{cmpkbid} ne $rxn->{id}) {
		    $rxn->{dispid} .= "<br>(".$rxn->{rxnkbid}.")";
		}
	    }
	    my $reactants = "";
	    my $products = "";
	    my $sign = "<=>";
	    if ($rxn->{direction} eq ">") {
		$sign = "=>";
	    } elsif ($rxn->{direction} eq "<") {
		$sign = "<=";
	    }
	    foreach my $rgt (@{$rxn->{modelReactionReagents}}) {
		$rgt->{cpdkbid} = pop @{[split "/", $rgt->{modelcompound_ref}]};
		$mcpd_refs{$rgt->{modelcompound_ref}} = $model->{cpdhash}->{$rgt->{cpdkbid}}; # keep track of model compound refs
		if ($rgt->{coefficient} < 0) {
		    if ($reactants ne "") {
			$reactants .= " + ";
		    }
		    if ($rgt->{coefficient} != -1) {
			my $abscoef = int(-1*100*$rgt->{coefficient})/100;
			$reactants .= "(".$abscoef.") ";
		    }
		    $reactants .= $model->{cpdhash}->{$rgt->{cpdkbid}}->{name}."[".$model->{cpdhash}->{$rgt->{cpdkbid}}->{cmpkbid}."]";
		} else {
		    if ($products ne "") {
			$products .= " + ";
		    }
		    if ($rgt->{coefficient} != 1) {
			my $abscoef = int(100*$rgt->{coefficient})/100;
			$products .= "(".$abscoef.") ";
		    }
		    $products .= $model->{cpdhash}->{$rgt->{cpdkbid}}->{name}."[".$model->{cpdhash}->{$rgt->{cpdkbid}}->{cmpkbid}."]";
		}
	    }
	    $rxn->{ftrhash} = {};
	    foreach my $prot (@{$rxn->{modelReactionProteins}}) {
		foreach my $subunit (@{$prot->{modelReactionProteinSubunits}}) {
		    foreach my $feature (@{$subunit->{feature_refs}}) {
			my $ef = pop @{[split "/", $feature]};
			$rxn->{ftrhash}->{$ef} = 1;
			$ftr2model{$ef}->{$model->{id}} = 1;
			$ftr2reactions{$ef}->{$rxn->{id}} = 1;
		    }
		}
	    }
	    $rxn->{dispfeatures} = "";
	    foreach my $gene (keys %{$rxn->{ftrhash}}) {
		if ($rxn->{dispfeatures} ne "") {
		    $rxn->{dispfeatures} .= "<br>";
		}
		$rxn->{dispfeatures} .= $gene;
	    }
	    $rxn->{equation} = $reactants." ".$sign." ".$products;
	}
    }
    
    # PREPARE FEATURE COMPARISONS
    my $gene_translation;
    my %model2family;
    my %ftr2family;
    my $mc_families = {};
    my $core_families = 0;

    if (defined $protcomp) {
	my $i = 0;
	foreach my $ftr (@{$protcomp->{proteome1names}}) {
	    foreach my $hit (@{$protcomp->{data1}->[$i]}) {
		$gene_translation->{$ftr}->{$protcomp->{proteome2names}->[$hit->[0]]} = 1;
	    }
	    $i++;
	}
        $i = 0;
	foreach my $ftr (@{$protcomp->{proteome2names}}) {
	    foreach my $hit (@{$protcomp->{data2}->[$i]}) {
		$gene_translation->{$ftr}->{$protcomp->{proteome1names}->[$hit->[0]]} = 1;
	    }
	    $i++;
	}
    }
    if (defined $pangenome) {
	foreach my $family (@{$pangenome->{orthologs}}) {
	    my $in_models = {};
	    my $family_model_data = {};
	    foreach my $ortholog (@{$family->{orthologs}}) {
		$ftr2family{$ortholog->[0]} = $family;
		map { $gene_translation->{$ortholog->[0]}->{$_->[0]} = 1 } @{$family->{orthologs}};
		foreach my $model (@models) {
		    if (exists $ftr2model{$ortholog->[0]}->{$model->{id}}) {
			map { $in_models->{$model->{id}}->{$_} = 1 } keys $ftr2reactions{$ortholog->[0]};
			push @{$model2family{$model->{id}}->{$family->{id}}}, $ortholog->[0];
		    }
		}
	    }
	    my $num_models = scalar keys %$in_models;
	    if ($num_models > 0) {
		foreach my $model (@models) {
		    if (exists $in_models->{$model->{id}}) {
			my @reactions = sort keys %{$in_models->{$model->{id}}};
			$family_model_data->{$model->{id}} =  [1, \@reactions];
		    }
		    else {
			$family_model_data->{$model->{id}} = [0, []];
		    }
		}
		my $mc_family = {
		    id => $family->{id},
		    family_id => $family->{id},
		    function => $family->{function},
		    number_models => $num_models,
		    fraction_models => $num_models*1.0/@models,
		    core => ($num_models == @models ? 1 : 0),
		    family_model_data => $family_model_data
		};
		$mc_families->{$family->{id}} = $mc_family;
		$core_families++ if ($num_models == @models);
	    }
	}
    }

    # ACCUMULATE REACTIONS AND FAMILIES
    my %rxn2families;

    foreach my $model (@models) {
	foreach my $rxnid (keys %{$model->{rxnhash}}) {
	    foreach my $ftr (keys %{$model->{$rxnid}->{ftrhash}}) {
		$rxn2families{$rxnid}->{$ftr2family{$ftr}->{id}} = $ftr2family{$ftr};
	    }
	}
    }

    # READY TO COMPARE

    my $mc_models;
    my $mc_reactions;
    my $mc_compounds;
    my $mc_bcpds;

    foreach my $model1 (@models) {
	my $mc_model = {};
	push @{$mc_models}, $mc_model;
	$mc_model->{id} = $model1->{id};
	$mc_model->{model_ref} = $model1->{model_ref};
	$mc_model->{genome_ref} = $model1->{genome_ref};
	$mc_model->{families} = exists $model2family{$model1->{id}} ? scalar keys %{$model2family{$model1->{id}}} : 0;

	eval {
	    my $genome=$wsClient->get_objects([{ref=>$model1->{genome_ref}}])->[0]{data};
	    $mc_model->{name} = $genome->{scientific_name};
	    $mc_model->{taxonomy} = $genome->{taxonomy};
	};
	if ($@) {
	    warn "Error loading genome from workspace:\n".$@;
	}

	$mc_model->{reactions} = scalar @{$model1->{modelreactions}};
	$mc_model->{compounds} = scalar @{$model1->{modelcompounds}};
	$mc_model->{biomasses} = scalar @{$model1->{biomasses}};

	foreach my $model2 (@models) {
	    next if $model1->{id} eq $model2->{id};		    
	    $mc_model->{model_similarity}->{$model2->{id}} = [0,0,0,0,0];
	}

	foreach my $rxn (@{$model1->{modelreactions}}) {
	    my $ftrs = [];
	    if (defined $pangenome) {
		foreach my $ftr (keys %{$rxn->{ftrhash}}) {
		    my $family = $ftr2family{$ftr};
		    next if ! defined $family;
		    my $conservation = 0;
		    foreach my $m (keys %model2family) {
			$conservation++ if exists $model2family{$m}->{$family->{id}};
		    }
		    push @$ftrs, [$ftr, $family->{id}, $conservation*1.0/@models, 0];
		}
		# maybe families associated with reaction aren't in model
		foreach my $familyid (keys %{$rxn2families{$rxn->{id}}}) {
		    if (! exists $model2family{$model1->{id}}->{$familyid}) {
			my $conservation = 0;
			foreach my $m (keys %model2family) {
			    $conservation++ if exists $model2family{$m}->{$familyid};
			}
			push @$ftrs, ["", $familyid, $conservation*1.0/@models, 1];
		    }
		}
	    }
	    my $mc_reaction = $mc_reactions->{$rxn->{id}};
	    if (! defined $mc_reaction) {
		$mc_reaction = {
		    id => $rxn->{id},
		    reaction_ref => $rxn->{reaction_ref},
		    name => $rxn->{name},
		    equation => $rxn->{equation},
		    number_models => 1,
		    core => 0
		};
		$mc_reactions->{$mc_reaction->{id}} = $mc_reaction;
	    } else {
		$mc_reaction->{number_models}++;
	    }
	    $mc_reaction->{reaction_model_data}->{$model1->{id}} = [1,$rxn->{direction},$ftrs,$rxn->{dispfeatures}];
	    foreach my $model2 (@models) {
		next if $model1->{id} eq $model2->{id};

		my $model2_ftrs;
		if ($rxn->{rxnkbid} =~ "rxn00000" && defined $model2->{rxnhash}->{$rxn->{id}}) {
		    $mc_model->{model_similarity}->{$model2->{id}}->[0]++;
		    $model2_ftrs = $model2->{rxnhash}->{$rxn->{id}}->{ftrhash};
		}
		elsif (defined $model2->{rxnhash}->{$rxn->{rxnkbid}."_".$rxn->{cmpkbid}}) {
		    $mc_model->{model_similarity}->{$model2->{id}}->[0]++;
		    $model2_ftrs = $model2->{rxnhash}->{$rxn->{rxnkbid}."_".$rxn->{cmpkbid}}->{ftrhash};
		}

		my $gpr_matched = 0;
		if (scalar keys %{$rxn->{ftrhash}} > 0) {
		    $gpr_matched = 1;
		    foreach my $ftr (keys %{$rxn->{ftrhash}}) {
			my $found_a_match = 0;
			foreach my $gene (keys %{$gene_translation->{$ftr}}) {
			    if (exists $ftr2model{$gene}->{$model2->{id}}) {
				$found_a_match = 1;
				last;
			    }
			}
			$gpr_matched = 0 if ($found_a_match == 0);
		    }
		    if ($gpr_matched == 1) {
			foreach my $ftr (keys %{$model2_ftrs}) {
			    my $found_a_match = 0;
			    foreach my $gene (keys %{$gene_translation->{$ftr}}) {
				if (exists $ftr2model{$gene}->{$model1->{id}}) {
				    $found_a_match = 1;
				    last;
				}
			    }
			    $gpr_matched = 0 if ($found_a_match == 0);
			}
		    }
		}
		if ($gpr_matched == 1) {
		    $mc_model->{model_similarity}->{$model2->{id}}->[4]++;
		}
	    }
	}
	# fill in info for reactions not in model
	foreach my $rxnid (keys %rxn2families) {
	    if (! exists $model1->{rxnhash}->{$rxnid}) {
		my $ftrs = [];
		if (defined $pangenome) {
		    foreach my $familyid (keys %{$rxn2families{$rxnid}}) {
			my $conservation = 0;
			foreach my $m (keys %model2family) {
			    $conservation++ if exists $model2family{$m}->{$familyid};
			}
			if (exists $model2family{$model1->{id}}->{$familyid}) {
			    foreach my $ftr (@{$model2family{$model1->{id}}->{$familyid}}) {
				push @$ftrs, [$ftr, $familyid, $conservation*1.0/@models, 0];
			    }
			}
			else {
			    push @$ftrs, ["", $familyid, $conservation*1.0/@models, 1];
			}
		    }
		}
		$mc_reactions->{$rxnid}->{reaction_model_data}->{$model1->{id}} = [1,"",$ftrs,""];
	    }
	}
	# process compounds
	my %cpds_registered; # keep track of which compounds are accounted for since they might appear in multiple compartments
	foreach my $cpd (@{$model1->{modelcompounds}}) {
	    my $match_id = $cpd->{cpdkbid};
	    if ($match_id =~ "cpd00000") {
		$match_id = $cpd->{id};
		$match_id =~ s/_[a-zA-z]\d+$//g;
	    }
	    my $mc_compound = $mc_compounds->{$match_id};
	    if (! defined $mc_compound) {
		$mc_compound = {
		    id => $match_id,
		    compound_ref => $cpd->{compound_ref},
		    name => $cpd->{name},
		    number_models => 0,
		    core => 0,
		    model_compound_compartments => { $model1->{id} => [[$cpd->{modelcompartment_ref},$cpd->{charge}]] }
		};
		$mc_compounds->{$mc_compound->{id}} = $mc_compound;
	    } else {
		push @{$mc_compound->{model_compound_compartments}->{$model1->{id}}}, [$cpd->{modelcompartment_ref},$cpd->{charge}];
	    }
	    if (! exists $cpds_registered{$match_id}) {
		$mc_compound->{number_models}++;
		$cpds_registered{$match_id} = 1;
	    }
	    foreach my $model2 (@models) {
		next if $model1->{id} eq $model2->{id};

		if (($cpd->{cpdkbid} =~ "cpd00000" && defined $model2->{cpdhash}->{$cpd->{id}}) ||
		    (defined $model2->{cpdhash}->{$cpd->{cpdkbid}."_".$cpd->{cmpkbid}})) {
		    $mc_model->{model_similarity}->{$model2->{id}}->[1]++;
		}
	    }
	}
	my %model1bcpds;
	foreach my $biomass (@{$model1->{biomasses}}) {
	    foreach my $bcpd (@{$biomass->{biomasscompounds}}) {
		my $cpdkbid = pop @{[split "/", $bcpd->{modelcompound_ref}]};
		my $cpd = $model1->{cpdhash}->{$cpdkbid};
		my $match_id = $cpd->{cpdkbid};
		if (! defined $match_id || $match_id =~ "cpd00000") {
		    $match_id = $cpd->{id};
		    $match_id =~ s/_[a-zA-z]\d+$//g;
		}
		if (! defined $match_id) {
		    print STDERR "no match possible for biomass compound:\n";
		    print STDERR Dumper($bcpd);
		    next;
		}
		$model1bcpds{$match_id} = 0;
		my $mc_bcpd = $mc_bcpds->{$match_id};
		my $cref = defined $cpd->{modelcompartment_ref} ? $cpd->{modelcompartment_ref} : "";
		if (! defined $mc_bcpd) {
		    $mc_bcpd = {
			id => $match_id,
			compound_ref => defined $cpd->{compound_ref} ? $cpd->{compound_ref} : "",
			name => $cpd->{name},
			number_models => 1,
			core => 0,
			model_biomass_compounds => { $model1->{id} => [[$cref,$bcpd->{coefficient}]] }
		    };
		    $mc_bcpds->{$mc_bcpd->{id}} = $mc_bcpd;
		} else {
		    $mc_bcpd->{number_models}++;
		    push @{$mc_bcpd->{model_biomass_compounds}->{$model1->{id}}}, [$cref,$bcpd->{coefficient}];
		}
		foreach my $model2 (@models) {
		    next if $model1->{id} eq $model2->{id};

		    if (($cpd->{cpdkbid} =~ "cpd00000" && defined $model2->{cpdhash}->{$cpd->{id}}) ||
			(defined $model2->{cpdhash}->{$cpd->{cpdkbid}."_".$cpd->{cmpkbid}})) {
			$mc_model->{model_similarity}->{$model2->{id}}->[2]++;
		    }
		}
	    }
	}
	$mc_model->{biomasscpds} = scalar keys %model1bcpds;

	foreach my $family (keys %{$model2family{$model1->{id}}}) {
	    foreach my $model2 (@models) {
		next if $model1->{id} eq $model2->{id};

		if (exists $model2family{$model2->{id}}->{$family}) {
		    $mc_model->{model_similarity}->{$model2->{id}}->[3]++;
		}
	    }
	}
    }

    # need to set 'core' and 'fraction_models'
    my $core_reactions = 0;
    foreach my $mc_reaction (values %$mc_reactions) {
	if ($mc_reaction->{number_models} == @models) {
	    $core_reactions++;
	    $mc_reaction->{core} = 1;
	}
	$mc_reaction->{fraction_models} = 1.0*$mc_reaction->{number_models}/@models;
    }

    my $core_compounds = 0;
    foreach my $mc_compound (values %$mc_compounds) {
	if ($mc_compound->{number_models} == @models) {
	    $core_compounds++;
	    $mc_compound->{core} = 1;
	}
	$mc_compound->{fraction_models} = 1.0*$mc_compound->{number_models}/@models;
    }

    my $core_bcpds = 0;
    foreach my $mc_bcpd (values %$mc_bcpds) {
	if ($mc_bcpd->{number_models} == @models) {
	    $core_bcpds++;
	    $mc_bcpd->{core} = 1;
	}
	$mc_bcpd->{fraction_models} = 1.0*$mc_bcpd->{number_models}/@models;
    }

    my $mc = {};
    $mc->{id} = $mc_name;
    $mc->{name} = $mc_name;
    $mc->{models} = $mc_models;
    $mc->{reactions} = [values %$mc_reactions];
    $mc->{core_reactions} = $core_reactions;
    $mc->{compounds} = [values %$mc_compounds];
    $mc->{core_compounds} = $core_compounds;
    $mc->{biomasscpds} = [values %$mc_bcpds];
    $mc->{core_biomass_compounds} = $core_bcpds;
    $mc->{core_families} = $core_families;
    $mc->{families} = [values %$mc_families];
    $mc->{protcomp_ref} = $protcomp_ref if (defined $protcomp_ref);
    $mc->{pangenome_ref} = $pangenome_ref if (defined $pangenome_ref);

    my $mc_metadata = $wsClient->save_objects({
	'workspace' => $workspace_name,
	'objects' => [{
	    type => 'KBaseFBA.ModelComparison',
	    name => $mc_name,
	    data => $mc,
	    'provenance' => $provenance
		      }]});

    my $report = "ModelComparison saved to $workspace_name/$mc_name\n";
    my $reportObj = { "objects_created"=>[{'ref'=>"$workspace_name/$mc_name", "description"=>"Model Comparison"}],
		      "text_message"=>$report };
    my $reportName = "model_comparison_report_${mc_name}";

    my $metadata = $wsClient->save_objects({
	'id' => $mc_metadata->[0]->[6],
	'objects' => [{
	    type => 'KBaseReport.Report',
	    data => $reportObj,
	    name => $reportName,
	    'meta' => {},
	    'hidden' => 1,
	    'provenance' => $provenance
		      }]});

    $return = { 'report_name'=>$reportName, 'report_ref', $metadata->[0]->[6]."/".$metadata->[0]->[0]."/".$metadata->[0]->[4], 'mc_ref' => $workspace_name."/".$mc_name};

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



=head2 ModelComparisonResult

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a string
report_ref has a value which is a string
mc_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a string
report_ref has a value which is a string
mc_ref has a value which is a string


=end text

=back



=cut

1;
