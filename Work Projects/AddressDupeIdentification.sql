UPDATE [*Hardmatch App Mail] SET [*Hardmatch App Mail].[Boarded Loan] = "1"

WHERE ((([*Hardmatch App Mail].[Boarded Loan]) Is Null) AND (([*Hardmatch App Mail].UNIFI_ACCT_NUM) Is Not Null));



UPDATE [*Hardmatch App mail] INNER JOIN [*Hardmatch Mail] ON [*Hardmatch mail].[app id] = [*hardmatch app mail].id SET [*Hardmatch App mail].remove = "post board date start date"

WHERE [*hardmatch app mail].[boarded loan] = "1" AND [*Hardmatch app mail].[app_start_dt]>[*Hardmatch mail].[open_date];



Insert into [x_hm mail app removals]

Select [*Hardmatch app mail].*

From [*hardmatch app mail]

Where [*hardmatch app mail].remove is not null;



Delete [*hardmatch app mail].*

From [*hardmatch app mail]

Where [*hardmatch app mail].remove is not null;



Alter Table [*hardmatch app mail]

Add column [Dupe Identifier] Number;



Alter Table [x_hm mail app removals]

Add column [Dupe Identifier] Number;



UPDate [*hardmatch app mail] SET [*hardmatch app mail].[dupe identifier] = iif([*hardmatch app mail].[boarded loan]="1",Null,1) & switch([*hardmatch app mail].[app_status_cd]="A",1,[*hardmatch app mail].[app_status_cd]="P",2,[*hardmatch app mail].[app_status_cd]="W",3,[*hardmatch app mail].[app_status_cd]="D",4)&30000000 - Val(Format([*hardmatch app mail].[APP_START_DT],"yyyymmdd"))&4000000000-[*hardmatch app mail].app_unifi_id;



SELECT [*Hardmatch App Mail].ADDRESS1, Count([*Hardmatch App Mail].ID) AS CountOfID INTO [App Mail Dupe Addresses]

FROM [*Hardmatch App Mail]

GROUP BY [*Hardmatch App Mail].ADDRESS1, [*hardmatch App Mail].[App PC]

HAVING ((([*Hardmatch App Mail].ADDRESS1) Is Not Null) AND ((Count([*Hardmatch App Mail].ID))>1))

ORDER BY Count([*Hardmatch App Mail].ID) DESC;



Update [*hardmatch app mail] INNER JOIN [App Mail Dupe Addresses] ON [*Hardmatch app mail].Address1 = [App Mail Dupe Addresses].Address1 SET [*hardmatch app mail].[Address Dupe] = 1;



SELECT [*Hardmatch App Mail].[dupe identifier], [*Hardmatch App Mail_1].[Dupe Identifier], [*hardmatch App Mail].[dupe identifier]-[*Hardmatch App Mail_1].[dupe identifier] AS [I find dupes], [*Hardmatch App Mail].ID INTO [Finding Mail App Address Dupes]

FROM [*Hardmatch App Mail] AS [*Hardmatch App Mail_1] INNER JOIN [*Hardmatch App Mail] ON ([*Hardmatch App Mail].ID <> [*Hardmatch App Mail_1].ID) AND ([*Hardmatch App Mail_1].ADDRESS1 = [*Hardmatch App Mail].ADDRESS1) AND ([*Hardmatch App Mail].[App PC] = [*Hardmatch App Mail_1].[APP PC])

WHERE ((([*hardmatch App Mail].[dupe identifier]- [*Hardmatch App Mail_1].[dupe identifier] >0)));



SELECT [*Hardmatch App Mail].ADDRESS1, [*Hardmatch App Mail].Remove, Count([*Hardmatch App Mail].ID) AS CountOfID, First([*Hardmatch App Mail].APP_UNIFI_ID) AS FirstOfAPP_UNIFI_ID INTO [MessedUpDupesMail]

FROM [*Hardmatch App Mail]

WHERE ((([*Hardmatch App Mail].[Address Dupe]) Is Not Null))

GROUP BY [*Hardmatch App Mail].ADDRESS1, [*Hardmatch App Mail].Remove

HAVING ((([*Hardmatch App Mail].Remove) Is Null) AND ((Count([*Hardmatch App Mail].ID))>1));



UPDATE [*Hardmatch App Mail] INNER JOIN [Finding Mail App Address Dupes] ON [*Hardmatch App Mail].ID = [Finding Mail App Address Dupes].ID SET [*Hardmatch App Mail].[App Remove Reason] = Switch([Finding Mail App Address Dupes].[I find Dupes]>200000000000000,"“Status”",[Finding Mail App Address Dupes].[I find dupes]>3000000 And [Finding Mail App Address Dupes].[I find dupes]<=200000000000000,"“Date”",[Finding Mail App Address Dupes].[I find dupes]<=3000000,"“App Number”"), [*Hardmatch App Mail].remove = “Address Dupe”;



UPDATE [*Hardmatch App Mail] INNER JOIN [Finding Mail App Address Dupes] ON [*Hardmatch App Mail].ID = [Finding Mail App Address Dupes].ID SET [*Hardmatch App Mail].[App Remove Reason] = Switch([Finding Mail App Address Dupes].[I find Dupes]>200000000000000,"“Status”",[Finding Mail App Address Dupes].[I find dupes]>3000000 And [Finding Mail App Address Dupes].[I find dupes]<=200000000000000,"“Date”",[Finding Mail App Address Dupes].[I find dupes]<=3000000,"“App Number”"), [*Hardmatch App Mail].remove = "Address Dupe";



UPDATE [*Hardmatch App Mail] INNER JOIN [MessedUpDupesMail] ON [*Hardmatch App Mail].Address1 = [MessedUpDupesMail].Address1 AND [*Hardmatch App Mail].[APP_UNIFI_ID] = [MessedUpDupesMail].FirstOfAPP_UNIFI_ID SET [*Hardmatch App Mail].[App remove reason] = "App ID", [*hardmatch App Mail].remove = "Address Dupe";
