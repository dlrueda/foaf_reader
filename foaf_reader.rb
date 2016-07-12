require 'rdf'
require 'linkeddata'


def abstract_for(interest)
  tmp_query = "PREFIX foaf: <http://xmlns.com/foaf/0.1/>
    PREFIX dbo: <http://dbpedia.org/ontology/>
    SELECT ?abs
      WHERE { ?s dbo:abstract ?abs
        FILTER (lang(?abs) = 'en')}"

  tmp_graph = RDF::Graph.load(interest)
  sse_abstracts = SPARQL.parse(tmp_query)
  sse_abstracts.execute(tmp_graph) do |res|
    puts res.abs
  end
end



# 1. Load my own FOAF file
#graph = RDF::Graph.load("foaf_files/foaf.rdf")
graph = RDF::Graph.load("http://www.stanford.edu/~dlrueda/foaf.rdf")
puts graph.inspect

# 2. Find everyone I know

query = "
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT DISTINCT ?o
  WHERE { ?s foaf:knows ?o }
"

# 3. Load all of their FOAF files into the same graph as mine

puts "before loading"
sse = SPARQL.parse(query)
sse.execute(graph) do |result|
  puts result.o
  #explicitly cast the result as an RDF resource
  #triples = RDF::Resource(RDF::URI.new(result.o))
  #graph.load(triples)
  #add to your graph
  graph.load(result.o)
end

puts "after loading"
sse.execute(graph) do |result|
  puts result.o
end

# query for interests
puts "Querying interests"
interests_query = "
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?interest
  WHERE { ?s foaf:interest ?interest }
"

q_interests = SPARQL.parse(interests_query)
q_interests.execute(graph) do |result|
  puts result.interest
  abstract_for(result.interest)
end

#abstract_for('http://dbpedia.org/resource/Quilting')

# puts "Interests"
# s = SPARQL.parse(interests_query)
# s.execute(graph) do |result|
#   puts result.interest
# end
#
# # 4. Write the new graph out to a file in turtle
# # file endings to try: rdf, ttl, nt
#
# RDF::Writer.open("output.ttl") do |writer|
#   graph.each_statement do |statement|
#     writer << statement
#   end
# end
#
# # Add and delete statements. Go through this tutorial: http://blog.datagraph.org/2010/03/rdf-for-ruby
#
# # 5. Remove all the "error reports to" statements
# # graph.delete([rdfrb, RDF::DC.creator, arto])
