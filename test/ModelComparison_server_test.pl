use strict;
use Data::Dumper;
use Test::More;
use Config::Simple;
use Time::HiRes qw(time);
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Bio::KBase::fbaModelServices::Client;
use ModelComparison::ModelComparisonImpl;

local $| = 1;
my $token = $ENV{'KB_AUTH_TOKEN'};
my $config_file = $ENV{'KB_DEPLOYMENT_CONFIG'};
my $config = new Config::Simple($config_file)->get_block('ModelComparison');
my $ws_url = $config->{"workspace-url"};
my $ws_name = undef;
my $ws_client = new Bio::KBase::workspace::Client($ws_url,token => $token);
my $fba_url = $config->{"fba-url"};
my $fba_client = new Bio::KBase::fbaModelServices::Client($fba_url,token => $token);
my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1);
my $ctx = LocalCallContext->new($token, $auth_token->user_id);
$ModelComparison::ModelComparisonServer::CallContext = $ctx;
my $impl = new ModelComparison::ModelComparisonImpl();

sub get_ws_name {
    if (!defined($ws_name)) {
        my $suffix = int(time * 1000);
        $ws_name = 'test_ModelComparison_' . $suffix;
        $ws_client->create_workspace({workspace => $ws_name});
    }
    return $ws_name;
}

eval {
    my $obj_name = "testmodel.1";
    open(SBML,"testmodel.xml");
    my @sbml = <SBML>;
    close(SBML);
    chomp @sbml;
    my $sbml = join "", @sbml;
    $fba_client->import_fbamodel({'workspace'=>get_ws_name(), 'genome'=>'Rhodobacter_sphaeroides_2.4.1', 'genome_workspace'=>'KBaseExampleData', 'model'=>$obj_name, 'biomass'=>'biomass0', 'sbml'=>$sbml});
    my $models = [get_ws_name()."/".$obj_name];
    $obj_name = "testmodel.2";
    open(SBML,"testmodel2.xml");
    @sbml = <SBML>;
    close(SBML);
    chomp @sbml;
    $sbml = join "", @sbml;
    $fba_client->import_fbamodel({'workspace'=>get_ws_name(), 'genome'=>'Rhodobacter_sphaeroides_2.4.1', 'genome_workspace'=>'KBaseExampleData', 'model'=>$obj_name, 'biomass'=>'biomass0', 'sbml'=>$sbml});
    push @$models, get_ws_name()."/".$obj_name;
    $obj_name = "protcomp.1";
    my $protcomp = {
	id => 1,
	genome1ref => 'KBaseExampleData/Rhodobacter_sphaeroides_2.4.1',
	genome2ref => 'KBaseExampleData/Rhodobacter_sphaeroides_2.4.1',
	proteome1names => ['RSP_0723','RSP_1012','RSP_4032'],
	proteome2names => ['RSP_0723','RSP_1012','RSP_4032'],
	proteome1map => {},
	proteome2map => {},
	data1 => [[[0,0,0]],[[1,1,1]],[[2,2,2]]],
	data2 => [[[0,0,0]],[[1,1,1]],[[2,2,2]]],
	sub_bbh_percent => 0,
	max_evalue => "0"
    };
    $ws_client->save_objects({
	'workspace' => get_ws_name(),
	'objects' => [{
	    type => 'GenomeComparison.ProteomeComparison',
	    name => $obj_name,
	    data => $protcomp
		      }]
			    });
    $@ = '';
    my $return;
    eval { 
	print "Ready to compare_models with proteome comparison\n";
        $return = $impl->compare_models({model_refs=>$models, 'workspace'=>get_ws_name(), 'protcomp_ref'=>get_ws_name()."/".$obj_name, 'mc_name'=>"mc.1"});
    };
    if ($@) {
	print "Error during compare_models:\n".$@."\n";
    }
    my $mc1;
    eval {
	$mc1=$ws_client->get_objects([{ref=>get_ws_name()."/"."mc.1"}])->[0]{data};
    };
    if ($@) {
	warn "Error loading mc1 from workspace:\n".$@;
    }

    my $m1m2sim = $mc1->{models}->[0]->{model_similarity}->{'testmodel.2'};
    ok($m1m2sim->[0] == 7 && $m1m2sim->[1] == 12 && $m1m2sim->[2] == 4 && $m1m2sim->[3] == 0 && $m1m2sim->[4] == 2, "model similarity with proteome OK");

    $obj_name = "pangenome.1";
    my $pangenome = {
	id => "pg1",
	name => $obj_name,
	type => "type",
	genome_refs => ['KBaseExampleData/Rhodobacter_sphaeroides_2.4.1','KBaseExampleData/Rhodobacter_sphaeroides_2.4.1'],
	orthologs => [{
	    id => "fam1",
	    type => "type",
	    function => "function",
	    md5 => "md5",
	    protein_translation => "pt",
	    orthologs => [['RSP_0723', 0, "s"],['RSP_0723', 0, "s"]]}]
    };
    $ws_client->save_objects({
	'workspace' => get_ws_name(),
	'objects' => [{
	    type => 'KBaseGenomes.Pangenome',
	    name => $obj_name,
	    data => $pangenome
		      }]
			    });
    $@ = '';
    eval { 
	print "Ready to compare_models with pangenome comparison\n";
        $return = $impl->compare_models({model_refs=>$models, 'workspace'=>get_ws_name(), 'pangenome_ref'=>get_ws_name()."/".$obj_name, 'mc_name'=>"mc.2"});
    };
    if ($@) {
	print "Error during compare_models:\n".$@."\n";
    }

    my $mc2;
    eval {
	$mc2=$ws_client->get_objects([{ref=>get_ws_name()."/"."mc.2"}])->[0]{data};
    };
    if ($@) {
	warn "Error loading mc1 from workspace:\n".$@;
    }
    $m1m2sim = $mc2->{models}->[0]->{model_similarity}->{'testmodel.2'};
    ok($m1m2sim->[0] == 7 && $m1m2sim->[1] == 12 && $m1m2sim->[2] == 4 && $m1m2sim->[3] == 1 && $m1m2sim->[4] == 1, "model similarity with pangenome OK");
    done_testing(2);
};
my $err = undef;
if ($@) {
    $err = $@;
}
eval {
    if (defined($ws_name)) {
        $ws_client->delete_workspace({workspace => $ws_name});
        print("Test workspace was deleted\n");
    }
};
if (defined($err)) {
    if(ref($err) eq "Bio::KBase::Exceptions::KBaseException") {
        die("Error while running tests: " . $err->trace->as_string);
    } else {
        die $err;
    }
}

{
    package LocalCallContext;
    use strict;
    sub new {
        my($class,$token,$user) = @_;
        my $self = {
            token => $token,
            user_id => $user
        };
        return bless $self, $class;
    }
    sub user_id {
        my($self) = @_;
        return $self->{user_id};
    }
    sub token {
        my($self) = @_;
        return $self->{token};
    }
    sub provenance {
        my($self) = @_;
        return [{'service' => 'ModelComparison', 'method' => 'please_never_use_it_in_production', 'method_params' => []}];
    }
    sub authenticated {
        return 1;
    }
    sub log_debug {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
    sub log_info {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
}
