// MIT License
//
// Copyright (c) 2019 UK Parliament
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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