# Deep Dive: Auditing Oracle 19c Patching via DBA_REGISTRY_SQLPATCH on AWS RDS

As an Oracle Developer, understanding the state of your database is critical for troubleshooting performance regressions and security vulnerabilities. On **Oracle 19c RDS**, where you lack OS-level access to run `opatch lsinventory`, the `DBA_REGISTRY_SQLPATCH` view is your primary source of truth for the database's "code level."

---

## 1. The Evolution of Patch Tracking: From Legacy to Modern
To understand why we use `DBA_REGISTRY_SQLPATCH` today, we must look at how Oracle's internal tracking has evolved.

### **The Legacy: SYS.REGISTRY$HISTORY**
In the era of **Oracle 11g and older**, patching was a manual, multi-step process using the `catbundle.sql` script.
*   **Purpose:** It tracked major upgrades, downgrades, and older "Patch Set Updates" (PSUs).
*   **Limitation:** It didn't provide granular details about individual SQL script failures or specific metadata about modern Release Updates (RUs).
*   **Current Status:** While the view `DBA_REGISTRY_HISTORY` still exists in 19c for backward compatibility, it is largely **deprecated**. It often remains empty or static because modern tools no longer update it.

### **The Modern Base: SYS.REGISTRY$SQLPATCH**
Starting with **Oracle 12c**, Oracle introduced the `datapatch` utility and a more robust internal registry.
*   **Underlying Table:** `SYS.REGISTRY$SQLPATCH` is the actual data dictionary table where every SQL-level patch action is recorded.
*   **Usage:** While `SYS.REGISTRY$SQLPATCH` contains the raw data, DBAs and Developers should use the **`DBA_REGISTRY_SQLPATCH`** view, which provides a formatted, human-readable layer over this base table.


| Database Version | Primary Tool | Recommended Query View |
| :--- | :--- | :--- |
| **Oracle 11g** | `catbundle.sql` | `DBA_REGISTRY_HISTORY` |
| **Oracle 12c - 23c+** | `datapatch` | `DBA_REGISTRY_SQLPATCH` |

---

## 2. Why DBA_REGISTRY_SQLPATCH for RDS?
In a managed environment like **Amazon RDS**, AWS handles the binary patching of the engine. However, the **SQL portion** (the post-install scripts) must execute within the database instance to update the Data Dictionary.

`DBA_REGISTRY_SQLPATCH` allows you to audit these automated AWS maintenance tasks to ensure your instance is running the expected Release Update (RU).

---

## 3. Core Column Reference for Developers


| Category | Column | Description & Developer Significance |
| :--- | :--- | :--- |
| **Identification** | `PATCH_ID` | Unique numeric Oracle bug ID. Use this to cross-reference fixes on My Oracle Support (MOS). |
| | `PATCH_UID` | Universal Patch ID; a globally unique identifier for specific patch versions. |
| | `DESCRIPTION` | Text summary of the update (e.g., *"Database Release Update 19.20.0.0.0"*). |
| **Status & Action** | `ACTION` | Indicates whether the script was an **APPLY** (install) or **ROLLBACK** (removal). |
| | `STATUS` | **Critical:** `SUCCESS` means full application. `WITH ERRORS` indicates partial failure. Any status other than `SUCCESS` on RDS requires an AWS Support ticket. |
| | `ACTION_TIME` | Timestamp of execution. Essential for correlating patching with performance events. |
| **Classification** | `PATCH_TYPE` | Categorizes the patch as: <br> • `RU`: Release Update <br> • `RUR`: Release Update Revision <br> • `INTERIM`: One-off patch |
| | `BUNDLE_SERIES` | Identifies the family, such as `DBRU` (Database RU) or `OJVM` (Oracle Java VM). |
| **Internal Ops** | `INSTALL_ID` | Unique session ID per `datapatch` run; helps group multiple patches applied together. |
| | **`FLAGS`** | **Metadata Indicators (See Breakdown Below).** On RDS, **`NJ`** is common. |
| | `LOGFILE` | Path to execution logs. *Note: On RDS, view these via the AWS Console (e.g., `lsinventory-dbv.txt`).* |


---

## 4. Decoding the FLAGS Column
The `FLAGS` column contains single-letter indicators describing the environment or execution mode required for the SQL portion of the patch.

