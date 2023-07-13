# Implementing Views for Property Graph Transformations

This document describes the graph datasets, as well as the view and query workloads used in the experiment.

## Graph Datasets
Our experiment includes five graph datasets from a variety of domains.

| Abbreviation  | Name        | Type  | $&#124; N &#124;$ | $&#124; E &#124;$ |
| ------------- |-------------| ----- | ----- | ----- |
| SYN | Syntatic Graph |Syntatic | - | - |
| OAG | Open Aacademic Graph | Citation | 19.25M | 23.33M | 
| PROV | Wikipedia Edits | Provenance | 5.15M | 2.65M | 
| SOC | Twitter | Social | 713K | 405K | 
| WORD | WordNet | Knowledge | 823K | 472K | 

## Workload Description
View definitions contain:
* Construction (input graph pattern to output graph pattern)
* Transformed view with default rules
* Create new nodes or edges / delete
* Mapping variables (of nodes/edges) to a node or edge
* Recursion on a graph pattern
  
Queries contain:
* Retrieve a node or edge pattern or a graph pattern
* project tuples using the WHERE clause over properties
* (optional) Recursion





## SYN
### Description of Dataset
#### Preprocessing
#### Schema
### View definition
### Query Workload





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
CREATE VIEW oag_view AS (
 CONSTRUCT MAP FROM n1,n2 TO (s:OA)
 MATCH (n1:MA)-[e1:L]->(n2:AA)
 FROM oag
 WHERE n1 < 300000
  UNION
 CONSTRUCT MAP FROM n1,n2 TO (s:OP)
 MATCH (n1:MP)-[e1:L]->(n2:AP)
 FROM oag
 WHERE n1 < 200300000
)
```
### Query Workload
Retrieve a set of nodes that were newly created in the view.
```
// OAG-Q1 
MATCH (n1:OA)
FROM oag_view
RETURN n1

// OAG-Q2
MATCH (n1:OP)
FROM oag_view
RETURN n1
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
 (:AC) : Entity - Creation 
 (:AR) : Entity - Revision

Edge labels
 -[:DERBY]-> : isDeriveFrom
 -[:USED]-> : used
 -[:GENBY]-> : isGeneratedBy
 -[:ASSOC]-> : isAssociatedWith
 -[:ATTR]-> : isAttributedTo

Constraints on Edge Connectivity
 (:R)-[:DERBY]->(:R)
 (:R)-[:USED]->(:AR)
 (:R)-[:GENBY]->(:AC)
 (:R)-[:GENBY]->(:AR)
 (:AR)-[:ASSOC]->(:U)
 (:AR)-[:ATTR]->(:U)
```            
### View definition
For two chosen sets of revision activities, establish an 'isAttributedTo' relationship derived from 'Used' and 'isAssociatedWith' relationships.
```
CREATE VIEW prov_view AS (
 CONSTRUCT (v2)-[ne1:ATTR]->(v3)
 MATCH (v1:R)-[e1:USED]->(v2:AR), (v1)-[e2:ASSOC]->(v3:U)
 FROM prov
 WHERE v1 < 5000
  UNION
 CONSTRUCT (v2)-[ne1:ATTR2]->(v3)
 MATCH (v1:R)-[e1:USED]->(v2:AR), (v1)-[e2:ASSOC]->(v3:U)
 FROM prov
 WHERE v1 > 5000 AND v1 < 8000
)
```
### Query Workload
For a particular set of revision entities, retrieve nodes or edges that have an 'isAttributedTo' relationship originating from them
```
// PROV-Q1 
MATCH (v1:AR)-[ne1:ATTR]->(v2:U)
FROM prov_view
WHERE v1 < 2000
RETURN v1

// PROV-Q2
MATCH (v1:AR)-[ne1:ATTR2]->(v2:U)
FROM prov_view
WHERE v1 < 6000 AND v1 > 5000
RETURN ne1
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
CREATE VIEW soc_view AS (
 // create 2-hop friendship
 CONSTRUCT (u1)-[e3:F2]->(u3)
 MATCH (u1:U)-[e1:F]->(u2:U), (u2)-[e2:F]->(u3:U)
 FROM soc
 WHERE u1 < 50
  UNION
 // create 3-hop friendship
 CONSTRUCT (u1)-[e4:F3]->(u4)
 MATCH (u1:U)-[e1:F]->(u2:U), (u2)-[e2:F]->(u3:U), (u3)-[e3:F]->(u4:U)
 FROM soc
 WHERE u1 < 50
)
```
### Query Workload
For a specific group of users, return those who have a 2-hop or 3-hop relationship originating from them.
```
// SOC-Q1 
MATCH (u1:U)-[e1:F2]->(u2:U)
FROM soc_view
WHERE u1 > 0 AND u1 < 10
RETURN u1

// SOC-Q2
MATCH (u1:U)-[e1:F3]->(u2:U)
FROM soc_view
WHERE u1 > 10 AND u1 < 15
RETURN u1
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
 -[:A]-> : isAntonym
 -[:AS]-> : isAnotnymSynset
 -[:C]-> : isContainedIn

Constraints on Edge Connectivity
 (:S)-[:SL]->(:L)
 (:W)-[:WS]->(:S)
 (:L)-[:A]->(:L)
 (:S)-[:AS]->(:S)
 (:W)-[:C]->(:L)
```            
### View definition
For a chosen set of synsets, generate antonym synsets based on the antonym relationships of the words they contain. Add direct edges from words to lemmas that are connected through a synset.
```
CREATE VIEW word_view AS (
 CONSTRUCT (s1)-[e4:AS]->(s2)
 MATCH (s1:S)-[e1:SL]->(l1:L), (s2:S)-[e2:SL]->(l2:L), (l1)-[e3:A]->(l2)
 FROM word
 WHERE s1 < 3000
  UNION
 CONSTRUCT (w)-[e3:C]->(l)
 MATCH (w:W)-[e1:WS]->(s:S), (s)-[e2:SL]->(l:L)
 FROM word
 WHERE w < 7000 AND w > 3000
)
```
### Query Workload
For a particular set of words and synsets, retrieve edges that were newly created in the graph view.
```
// WORD-Q1 
MATCH (w:W)-[e:C]->(l:L)
FROM word_view
WHERE w > 5000 AND w < 6000
RETURN e

// WORD-Q2
MATCH (s1:S)-[e:AS]->(s2:S)
FROM word_view
WHERE s1 > 2800 AND s1 < 3000
RETURN e
```
