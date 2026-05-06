-- +----------------------------------------------------------------------------+
-- | NAME: compare-invalid-objects-between-schemas.sql                          |
-- | DESCRIPTION: Identifies invalid objects in a source schema that also exist |
-- |              in a target schema.                                           |
-- | USAGE: Replace 'ADMIN' (Source) and 'CUSTOMER' (Target) with your specific |
-- |        schema names before execution.                                      |
-- +----------------------------------------------------------------------------+

SELECT src.object_name
       ,src.object_type
       ,to_char(src.created, 'dd/mm/yyyy hh24:mi:ss')       created
       ,to_char(src.last_ddl_time, 'dd/mm/yyyy hh24:mi:ss') last_ddl_time
       ,src.status                                          AS source_status
       ,trg.status                                          AS target_status
FROM   DBA_OBJECTS src
       JOIN DBA_OBJECTS trg
         ON src.object_name = trg.object_name
            AND src.object_type = trg.object_type
WHERE  src.owner = 'ADMIN'                                  -- Set Source Schema
       AND src.status = 'INVALID'
       AND trg.owner = 'CUSTOMER'                           -- Set Target Schema
ORDER  BY src.object_name
          ,src.object_type;
