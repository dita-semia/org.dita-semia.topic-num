# dita-semia-topic-num
The purpose of thsi DITA-OT plugin is to add a number to all topic titles as a preprocess step.

Since after installation the step will be executed for every(!) transtype the feature has to activated explicitly by setting the parameter dita-semia.topic-num.activate to true.

The main purpose is to add topic numbers for an HTML transtype since this task requires map awareness when processing the individual topic files - which is usually the case for PDF output but not for HTML.
