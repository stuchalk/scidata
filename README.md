# SciData

SciData is a general scientific data model (SDM) and related ontology (SDMO) that has been developed for use in chemistry but may also be useful in biology, physics, and related disciplines.  It can be used in any way, meaning that it can be applied in databases (relational or graph), spreadsheets (excel or google sheets), and any other way that makes sense for the user.  The examples in this repo are all written in JSON-LD (https://www.w3.org/TR/json-ld/) because the data annotated in this way can be read by humans and also converted to RDF.

It is important to point out that SciData is a framework about how to organize scientific data and its contextual metadata. Contextual meaning of the metadata and data stored in the framework is the responsibility of other ontologies (as can be seen in some of the examples). Although the framework provides a detailed way to link/organize this information none of the pieces are required and all terms can be used in any way needed by the user.  The only caveat is that if the links between data and metadata are important in your application you need to be careful to implement them with or without the SciData framework.

For more information see the GitHub website for this repo - http://stuchalk.github.io/scidata or the paper recently presented at the 251st ACS Meeting in San Diego (http://www.slideshare.net/stuchalk/a-generic-scientific-data-model-and-ontology-for-representation-of-chemical-data).  A paper on this work will be coming out in the summer of 2016.

If you are interested in using the framework please let me know so I can help you implement it.  If you have data you think would work in this format but don't have the time to develop it send me a sample and I will convert it for you.  This is a great way to see how well it works in general.  Post suggestions by adding issues to this repo.  Finally, if you are interested in the development of the framework also let me know so I can add you as a contributor (only collaborators can edit).

Thanks

Stuart Chalk (schalk@unf.edu)

*The license for this work is Creative Commons Attibution-ShareAlike 4.0 International (4.0)*