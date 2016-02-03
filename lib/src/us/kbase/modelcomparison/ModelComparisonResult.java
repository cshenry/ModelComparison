
package us.kbase.modelcomparison;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: ModelComparisonResult</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "mc_ref"
})
public class ModelComparisonResult {

    @JsonProperty("mc_ref")
    private String mcRef;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("mc_ref")
    public String getMcRef() {
        return mcRef;
    }

    @JsonProperty("mc_ref")
    public void setMcRef(String mcRef) {
        this.mcRef = mcRef;
    }

    public ModelComparisonResult withMcRef(String mcRef) {
        this.mcRef = mcRef;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((("ModelComparisonResult"+" [mcRef=")+ mcRef)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
