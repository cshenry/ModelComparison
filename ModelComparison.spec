/*
A KBase module: ModelComparison
*/

module ModelComparison {
    typedef int bool;

    /*
    Reaction ID
    @id external
    */
    typedef string reaction_id;

    /*
    Genome feature ID
    @id external
    */
    typedef string Feature_id;

    /*
    Feature family ID
    @id external
    */
    typedef string Family_id;

    /*
    Reference to metabolic model
    @id ws KBaseFBA.FBAModel
    */
    typedef string Model_ref;

    /*
    Reference to KBase genome
    @id ws KBaseGenomes.Genome
    */
    typedef string Genome_ref;

    /*
    Reference to a Pangenome object in the workspace
    @id ws KBaseGenomes.Pangenome
    */
    typedef string Pangenome_ref;

    /*
    Reference to a Proteome Comparison object in the workspace
    @id ws GenomeComparison.ProteomeComparison
    */
    typedef string Protcomp_ref;

    /*
    Reference to a reaction object in a biochemistry
    @id subws KBaseBiochem.Biochemistry.reactions.[*].id
    */
    typedef string Reaction_ref;

    /*
    Reference to a compound object
    @id subws KBaseBiochem.Biochemistry.compounds.[*].id
    */
    typedef string Compound_ref;

    /*
    Reference to a compartment object
    @id subws KBaseBiochem.Biochemistry.compartments.[*].id
    */
    typedef string Compartment_ref;

    /*
    ModelComparisonModel object: this object holds information about a model in a model comparison
    */
    typedef structure {
	string id;
	Model_ref model_ref;
	Genome_ref genome_ref;
	mapping<string model_id,tuple<int common_reactions,int common_compounds,int common_biomasscpds,int common_families,int common_gpr> > model_similarity; 
	string name;
	string taxonomy;
	int reactions;
	int families;
	int compounds;
	int biomasscpds;
	int biomasses;
    } ModelComparisonModel;
    
    /*
    ModelComparisonFamily object: this object holds information about a protein family across a set of models
    */
    typedef structure {
	string id;
	Family_id family_id;
	string function;
	int number_models;
	float fraction_models;
	bool core;
	mapping<string model_id,tuple<bool present,list<reaction_id>>> family_model_data;
    } ModelComparisonFamily;

    /*
    ModelComparisonReaction object: this object holds information about a reaction across all compared models
    */
    typedef structure {
	string id;
	Reaction_ref reaction_ref;
	string name;
	string equation;
	int number_models;
	float fraction_models;
	bool core;
	mapping<string model_id,tuple<bool present,string direction,list<tuple<Feature_id,Family_id,float conservation,bool missing>>,string gpr>> reaction_model_data;
    } ModelComparisonReaction;
    
    /*
    ModelComparisonCompound object: this object holds information about a compound across a set of models
    */
    typedef structure {
	string id;
	Compound_ref compound_ref;
	string name;
	int number_models;
	float fraction_models;
	bool core;
	mapping<string model_id,list<tuple<Compartment_ref,float charge>>> model_compound_compartments;
    } ModelComparisonCompound;
    
    /*
    ModelComparisonBiomassCompound object: this object holds information about a biomass compound across a set of models
    */
    typedef structure {
	string id;
	Compound_ref compound_ref;
	string name;
	int number_models;
	float fraction_models;
	bool core;
	mapping<string model_id,list<tuple<Compartment_ref,float coefficient>>> model_biomass_compounds;
    } ModelComparisonBiomassCompound;
    
    /*
    ModelComparisonParams object: a list of models and optional pangenome and protein comparison; mc_name is the name for the new object.

    @optional protcomp_ref pangenome_ref
    */
    typedef structure {
	string workspace;
	string mc_name;
	list<Model_ref> model_refs;
	Protcomp_ref protcomp_ref;
	Pangenome_ref pangenome_ref;
    } ModelComparisonParams;

    /*
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
    */
    typedef structure {
	string id;
	string name;
	int core_reactions;
	int core_compounds;
	int core_families;
	int core_biomass_compounds;
	Protcomp_ref protcomp_ref;
	Pangenome_ref pangenome_ref;

	list<ModelComparisonModel> models;
	list<ModelComparisonReaction> reactions;
	list<ModelComparisonCompound> compounds;
	list<ModelComparisonFamily> families;
	list<ModelComparisonBiomassCompound> biomasscpds;
    } ModelComparison;
    
    typedef tuple<string id,string type,string moddate,int instance,string command,string lastmodifier,string owner,string workspace,string workspace_ref,string chsum,mapping<string,string> metadata> object_metadata;

    /*
    Compare models
    */
    funcdef compare_models(ModelComparisonParams params) returns (object_metadata) authentication required;
};