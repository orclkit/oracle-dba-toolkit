-- +-----------------------------------------------------------------------------+
-- | NAME: verify-oracle-19c-patch-ru-level-and-internal-components.sql          |
-- | DESCRIPTION: Audit Oracle 19c patch levels, RU versions, and impacted tags  |
-- | COMPATIBILITY: Oracle 12c, 19c, 21c, 23c                                    |
-- | LICENSE: GNU General Public License v3.0 (GPL-3.0)                          |
-- | USAGE: Execute in SQL*Plus or SQL Developer to verify Patch Registry health |
-- | Author: @orclkit                                                            |
-- +-----------------------------------------------------------------------------+


SELECT patch_id
       ,description
       ,status
       ,action
       ,action_time
       ,target_ru
       ,impacted_components
FROM   (SELECT pch.patch_id
               ,pch.description
               ,pch.status
               ,pch.action
               ,pch.action_time
               ,xtl.target_ru
               ,xtl.impacted_components
               ,row_number()
                  over (
                    PARTITION BY pch.patch_id
                    ORDER BY pch.action_time DESC) AS latest_rank
        FROM   DBA_REGISTRY_SQLPATCH pch
        CROSS JOIN XMLTABLE('/sqlPatch'
            PASSING pch.patch_descriptor
            COLUMNS 
                target_ru           VARCHAR2(20)  PATH '@ruVersion',
                impacted_components VARCHAR2(100) PATH 'string-join(components/component, ", ")'
        ) xtl
        )
WHERE  latest_rank = 1
ORDER  BY action_time DESC; 
