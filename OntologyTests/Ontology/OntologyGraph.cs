namespace OntologyTests
{
    using System.Collections.Generic;
    using System.Linq;
    using dnr = VDS.RDF.Ontology;

    internal class OntologyGraph : dnr.OntologyGraph
    {
        public IEnumerable<OntologyRestriction> Restrictions
        {
            get
            {
                var rdf_type = this.CreateUriNode("rdf:type");
                var owl_Restriction = this.CreateUriNode("owl:Restriction");

                return this.GetTriplesWithPredicateObject(rdf_type, owl_Restriction).Select(t => new OntologyRestriction(t.Subject));
            }
        }

        public IEnumerable<OntologyOntology> Ontologies
        {
            get
            {
                var rdf_type = this.CreateUriNode("rdf:type");
                var owl_Restriction = this.CreateUriNode("owl:Ontology");

                return this.GetTriplesWithPredicateObject(rdf_type, owl_Restriction).Select(t => new OntologyOntology(t.Subject));
            }
        }
    }
}