USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure EXEC [dbo].[prMergeDBPermissions]
Date: 		2023-03-19
Author: 	Charlton Julius
Notes: 		Merges DBPermissions staging table into 
			final table
*/

CREATE   PROCEDURE [dbo].[prMergeDBPermissions]
AS

BEGIN

BEGIN TRANSACTION [MergeDBPermissions]
	
	BEGIN TRY
		
		MERGE [dbo].[tDBPermission] AS [tgt]
		USING [stage].[tDBPermission] AS [src]
			ON [src].[RowHash] = [tgt].[RowHash]
		WHEN MATCHED 
			THEN UPDATE
				SET  [ServerName]			= [src].[ServerName]
					,[DBName]				= [src].[DBName]			
					,[DBPrincipal]			= [src].[DBPrincipal]		
					,[SrvPrincipal]			= [src].[SrvPrincipal]		
					,[type]					= [src].[type]				
					,[type_desc]			= [src].[type_desc]		
					,[RoleMembership]		= [src].[RoleMembership]	
					,[DirectPermissions]	= [src].[DirectPermissions]
		WHEN NOT MATCHED BY TARGET
			THEN
			INSERT
				(
				 [ServerName]
				,[DBName]			
				,[DBPrincipal]		
				,[SrvPrincipal]		
				,[type]				
				,[type_desc]		
				,[RoleMembership]	
				,[DirectPermissions]
				,[RowHash]
				)
			VALUES
				(
				 [src].[ServerName]
				,[src].[DBName]			
				,[src].[DBPrincipal]		
				,[src].[SrvPrincipal]		
				,[src].[type]				
				,[src].[type_desc]		
				,[src].[RoleMembership]	
				,[src].[DirectPermissions]
				,[src].[RowHash]
				)
		WHEN NOT MATCHED BY SOURCE
			THEN DELETE;
	PRINT 'Modified ' + CAST(@@ROWCOUNT AS VARCHAR(50)) + ' Rows.'
		
	END TRY
	
	BEGIN CATCH
	
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT	 @ErrorMessage = ERROR_MESSAGE()
				,@ErrorSeverity = ERROR_SEVERITY()
				,@ErrorState = ERROR_STATE();

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

		ROLLBACK TRANSACTION [MergeDBPermissions];

		PRINT 'MergeDBPermissions failed. Transaction Rolled Back';

	END CATCH;
		
IF @@TRANCOUNT > 0  
COMMIT TRANSACTION [MergeDBPermissions];
	
END
GO
