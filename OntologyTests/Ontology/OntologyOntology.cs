namespace OntologyTests
{
    using VDS.RDF;
    using VDS.RDF.Ontology;

    public class OntologyOntology : OntologyResource
    {
        protected internal OntologyOntology(INode resource) : base(resource, resource.Graph) { }
    }
}
