USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Utility].[SDIMInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Version] [varchar](25) NULL,
	[LastRun] [datetime2](7) NULL,
 CONSTRAINT [PK_Utility_SDIMInfo_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_SDIMInfo', @value=N'Holds SDIM information' , @level0type=N'SCHEMA',@level0name=N'Utility', @level1type=N'TABLE',@level1name=N'SDIMInfo'
GO