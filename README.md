# InventoryManager
Simple Database Inventory Manager (SDIM)

<b>What is SDIM?</b>

All DBAs should keep track of their Servers/ Instances/ etc not only for their own edification, but for Management and security reasons as well. If you’re not, then you need to, as it comes in incredibly handy even if it isn’t a requirement of the job.

Most of the time, this information is compiled into a spreadsheet of some kind or possibly in a word processing document somewhere. Keeping this data up-to-date and accurate is a pain, especially when you have to break it out into multiple tabs and/or over multiple documents.

You could get a full-blown inventory manager that collects and compiles all the data and organizes it for you. But there’s a definite cost to that solution and not one that all companies will find useful (Read: “It’s not in the budget this quarter”).

What if you can’t get someone to shell out the money for a product like that? Then you have to either keep with the spreadsheets (yuck) or you need to find another solution with the tools you have.

This is an attempt to do this and make it portable from one system to another.<br>
<br>
<b>Requirements</b>

Repository Server - SQL Server 2012 or better. PowerShell 3 or better installed.<br>
Clients - Powershell 4 or better.<br>
CMS Server (Optional) - SQL Server 2012 or better. PowerShell 3 or better installed.<br>
Active Directory Environment<br>

<i>Note SDIM v2.3 and earlier:</i>: SDIM will be able to access 2005 - 2022 SQL Server Instances, however, it needs to be installed on 2012 or better. You might be able to get it to work on 2008R2, but that is not a supported setup.<br>

<i>Note SDIM v2.4</i>: SDIM 2.4 can only access from 2012-2022 editions because of its use of the SERVERPROPERTY('ProductUpdateLevel') to capture CU since this is 'new' way that SQL Server updates. <br>
<br>
<b>How do I install?</b>

Is not a long process, but it does require certain things in a certain order. This will guide you through setting these up. The current version of this guide is for SDIM 2.4.

<i>Step 1</i>: Set up your Repository Server

The repository server is where you are going to stored the data after you have pulled it from your instances. It can be the same server as your CMS or something else entirely.  This guide assumes that you are using a CMS and the DBAdmin database. If not, then you'll need to use the correct switches and change the scripts to point to your Server\Instance.Database.
 
 On your Repository Server, run the following script:
 
 DBAdmin.sql
 
 <i>Step 2</i>: Build schemas and tables
 
 On your Repository Server in the DBAdmin database run the following scripts in this order:

Utility.Schema.sql<br>
Reports.Schema.sql<br>

dbo.ServerList.Table.sql<br>
dbo.InstanceList.Table.sql<br>
dbo.DatabaseList.Table.sql<br>
dbo.ServiceList.Table.sql<br>
dbo.JobList.Table.sql<br>

<i>Step 3</i>: Create Views

 On your Repository Server in the DBAdmin database run the following scripts in this order:

Reports.vwGetInstancesGroup_SQLVer.View.sql<br>
Reports.vwGetServers.View.sql<br>
Reports.vwGetServers_Instances_SQLVersion_Instance_FullList.View.sql<br>

<i>Step 4</i>: Create Stored Prcedures

 On your Repository Server in the DBAdmin database run the following scripts in this order:
 
dbo.prGetConnectionInformation.StoredProcedure.sql<br>
dbo.prGetDatabasesAndSize.StoredProcedure.sql<br>
dbo.prGetInstances.StoredProcedure.sql<br>
dbo.prGetInstancesAndDatabases.StoredProcedure.sql<br>
dbo.prGetInstancesGroup_SQLVer.StoredProcedure.sql<br>
dbo.prGetInstancesGroup_SQLVer_SQLEd.StoredProcedure.sql<br>
dbo.prGetInstancesGroup_SQLVer_SQLEd_SQLSP.StoredProcedure.sql<br>
dbo.prGetInventory.StoredProcedure.sql<br>
dbo.prGetJobs.StoredProcedure.sql<br>
dbo.prGetJobsExt.StoredProcedure.sql<br>
dbo.prGetServerNames.StoredProcedure.sql<br>
dbo.prGetServers.StoredProcedure.sql<br>
dbo.prGetServersAndInstances.StoredProcedure.sql<br>
dbo.prGetServerServices.StoredProcedure.sql<br>
dbo.prGetServersGroup_OS_SP.StoredProcedure.sql<br>
dbo.prInsertDatabaseList.StoredProcedure.sql<br>
dbo.prInsertJobList.StoredProcedure.sql<br>
dbo.prInsertNewServerAndInstanceCMS.StoredProcedure.sql<br>
dbo.prInsertServiceList.StoredProcedure.sql<br>
dbo.prUpdateInstanceList.StoredProcedure.sql<br>
dbo.prUpdateServerList.StoredProcedure.sql<br>
Utility.prInsertNewServerAndInstance.StoredProcedure.sql<br>

