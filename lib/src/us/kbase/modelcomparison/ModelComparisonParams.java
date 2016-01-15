
package us.kbase.modelcomparison;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: ModelComparisonParams</p>
 * <pre>
 * ModelComparisonParams object: a list of models and optional pangenome and protein comparison
 * @optional protcomp_ref pangenome_ref
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "models",
    "protcomp_ref",
    "pangenome_ref"
})
public class ModelComparisonParams {

    @JsonProperty("models")
    private List<String> models;
    @JsonProperty("protcomp_ref")
    private java.lang.String protcompRef;
    @JsonProperty("pangenome_ref")
    private java.lang.String pangenomeRef;
    private Map<java.lang.String, Object> additionalProperties = new HashMap<java.lang.String, Object>();

    @JsonProperty("models")
    public List<String> getModels() {
        return models;
    }

    @JsonProperty("models")
    public void setModels(List<String> models) {
        this.models = models;
    }

    public ModelComparisonParams withModels(List<String> models) {
        this.models = models;
        return this;
    }

    @JsonProperty("protcomp_ref")
    public java.lang.String getProtcompRef() {
        return protcompRef;
    }

    @JsonProperty("protcomp_ref")
    public void setProtcompRef(java.lang.String protcompRef) {
        this.protcompRef = protcompRef;
    }

    public ModelComparisonParams withProtcompRef(java.lang.String protcompRef) {
        this.protcompRef = protcompRef;
        return this;
    }

    @JsonProperty("pangenome_ref")
    public java.lang.String getPangenomeRef() {
        return pangenomeRef;
    }

    @JsonProperty("pangenome_ref")
    public void setPangenomeRef(java.lang.String pangenomeRef) {
        this.pangenomeRef = pangenomeRef;
    }

    public ModelComparisonParams withPangenomeRef(java.lang.String pangenomeRef) {
        this.pangenomeRef = pangenomeRef;
        return this;
    }

    @JsonAnyGetter
    public Map<java.lang.String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(java.lang.String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public java.lang.String toString() {
        return ((((((((("ModelComparisonParams"+" [models=")+ models)+", protcompRef=")+ protcompRef)+", pangenomeRef=")+ pangenomeRef)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
