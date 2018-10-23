namespace OntologyTests
{
    using VDS.RDF;
    using VDS.RDF.Ontology;

    public class OntologyRestriction : OntologyResource
    {
        protected internal OntologyRestriction(INode resource) : base(resource, resource.Graph) { }
    }
}