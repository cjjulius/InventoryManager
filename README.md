<h1 align="center">

![SDIM_logo](https://user-images.githubusercontent.com/4412545/230189133-94e38d8e-1abc-40cb-b2d1-5a252de8c495.png)
<br>
Simple Database Inventory Manager<br>
</h1>

<br>
<b>What is SDIM?</b>

All DBAs should keep track of their Servers/ Instances/ etc not only for their own edification, but for Management and security reasons as well. If you’re not, then you need to, as it comes in incredibly handy even if it isn’t a requirement of the job.

Most of the time, this information is compiled into a spreadsheet of some kind or possibly in a word processing document somewhere. Keeping this data up-to-date and accurate is a pain, especially when you have to break it out into multiple tabs and/or over multiple documents.

You could get a full-blown inventory manager that collects and compiles all the data and organizes it for you. But there’s a definite cost to that solution and not one that all companies will find useful (Read: “It’s not in the budget this quarter”).

What if you can’t get someone to shell out the money for a product like that? Then you have to either keep with the spreadsheets (yuck) or you need to find another solution with the tools you have.

This is an attempt to do this and make it portable from one system to another.<br>
<br>
<h2>Requirements</h2>

Repository Server - SQL Server 2012 or better. PowerShell 3 or better installed.<br>
Clients - Powershell 4 or better.<br>
CMS Server (Optional) - SQL Server 2012 or better. PowerShell 3 or better installed.<br>
Active Directory Environment<br>

<i>Note SDIM v2.3 and earlier</i>: SDIM will be able to access 2005 - 2022 SQL Server Instances, however, it needs to be installed on 2012 or better. You might be able to get it to work on 2008R2, but that is not a supported setup.<br>

<i>Note SDIM v2.4</i>: SDIM 2.4 can only access from 2012-2022 editions because of its use of the SERVERPROPERTY('ProductUpdateLevel') to capture CU since this is 'new' way that SQL Server updates. <br>

<i>Note SDIM v2.7.1</i>: SDIM 2.7.1 by default has temporal tables for the Srv/DB permissions. This limits the CMS to 2016+. If you would like to install this on 2012/2014 then simply remove these from the table definition and do not deploy the history tables.   <br>
<br>
<h2>How do I install?</h2>

Is not a long process, but it does require certain things in a certain order. This will guide you through setting these up. The current version of this guide is for SDIM 2.7.1<br>
<br>

<h3><i>Step 1</i>: Set up your Repository Server</h3>

The repository server is where you are going to stored the data after you have pulled it from your instances. It can be the same server as your CMS or something else entirely.  This guide assumes that you are using a CMS and the DBAdmin database. If not, then you'll need to use the correct switches and change the scripts to point to your Server\Instance.Database.
 
 On your Repository Server, run the following script:
 
 DBAdmin.sql<br>
 <br>
 
 <h3><i>Step 2</i>: Build schemas and tables</h3>
 
 On your Repository Server in the DBAdmin database run the following scripts in this order:

Utility.Schema.sql<br>
Reports.Schema.sql<br>
stage.Schema.sql<br>

dbo.DatabaseList.Table.sql<br>
dbo.InstanceList.Table.sql<br>
dbo.JobList.Table.sql<br>
dbo.prGetTables.StoredProcedure.sql<br>
dbo.prInsertTableList.StoredProcedure.sql<br>
dbo.ServerList.Table.sql<br>
dbo.ServiceList.Table.sql<br>
dbo.TableList.Table.sql<br>
dbo.tDBPermission.Table.sql<br>
dbo.tDBPermissionHist.Table.sql<br>
dbo.tSrvPermission.Table.sql<br>
dbo.tSrvPermissionHist.Table.sql<br>
stage.tDBPermission.Table.sql<br>
stage.tSrvPermission.Table.sql<br>
Utility.SDIMInfo.Table.sql<br>  
<br>
<h3><i>Step 3</i>: Create Views</h3>
 On your Repository Server in the DBAdmin database run the following scripts in this order:

Reports.vwGetInstancesGroup_SQLVer.View.sql<br>
Reports.vwGetServers.View.sql<br>
Reports.vwGetServers_Instances_SQLVersion_Instance_FullList.View.sql<br>
<br>

<h3><i>Step 4</i>: Create Stored Prcedures</h3>

 On your Repository Server in the DBAdmin database run the following scripts in this order:
 
dbo.prGetConnectionInformation.StoredProcedure.sql<br>
Utility.prInsertNewServerAndInstance.StoredProcedure.sql<br>
dbo.prUpdateServerList.StoredProcedure.sql<br>
dbo.prUpdateInstanceList.StoredProcedure.sql<br>
dbo.prStageSrvPermissions.StoredProcedure.sql<br>
dbo.prStageDBPermissions.StoredProcedure.sql<br>
dbo.prMergeSrvPermissions.StoredProcedure.sql<br>
dbo.prMergeDBPermissions.StoredProcedure.sql<br>
dbo.prInsertTableList.StoredProcedure.sql<br>
dbo.prInsertServiceList.StoredProcedure.sql<br>
dbo.prInsertNewServerAndInstanceCMS.StoredProcedure.sql<br>
dbo.prInsertJobList.StoredProcedure.sql<br>
dbo.prInsertDatabaseList.StoredProcedure.sql<br>
dbo.prGetTables.StoredProcedure.sql<br>
dbo.prGetSrvPermissions.StoredProcedure.sql<br>
dbo.prGetServersGroup_OS_SP.StoredProcedure.sql<br>
dbo.prGetServerServices.StoredProcedure.sql<br>
dbo.prGetServersAndInstances.StoredProcedure.sql<br>
dbo.prGetServers.StoredProcedure.sql<br>
dbo.prGetServerNames.StoredProcedure.sql<br>
dbo.prGetJobsExt.StoredProcedure.sql<br>
dbo.prGetJobs.StoredProcedure.sql<br>
dbo.prGetInventory.StoredProcedure.sql<br>
dbo.prGetInstancesGroup_SQLVer_SQLEd_SQLSP.StoredProcedure.sql<br>
dbo.prGetInstancesGroup_SQLVer_SQLEd.StoredProcedure.sql<br>
dbo.prGetInstancesGroup_SQLVer.StoredProcedure.sql<br>
dbo.prGetInstancesAndDatabases.StoredProcedure.sql<br>
dbo.prGetInstances.StoredProcedure.sql<br>
dbo.prGetDBPermissions.StoredProcedure.sql<br>
dbo.prGetDatabasesAndSize.StoredProcedure.sql<br>
Utility.prSDIMInfo.StoredProcedure.sql<br>
Utility.prSetLastRun.StoredProcedure.sql<br>
<br>

<h3><i>Step 5</i>: Set up Dependent Scripts<br></h3>

On your *Client* Servers in the master database run the following scripts in this order. If you currently have these scripts on your servers it will replace the version you have with this one. You can try to use a different version but it may break the process since DB_DataPull will need the "Report" funcionality to return data in a specific format to ingest. <br>

dbo.sp_SrvPermissions.sql<br>
dbo.sp_DBPermissions.sql<br>

*Note:* If you are using a CMS you can run the script across all servers simultaneously.<br>
<br>

<h3><i>Step 6</i>: Run 2.7.1_RunOnce.sql<br></h3>

 On your Repository Server in the DBAdmin database run the following script. This will populate a field or fields that need to be set for your version.<br>
 
2.7.1_RunOnce.sql<br>
<br>

<h3><i>Step 7</i>: Set up the DataPull<br></h3>

Put DB_DataPull.ps1 on your repository server, somewhere easily accessible. You'll want to pass the parameters into this to pull your data. I would recommend setting up a windows task or SQL job to run this by passing in the necessary parameters. You could also create a batch file that calls it and add parameters in there, your call.

There are defaults for all of these already in the script, the only one you HAVE to change is the CMS Server location with -CMSServer and toggle -UseCMS. If you're not providing a CMS server just ignore this parameter (you will need to provide a list of servers and instances manually using Utility.prInsertNewServerAndInstance).

<b>DB_DataPull.ps1 Parameters</b><br>
-RepositoryInstance "SomeInstance" <br>
The location of the repository instance relative to the server running the script. Assumed to be the same server "(local)" as this is probably the best practice<br>
-RepositoryDB "SomeDB" <br>
The location of the Repository DB relative to the instance. If you set it up like above, then that should be DBAdmin.<br>
-CMSServer "SomeServer"<br>
The location of the CMS Server. You can pass in an instance name as well "SOMESERVER\SOMEINSTANCE"<br>
-LogDir "C:\SomeDir\"<br>
Where to place the log. Log file names will be generated automatically. Default is "C:\Logs\" and stores all runs in a single day in one file.<br>
-LogFile "DB_DataPull_Log"<br>
Name of the Log. _$DATE will be appended to the name. Default (even if blank) is DB_DataPull_Log for code compatibility reasons.<br>
-LocalDir "C:\SDIM"<br>
Directory where the DB_DataPull.ps1 file is located. This allows the use of functions to make the code more reusable and clean.<br>
-UseCMS<br>
Toggle on if you're using a CMS Server. If not, it will pull from the ServerList\InstanceList and not truncate the tables.<br>
-Verbose<br>
Gives you lots of feedback.<br>
-Debug<br>
Writes Verbose to log silently.<br>

<br>
<h3><i>Step 8</i>: Set up Permissions<br></h3>

The servers that will be queried for data should be done so via a service account. 

Permssions will need to be done via two steps:

1. Run Permissions.sql on all of the servers you will be collecting on. IF you are using a CMS run the script via that method on all servers.<br>
You can comment out the DBAdmin section for servers that are not the CMS as they only access the CMS DBadmin.<br>

2. Give wmi permissions to the service account.<br>

The Hard Way (more secure):<br>
1. Open Component Services (dcomcnfg.exe)
2. Navigate to DCOM Config (Component Services > Computers > My Computer > DCOM Config)
3. In the details pane find "Windows Management and Instrumentation"
4. Right click and select 'Properties'
5. Go to the 'Security' tab and note the 'Launch And Activation Permissions', and 'Access Permissions'
6. Select 'Customize' if not already selected
7. Click Edit
8. In the Security properties page, click Add
9. In the Select Users or Groups popup, add the guest account (for local machine it's just type 'guest' and click 'Check Names' then 'OK', not sure about server in a domain)
10. Back in the Security properties page, note that Guest has less permissions by default than 'Everyone'. Give 'Remote Launch' and 'Remote Activation' and 'Local Activation'.

The Easy Way (less secure):<br>
Add the service account to the local Administrators group in lusrmgr.msc<br>
<br>

<h3><i>Step 9</i>: Set up the Clients<br></h3>

The clients can run these through powershell, or you can create a batch file that passes the parameters in and then create shortcuts and whatnot to the batch (I like to pass PowerShell the -WindowStyle Hidden option). It's fairly simple.

<b>DB_DataPull_FrontEnd.ps1 Parameters</b><br>
-RepositoryInstance<br>
The location of the repository instance relative to the server running the script. Assumed to be the same server "(local)", but probably won't be if clients are accessing it from their local machines.<br>
-RepositoryDB<br>
The location of the Repository DB relative to the instance. If you set it up like above, then that should be DBAdmin.<br>
<br>

<h2><b>Further Information</b></h2>

This (Simple Database Inventory Manager™) is of course provided free of charge, use-at-your-own-risk. There is no warranty either expressed or implied. If SDIM™ burns down your data center, uninstalls all your favorite toolbars and ruins your best pair of dress socks, I’m not at fault. Remember to back up your databases!

As always, feel free to contact me if you have comments, suggestions or questions.<br>
<br>

<h2><b>UPDATES</b><br></h2>
<br>
<h3><i>2.3</i></h3>

- Works on 2005-2022.<br>
- Pushed to 2.3 release for those with older environments.<br>
- isProduction column now does not display in Instances list. That was a feature that got removed from everywhere (before 1.0). Finally removed the column.<br>
- HIPAA level feature is now completely removed.
  - Never got this one working right and I decided that in the future I’ll go with something a bit more general, like maybe just ‘priority’ or something.<br>
- Fixed a few typos. Me spel gud now.<br>
<!-- -->
<h3><i>2.4.0</i></h3>

- Collects CU info via SERVERPROPERTY('ProductUpdateLevel'). This limits SDIM 2.4+ to 2012 or later instances.<br>
- Reports in frontend have been updated to show CU 
  - Will also show SP for version where that applies, otherwise RTM.<br>
- Added parameters instead of hard-coded variables for DB_DataPull_Frontend.ps1<br>
- Cleaned up some code<br>
- CMS will now report on itself as well.<br>
<!-- -->
<h3><i>2.5.2</i></h3>

- Expanded Database collection to include more than just size. Now includes:
  - Recovery Model<br>
  - State<br>
  - Compatibility Level<br>
  - Encryption Status<br>
  - Page Verify<br>
  - Much more!<br>
<!-- -->
<h3><i>2.5.7</i></h3>

- Now collects Table information.<br>
  - Note: This process of collection can take some time depending on the number of tables you have.<br>
- Full Inventory Updated to display all Table information.<br>
<!-- -->
<h3><i>2.6.0</i><br></h3>

- Server and Database Permissions now collected with Kenneth Fisher's scripts.<br>
- sp_DBPermissions V6.2 in master is needed on all Client servers<br>
- sp_SrvPermissions V6.1 in master is needed on all Client servers<br>
<!-- -->
<h3><i>2.7.1</i><br></h3>

- Versioning added to SrvPermissions/DBPermissions so that they can be queried for changes (no UI functionality)<br>
- LastRun added as well as Version number pulled from a table rather than manually entered.<br>
- Fixed a few bugs and cleaned up some column names to make them more clear what they represent.<br>
