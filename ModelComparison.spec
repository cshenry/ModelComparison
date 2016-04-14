/*
A KBase module: ModelComparison
*/

module ModelComparison {
    /*
    Reference to metabolic model
    @id ws KBaseFBA.FBAModel
    */
    typedef string Model_ref;

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
    
    typedef structure {
	string report_name;
	string report_ref;
	string mc_ref;
    } ModelComparisonResult;

    /*
    Compare models
    */
    funcdef compare_models(ModelComparisonParams params) returns (ModelComparisonResult) authentication required;
};