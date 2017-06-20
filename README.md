# dita-semia-topic-num
This DITA-OT plugin modifies title elements by adding a number to it.

It's meant to be used for HTML-based output formats since in these transformation types (other than for PDF output) the topics are not merged into the dita map. Thus, it is difficult to do a cross-topic numbering in the output stage.

Since after installation the step will be executed for every(!) transtype the feature has to activated explicitly by setting the parameter dita-semia.topic-num.activate to true.

Also note that your transformation type might already have its own implementation for adding a prefix to figure and table titles.
For standard xhtml output this will result in titles like "Table 1. Table 1-1: Table-Title". To fix this you will have to modify the final transformation stage 
to no more add additional prefixes. For demonstration purpose the file xsl/xhtml/dita2xhtml.xsl includes templates that will do exactly this for the standard xhtml transformation. (Set the ant property args.xsl to <DITA-OT dir>/plugins/org.dita-semia.topic-num/xsl/xhtml/dita2xhtml.xsl to use it.)


## Features:

- **Add number to titles for topics**

	Topics within the front- and backmatter are not numbered at all.
	
	Topics within chapters or outside a bookmap are numbered in the format "1.1.1".
	
	Topics within appendices are numbered in the format "A.1.1".


- **Add prefix and number to titles for figures and tables and numbers for equation blocks**

	Elements within chapters are numbered in the format "1-1".
	
	Elements within appendices are numbered in the format "A-1".
	
	Elements outside a bookmap are numbered in the format "1".
	
	The numbering beyond chapter or appendix level is consecutive, ignoring the topic hierarchy.
	
	The number will be added to corssreferences to these elements as well.
	
	For crossreferences to equation blocks the content of the equation number will be added as well if it is not already present. (Right now DITA-IT does not do this.)
	
	
- **Add a prefix to chapter and appendix titles**
	
	If specified the title of chapter and appendix topics (not for the descanding topics) are extended by a prefix like "Chapter <number>: ".
	
	This is not directly related to the numbering but easily integrated here and difficult to be realized in the output stage. 


## Parameters (ant properties):

- **dita-semia.image-convert.activate**

  Switch to aktivate this preprocessing step. Needs to be set to true.

  
- **dita-semia.topic-num.num-delimiterl**

	Default: " " (single whitespace)

  
- **dita-semia.topic-num.chapter-prefix-format**

	Prefix to be added in front of a chapter title (not for descanding topics). A "$" will be replaced by the number.
	
	Set it to "" or "$" to disable this feature.

	Default: "Chapter $: " 

  
- **dita-semia.topic-num.appendix-prefix-format**

	Prefix to be added in front of an appendix title (not for descanding topics). A "$" will be replaced by the number.
	
	Set it to "" or "$" to disable this feature.

	Default: "Appendix $: " 

  
- **dita-semia.topic-num.figure-prefix-format**

	Prefix to be added in front of a figure title. A "$" will be replaced by the number.
	
	Set it to "" or "$" to disable this feature.

	Default: "Figure $: " 

  
- **dita-semia.topic-num.table-prefix-format**

	Prefix to be added in front of a table title . A "$" will be replaced by the number.
	
	Set it to "" or "$" to disable this feature.

	Default: "Table $: " 

  
- **dita-semia.topic-num.equation-prefix-format**

	Prefix to be added in front of a equation-number . A "$" will be replaced by the number.
	
	Set it to "" or "$" to disable this feature.

	Default: "Equation $: " 
  
  
- **dita-semia.topic-num.xsl**

	URL for the script to be used for the XSLT processing.
	
	Default: ${dita.plugin.org.dita-semia.topic-num.dir}/xsl/processMap.xsl

- **dita-semia.topic-num.tmp-uri-suffix**

	Suffix that is added to the filenames for generating temporal files.

	Default: ".topic-num.tmp"

