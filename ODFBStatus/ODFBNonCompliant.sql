SELECT comp.[Netbios_Name0]
	,os.Caption0
	,REPLACE(comp.[ConfigurationItemName],'SeacorCompliant - ', '') as ConfigurationItemName
    ,comp.[CurrentValue]
	,comp.CIVersion
	,comp.UserName
	,comp.LastComplianceMessageTime
FROM [CM_SEA].[dbo].[v_CIComplianceStatusDetail] comp
	left join v_R_System s on s.ResourceID = comp.ResourceID
	left join v_GS_OPERATING_SYSTEM os on os.ResourceID = comp.ResourceID
	INNER JOIN (
		SELECT [ConfigurationItemName]
			,MAX(CIVersion) as CIVer
		FROM [CM_SEA].[dbo].[v_CIComplianceStatusDetail]
		WHERE ConfigurationItemName like 'OneDrive Status'
		GROUP BY [ConfigurationItemName]
	) tbl1 ON comp.ConfigurationItemName = tbl1.ConfigurationItemName AND comp.CIVersion = tbl1.CIVer
WHERE comp.ConfigurationItemName = 'OneDrive Status'
order by ConfigurationItemName, Netbios_Name0
