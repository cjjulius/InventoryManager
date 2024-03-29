USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure EXEC [dbo].[prMergeSrvPermissions]
Date: 		2023-03-19
Author: 	Charlton Julius
Notes: 		Merges SrvPermissions staging table into 
			final table
*/

CREATE   PROCEDURE [dbo].[prMergeSrvPermissions]
AS

BEGIN

BEGIN TRANSACTION [MergeSrvPermissions]
	
	BEGIN TRY

		MERGE [dbo].[tSrvPermission] AS [tgt]
		USING [stage].[tSrvPermission] AS [src]
			ON [src].[RowHash] = [tgt].[RowHash]
		WHEN MATCHED 
			THEN UPDATE
				SET  [ServerName]			= [src].[ServerName]		
					,[SrvPrincipal]			= [src].[SrvPrincipal]		
					,[type]					= [src].[type]				
					,[type_desc]			= [src].[type_desc]		
					,[is_disabled]			= [src].[is_disabled]		
					,[RoleMembership]		= [src].[RoleMembership]	
					,[DirectPermissions]	= [src].[DirectPermissions]
		WHEN NOT MATCHED BY TARGET
			THEN
			INSERT
				([ServerName]
				,[SrvPrincipal]
				,[type]
				,[type_desc]
				,[is_disabled]
				,[RoleMembership]
				,[DirectPermissions]
				,[RowHash])
			VALUES
				(
				 [src].[ServerName]
				,[src].[SrvPrincipal]
				,[src].[type]
				,[src].[type_desc]
				,[src].[is_disabled]
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

		ROLLBACK TRANSACTION [MergeSrvPermissions];

		PRINT 'MergeSrvPermissions failed. Transaction Rolled Back';

	END CATCH;
	
IF @@TRANCOUNT > 0  
COMMIT TRANSACTION [MergeSrvPermissions];
	
END
GO
