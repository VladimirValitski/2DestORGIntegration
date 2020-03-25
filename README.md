# 2DestORGIntegration

Acceptance criteria
 Create two dev orgs
 Create 500.000 records of any type on org Source with unique random names.
 Import those 500.000 records from org Source to org Dest. This is Source time job. Records should have ExtId__c to establish link 'record on org Source' => 'record on org Dest'
 Create a trigger on org Source that will create / update / delete / undelete related record from org Dest.
 Create a schedule job that will be running daily. It should sync records from org Dest to org Source.
 Create email template and send email once a day to system admin with information how many records exist on org Source.