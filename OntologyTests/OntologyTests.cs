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
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text.RegularExpressions;
    using VDS.RDF;
    using VDS.RDF.Ontology;
    using VDS.RDF.Parsing;
    using VDS.RDF.Parsing.Handlers;

    [TestClass]
    public class OntologyTests
    {
        private const string OntologyFile = "Ontology.ttl";
        private const string OntologyUri = "https://id.parliament.uk/schema";
        private const string BaseUri = "https://id.parliament.uk/schema/";

        private static IEnumerable<object[]> AllResources
        {
            get
            {
                return OntologyResources.Union(Ontologies);
            }
        }

        private static IEnumerable<object[]> OntologyResources
        {
            get
            {
                return Classes.Union(Properties).Union(Restrictions);
            }
        }

        private static IEnumerable<object[]> Properties
        {
            get
            {
                var ontologyGraph = new OntologyGraph();
                ontologyGraph.LoadFromFile(OntologyFile);

                return ontologyGraph.AllProperties.Select(p => new[] { p });
            }
        }

        private static IEnumerable<object[]> Classes
        {
            get
            {
                var ontologyGraph = new OntologyGraph();
                ontologyGraph.LoadFromFile(OntologyFile);

                return ontologyGraph.AllClasses.Select(c => new[] { c });
            }
        }

        private static IEnumerable<object[]> Restrictions
        {
            get
            {
                var ontologyGraph = new OntologyGraph();
                ontologyGraph.LoadFromFile(OntologyFile);

                return ontologyGraph.Restrictions.Select(r => new[] { r });
            }
        }

        private static IEnumerable<object[]> Ontologies
        {
            get
            {
                var ontologyGraph = new OntologyGraph();
                ontologyGraph.LoadFromFile(OntologyFile);

                return ontologyGraph.Ontologies.Select(r => new[] { r });
            }
        }

        private static IEnumerable<object[]> NamespaceResources
        {
            get
            {
                var ontologyGraph = new Graph();
                ontologyGraph.LoadFromFile(OntologyFile);

                return ontologyGraph
                    .Nodes
                    .UriNodes()
                    .Where(node => new Uri(BaseUri).IsBaseOf(node.Uri))
                    .Select(node => new[] { node });
            }
        }

        [TestMethod]
        public void Is_valid_turtle_file()
        {
            new TurtleParser().Load(new NullHandler(), OntologyFile);
        }

        [TestMethod]
        [DynamicData(nameof(Ontologies))]
        public void Ontology_has_correct_uri(OntologyResource ontology)
        {
            Assert.AreEqual(OntologyUri, ((IUriNode)ontology.Resource).Uri.AbsoluteUri);
        }

        [TestMethod]
        public void Only_one_ontology()
        {
            Assert.AreEqual(1, Ontologies.Count());
        }

        [TestMethod]
        [DynamicData(nameof(AllResources))]
        public void Resource_is_defined_by_ontology(OntologyResource ontologyResource)
        {
            var theOntology = new NodeFactory().CreateUriNode(new Uri(OntologyUri));

            var definingResource = ontologyResource.IsDefinedBy;

            Assert.AreEqual(1, definingResource.Count(), "Ontology resources must be defined by exactly one ontology.");
            Assert.AreEqual(theOntology, definingResource.Single(), "Ontology resources must be defined by the correct ontology.");
        }

        [TestMethod]
        [DynamicData(nameof(NamespaceResources))]
        public void Resource_is_explicitly_typed(IUriNode node)
        {
            var typeStatements = node
                .Graph
                .GetTriplesWithSubjectPredicate(
                    node,
                    node.Graph.CreateUriNode(new Uri(RdfSpecsHelper.RdfType)));

            Assert.IsTrue(typeStatements.Any(), "Resources must be explicitely typed.");
        }

        [TestMethod]
        [DynamicData(nameof(OntologyResources))]
        public void Resource_is_from_namespace(OntologyResource ontologyResource)
        {
            Assert.IsTrue(new Uri(BaseUri).IsBaseOf((ontologyResource.Resource as IUriNode).Uri));
        }

        [TestMethod]
        [DynamicData(nameof(Properties))]
        public void Properties_have_one_domain_one_range(OntologyProperty property)
        {
            Assert.AreEqual(1, property.Domains.Count(), "Properties must have exactly one domain.");
            Assert.AreEqual(1, property.Ranges.Count(), "Properties must have exactly one range.");
        }

        [TestMethod]
        [DynamicData(nameof(Properties))]
        public void Properties_are_camel_cased(OntologyProperty property)
        {
            var localName = new Uri(BaseUri).MakeRelativeUri((property.Resource as IUriNode).Uri).ToString();

            StringAssert.Matches(localName, new Regex(@"^[a-z]([a-z]|[A-Z]|[0-9])*$"), "Properties must be camelCased.");

        }

        [TestMethod]
        [DynamicData(nameof(Classes))]
        public void Classes_are_pascal_cased(OntologyClass @class)
        {
            var localName = new Uri(BaseUri).MakeRelativeUri((@class.Resource as IUriNode).Uri).ToString();

            StringAssert.Matches(localName, new Regex(@"^[A-Z]([a-z]|[A-Z]|[0-9])*$"), "Classes must be PascalCased.");
        }

        [TestMethod]
        [DynamicData(nameof(AllResources))]
        public void Resource_has_label(OntologyResource ontologyResource)
        {
            var theOntology = new NodeFactory().CreateUriNode(new Uri(OntologyUri));

            var labels = ontologyResource.Label;

            Assert.AreEqual(1, labels.Count(), "Ontology resources must have exactly one label.");
            Assert.IsTrue(labels.All(l => !string.IsNullOrEmpty(l.Value)), "Ontology resource labels must not be empty.");
        }
    }
}