<i>Step 5</i>: Set up the DataPull<br>

Put DB_DataPull.ps1 on your repository server, somewhere easily accessible. You'll want to pass the parameters into this to pull your data. I would recommend setting up a windows task or SQL job to run this by passing in the necessary parameters. You could also create a batch file that calls it and add parameters in there, your call.

There are defaults for all of these already in the script, the only one you HAVE to change is the CMS Server location with -CMSServer and toggle -UseCMS. If you're not providing a CMS server just ignore this parameter (you will need to provide a list of servers and instances manually using Utility.prInsertNewServerAndInstance).

DB_DataPull.ps1 Parameters<br>
-RepositoryInstance "SomeInstance" <br>
The location of the repository instance relative to the server running the script. Assumed to be the same server "(local)" as this is probably the best practice<br>
-RepositoryDB "SomeDB" <br>
The location of the Repository DB relative to the instance. If you set it up like above, then that should be DBAdmin.<br>
-CMSServer "SomeServer"<br>
The location of the CMS Server. You can pass in an instance name as well "SOMESERVER\SOMEINSTANCE"<br>
-LogDir "C:\SomeDir\"<br>
Where to place the log. Log file names will be generated automatically. Default is "C:\Logs\" and stores all runs in a single day in one file.<br>
-UseCMS<br>
Toggle on if you're using a CMS Server. If not, it will pull from the ServerList\InstanceList and not truncate the tables.<br>
-Verbose<br>
Gives you lots of feedback.<br>
-Debug<br>
Writes Verbose to log silently.<br>

<i>Step 6</i>: Set up the Clients<br>

The clients can run these through powershell, or you can create a batch file that passes the parameters in and then create shortcuts and whatnot to the batch (I like to pass PowerShell the -WindowStyle Hidden option). It's fairly simple.

DB_DataPull_FrontEnd.ps1 Parameters<br>
-RepositoryInstance<br>
The location of the repository instance relative to the server running the script. Assumed to be the same server "(local)", but probably won't be if clients are accessing it from their local machines.<br>
-RepositoryDB<br>
The location of the Repository DB relative to the instance. If you set it up like above, then that should be DBAdmin.<br>
<br>
<b>Further Information</b>

This (Simple Database Inventory Manager™) is of course provided free of charge, use-at-your-own-risk. There is no warranty either expressed or implied. If SDIM™ burns down your data center, uninstalls all your favorite toolbars and ruins your best pair of dress socks, I’m not at fault. Remember to back up your databases!

As always, feel free to contact me if you have comments, suggestions or questions.<br>
<br>
<b>UPDATES</b><br>
<br>
<i>2.3</i><br>
- Works on 2005-2022.<br>
- Pushed to 2.3 release for those with older environments.<br>
- isProduction column now does not display in Instances list. That was a feature that got removed from everywhere (before 1.0). Finally removed the column.<br>
- HIPAA level feature is now completely removed.
  - Never got this one working right and I decided that in the future I’ll go with something a bit more general, like maybe just ‘priority’ or something.<br>
- Fixed a few typos. Me spel gud now.<br>
<!-- -->
<i>2.4.0</i><br>
- Collects CU info via SERVERPROPERTY('ProductUpdateLevel'). This limits SDIM 2.4+ to 2012 or later instances.<br>
- Reports in frontend have been updated to show CU 
  - Will also show SP for version where that applies, otherwise RTM.<br>
- Added parameters instead of hard-coded variables for DB_DataPull_Frontend.ps1<br>
- Cleaned up some code<br>
- CMS will now report on itself as well.<br>
<br>
