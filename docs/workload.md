# Implementing Views for Property Graph Transformations

This document describes the graph datasets, as well as the view and query workloads used in the experiment.

## Graph Datasets
Our experiment includes five graph datasets from a variety of domains. Refer to [this page](../experiment/README.md) to download and prepare the dataset required for experiment.

| Abbreviation  | Name        | Type  | \|N\| | \|E\| |
| ------------- |-------------| ----- | ----- | ----- |
| LSQB | Labelled Subgraph Query Benchmark | Syntactic (social) | 3.96M | 22.20M |
| OAG | Open Aacademic Graph | Citation | 18.62M | 22.93M | 
| PROV | Wikipedia Edits | Provenance | 5.15M | 2.65M | 
| SOC | Twitter | Social | 713K | 405K | 
| WORD | WordNet | Knowledge | 823K | 472K | 

## Workload Description
View definitions contain:
* Standard Views (GQL/G-CORE)
* Transformation views with default rules
  * Create new nodes or edges / delete
  * Mapping variables (of nodes/edges) to a node or edge
  
Queries contain:
* Retrieve a node or edge pattern or a graph pattern
* project tuples using the WHERE clause over properties




## LSQB
### Description of Dataset
* Description: A benchmark for subgraph matching.
* Source: [LSQB](https://github.com/ldbc/lsqb)

#### Preprocessing

#### Schema
* Refer to the LSQB paper [[Link]](https://dl.acm.org/doi/pdf/10.1145/3461837.3464516).

### View definition
```
CREATE VIEW v1 ON g (
  MATCH
    (person1:Person)-[e1:KNOWS]->(person2:Person), 
    (comment:Comment)-[e3:HASCREATOR]->(person1:Person), 
    (comment:Comment)-[e4:REPLYOF]->(post:Post),
    (post:Post)-[e5:HASCREATOR]->(person2:Person)
  WHERE person1 <= 1159400
  CONSTRUCT
    (person1:Person)-[e1:KNOWS]->(person2:Person), 
    (comment:Comment)-[e3:HASCREATOR]->(person1:Person), 
    (comment:Comment)-[e4:REPLYOF]->(post:Post),
    (post:Post)-[e5:HASCREATOR]->(person2:Person)

CREATE VIEW v2 ON g (
  MATCH
    (person1:Person)-[e1:ISLOCATEDIN]->(city1:City),
    (city1:City)-[e2:ISPARTOF]->(country:Country),
    (person2:Person)-[e3:ISLOCATEDIN]->(city2:City),
    (city2:City)-[e4:ISPARTOF]->(country:Country),
    (person3:Person)-[e5:ISLOCATEDIN]->(city3:City),
    (city3:City)-[e6:ISPARTOF]->(country:Country),
    (person1:Person)-[e7:KNOWS]->(person2:Person),
    (person2:Person)-[e9:KNOWS]->(person3:Person)
    WHERE person1 >= 1159373 AND person1 <= 1159400
  CONSTRUCT
    (person1:Person)-[e1:ISLOCATEDIN]->(city1:City),
    (city1:City)-[e2:ISPARTOF]->(country:Country),
    (person2:Person)-[e3:ISLOCATEDIN]->(city2:City),
    (city2:City)-[e4:ISPARTOF]->(country:Country),
    (person3:Person)-[e5:ISLOCATEDIN]->(city3:City),
    (city3:City)-[e6:ISPARTOF]->(country:Country),
    (person1:Person)-[e7:KNOWS]->(person2:Person),
    (person2:Person)-[e9:KNOWS]->(person3:Person)
)      
```          


### Query Workload
```
MATCH 
  (person1:Person)-[e1:KNOWS]->(person2:Person), 
  (comment:Comment)-[e3:HASCREATOR]->(person1:Person), 
  (comment:Comment)-[e4:REPLYOF]->(post:Post),
  (post:Post)-[e5:HASCREATOR]->(person2:Person)
FROM v1 
WHERE person1 >= 1159373 AND person1 <= 1159400
RETURN (person1)

MATCH 
  (person1:Person)-[e1:ISLOCATEDIN]->(city1:City),
  (city1:City)-[e2:ISPARTOF]->(country:Country),
  (person2:Person)-[e3:ISLOCATEDIN]->(city2:City),
  (city2:City)-[e4:ISPARTOF]->(country:Country),
  (person3:Person)-[e5:ISLOCATEDIN]->(city3:City),
  (city3:City)-[e6:ISPARTOF]->(country:Country),
  (person1:Person)-[e7:KNOWS]->(person2:Person),
  (person2:Person)-[e9:KNOWS]->(person3:Person)
FROM v2 
WHERE person1 >= 1159373 AND person1 <= 1159380
RETURN (person1)
```

## OAG
### Description of Dataset
* Description: Open Academic Graph (OAG) is a large knowledge graph unifying two graphs: Microsoft Academic Graph (MAG) and AMiner.
* Source: [Open Academic Graph](https://www.microsoft.com/en-us/research/project/open-academic-graph/)
#### Preprocessing
* Select the papers published in 2016 only.
#### Schema
```
Node labels
 (:AA) : AMiner Author
 (:AP) : AMiner Paper
 (:AV) : AMiner Venue
 (:MA) : MAG Author
 (:MP) : MAG Paper
 (:MV) : MAG Venue
 (:OA) : OAG Author (not exist in the input graph)
 (:OP) : OAG Paper (not exist in the input graph)
 (:OV) : OAG Venue (not exist in the input graph)

Edge labels
 -[:W]-> : isWrittenBy
 -[:P]-> : isPublishedAt
 -[:L]-> : isLinkedTo

Constraints on Edge Connectivity
 (:AP)-[:W]->(:AA)
 (:AP)-[:P]->(:AV)
 (:MP)-[:W]->(:MA)
 (:MP)-[:P]->(:MV)
 (:OP)-[:W]->(:OA)
 (:OP)-[:P]->(:OV)
 (:AA)-[:L]->(:MA)
 (:AP)-[:L]->(:MP)
 (:AV)-[:L]->(:MV)
```            
### View definition
For every author connected between the two graph sets (AMiner and MAG), generate a new node.
```
CREATE VIEW v1 ON g WITH DEFAULT MAP (
  MATCH (p:P)-[e1:W]->(a:A), (p:P)-[e2:P]->(v:V)
  WHERE a > 2575 AND a < 2590
  CONSTRUCT (a:A)-[e3:PUBVEN]->(v:V)
  SET e3 = SK(\"kk1\", a, v)
      UNION
  MATCH (p:P)-[e1:W]->(a1:A), (p:P)-[e2:W]->(a2:A)
  WHERE a1 < 10 AND a2 < 7000 AND a1 != a2
  CONSTRUCT (a1:A)-[e3:COAUTHOR]->(a2:A)
  SET e3 = SK(\"kk2\", a1, a2)
)
```
### Query Workload
Retrieve a set of nodes that were newly created in the view.
```
MATCH (a:A)-[e3:PUBVEN]->(v:V) 
FROM v1 
WHERE a > 2580 AND a < 2587
RETURN (a)

MATCH (a:A)-[e3:PUBVEN]->(v:V) 
FROM v1 
WHERE a > 2580 AND a < 2588 
RETURN (a)
```



## PROV
### Description of Dataset
* Description: Talk namespace - edits of discussion pages attached to each Wikipedia article
* Source: [Complete Wikipedia edit history (up to January 2008)](https://snap.stanford.edu/data/wiki-meta.html) (File: enwiki-20080103.talk.bz2)
#### Preprocessing
* Transform the revision history into a provenance graph that follows the W3C PROV-DM standard.
#### Schema
```
Node labels
 (:R) : Activity - Revision
 (:U) : Agent - User
 (:E) : Entity

Edge labels
 -[:DERBY]-> : isDeriveFrom
 -[:USED]-> : used
 -[:GENBY]-> : isGeneratedBy

Constraints on Edge Connectivity
 (:R)-[:DERBY]->(:R)
 (:R)-[:USED]->(:E)
 (:R)-[:GENBY]->(:E)
```            

### View definition
```
CREATE VIEW prov1 ON g WITH DEFAULT MAP (
  MATCH (e2:E)-[d:DERBY]->(e1:E), !(e1:E)-[k2:DERBY]->(_:E)
  WHERE e1 < 30
  CONSTRUCT (a:REVISION)-[u:USED]->(e1:E), (e2:E)-[g:GENBY]->(a:REVISION)
  SET a = SK(\"rev\", d), u = SK(\"used\", d), g = SK(\"genby\", d)
      UNION
  MATCH (e2:E)-[d1:DERBY]->(e1:E), (e3:E)-[d2:DERBY]->(e2:E)
  WHERE e1 > 100 AND e1 < 130
  CONSTRUCT (e3:E)-[u:MULTIDERBY2]->(e1:E)
  SET u = SK(\"multi\", e1, e3)
)
```

### Query Workload
For a particular set of revision entities, retrieve nodes or edges that have an 'isAttributedTo' relationship originating from them
```
MATCH (a:REVISION)-[u:USED]->(e1:E), (e2:E)-[g:GENBY]->(a:REVISION)
  FROM prov1
  WHERE e1 < 501
  RETURN (a)

MATCH (e2:E)-[u:MULTIDERBY2]->(e1:E)
  FROM prov1
  WHERE e1 < 500
  RETURN (e1)
```



## SOC
### Description of Dataset
* Source: [TWITTER-FOLLOWS](https://networkrepository.com/soc-twitter-follows.php)
#### Preprocessing
#### Schema
```
Node labels
 (:U) : User

Edge labels
 -[:F]-> : isFriendOf

Constraints on Edge Connectivity
 (:U)-[:F]->(:U)
```
### View definition
For a selected group of users, create edges that represent two and three-hop relationships originating from them. 
```
CREATE VIEW v1 ON g WITH DEFAULT MAP (
  MATCH (p1:U)-[f1:F]->(p2:U), (p2)-[f2:F]->(p3:U), !(p1)-[f3:F]->(p3)
  WHERE p1 != p3 AND p1 < 100000
  CONSTRUCT (p1:U)-[r:R]->(p3:U)
  SET r = SK(\"rr\", p1, p3)
)

CREATE VIEW v2 ON v1 WITH DEFAULT MAP (
  MATCH (p1:U)
  WHERE p1 < 501
  DELETE p1
)
```
### Query Workload
For a specific group of users, return those who have a 2-hop or 3-hop relationship originating from them.
```
MATCH (p1:U)-[r:R]->(p2:U) 
  FROM v2
  WHERE p1 < 5000 
  RETURN (p2)

MATCH (p1:U)-[r1:R]->(p2:U), (p2)-[r2:R]->(p3:U), (p1)-[r3:F]->(p3)
  FROM v2 
  WHERE p1 < 30000 AND p1 != p3 RETURN (p3)
```


## WORD
### Description of Dataset
* Source: [WordNet](https://wordnet.princeton.edu/)
#### Preprocessing
* The dataset is obtained from [the Python NLTK package](https://www.nltk.org/howto/wordnet.html) and converted into a graph.
#### Schema
```
Node labels
 (:W) : Word
 (:L) : Lemma
 (:S) : Synset

Edge labels
 -[:SL]-> : is-Synset-Lemma-relationship
 -[:WS]-> : is-Word-Synset-relationship

Constraints on Edge Connectivity
 (:S)-[:SL]->(:L)
 (:W)-[:WS]->(:S)
```            
### View definition
```
CREATE VIEW v1 ON g WITH DEFAULT MAP (
  MATCH (w:W)-[ws:WS]->(s:S)
  CONSTRUCT (m:MS)
  MAP FROM w, s TO m
  SET m = SK(\"ff\", s)
  DELETE ws
)
```
### Query Workload
```

MATCH (m:MS)-[sl:SL]->(l:L) 
FROM v1 
WHERE l < 100 
RETURN (l)

MATCH (m:MS)-[sl:SL]->(l:L) 
FROM v1 
WHERE l < 150 
RETURN (l)
```