| Flag | Meaning | Developer Impact |
| :--- | :--- | :--- |
| **J** | **JVM Patch** | Indicates this patch affects **Oracle Java VM**. Be careful with Java-based stored procedures during this window. |
| **M** | **Merged** | This patch installation was merged with another patch during the application process. |
| **N** | **Normal Mode** | The patch was applied while the database was in normal **OPEN** (Read/Write) mode. |
| **R** | **Retried** | The patch installation was retried after a previous attempt failed or was interrupted. |
| **U** | **Upgrade Mode** | The patch required the database to be opened in **UPGRADE** mode to run its SQL scripts. |

> **Pro-Tip:** On RDS, an **"NJ"** flag means a Java VM patch was applied while the database remained in Normal Open mode.


---

## 5. Advanced Query: Deep Metadata Extraction
The `PATCH_DESCRIPTOR` column is stored as an `XMLTYPE`. We can use `XMLTABLE` to pull specific attributes like the **Target RU Version** and the **Impacted Components**.

Since a patch can impact multiple components (like CATPROC and JAVAVM), we use the XQuery `string-join` function to prevent `ORA-19279` errors and keep the output clean.

```sql
SELECT pch.patch_id
       ,pch.description
       ,pch.status
       ,xtb.target_ru
       ,xtb.patch_type
       ,xtb.impacted_components
FROM   DBA_REGISTRY_SQLPATCH pch
       CROSS JOIN XMLTABLE('/sqlPatch'
            PASSING pch.patch_descriptor
            COLUMNS
                target_ru VARCHAR2(20) path '@ruVersion'
                , patch_type VARCHAR2(20) path '@patchType'
                , impacted_components VARCHAR2(100) path 'string-join(components/component, ", ")'
        ) xtb
WHERE  pch.status = 'SUCCESS'
ORDER  BY pch.action_time DESC;
```

<p align="center">
  <img src="./images/oracle-19c-patch-registry-query.jpg" alt="Oracle 19c Patch Registry Results">
  <br>
  <i>Figure 1: Successful extraction of Target RU and Impacted Components from the Patch Descriptor.</i>
</p>


---

## 6. Summary Checklist for RDS Database Audits

When managing Oracle 19c on Amazon RDS, keep these platform-specific constraints in mind:

1.  **Managed Execution:** You cannot run `datapatch` manually. AWS triggers this automatically during your maintenance window or when you modify the instance version.
2.  **Inventory Sync:** It can take up to **60 minutes** after a maintenance window completes for this view to refresh and reflect the new patch level.
3.  **Log Access:** Actual text logs (like `lsinventory-dbv.txt`) are stored outside the database. Access these through the **RDS Management Console** under the **"Logs & events"** tab.
4.  **Status Check:** Always ensure the latest entries show `SUCCESS`. If you see `WITH ERRORS` or `FAILED`, contact AWS Support as you lack the OS permissions to rerun the SQL scripts manually.
5.  **JVM Integrity:** If the **'J'** flag is present in your audit, perform a sanity check on `USER_OBJECTS` to ensure **no** Java-based stored procedures have become `INVALID`.

---

## 7. References & Further Reading
*   [Oracle Documentation: DBA_REGISTRY_SQLPATCH (19c)](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_REGISTRY_SQLPATCH.html)
*   [Oracle Documentation: DBA_REGISTRY_SQLPATCH (21c)](https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/DBA_REGISTRY_SQLPATCH.html)
*   [Oracle Documentation: DBA_REGISTRY_SQLPATCH (23c+)](https://docs.oracle.com/en/database/oracle/oracle-database/26/refrn/DBA_REGISTRY_SQLPATCH.html)
*   [Mike Dietrich: Datapatch Return Codes and Helpful Queries](https://mikedietrichde.com/2026/02/17/datapatch-return-codes-and-helpful-queries)
*   [Rodrigo Jorge: Oracle Database Patching Internals (Deep Dive PDF)](https://2023.dbabrasil.net.br/wp-content/uploads/2023/07/Rodrigo-Jorge-DBABR23-Database-Patching-Internals.pdf)
*   [DBA Plus: Understanding SQL Patch End Status](https://www.dbaplus.ca/2019/12/dbaregistrysqlpatch-shows-end-status.html)
*   [Oracle Community Forums: How to Check Applied Patches](https://forums.oracle.com/ords/apexds/post/how-to-check-if-a-patch-has-been-applied-to-the-database-3984)

---
**Tags:** #OracleDB #AWS #RDS #DatabaseAdministration #SQL #PLSQL #Oracle19c #DatabasePatching #CloudComputing #DBA
