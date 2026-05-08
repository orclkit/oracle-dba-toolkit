---
title: "Validate Schema Integrity using Cross-Schema Invalid Object Comparison"
author: "@orclkit"
date: "2026-05-08"
tags: [oracle, sql, database-audit, dba]
---

# Validate Schema Integrity using Cross-Schema Invalid Object Comparison

> [!NOTE]
> This article covers cross-schema status auditing for Oracle Developers (11g through 23ai).
>
> **Goal:** Validate deployment success by detecting broken dependencies and mismatched object states between development and target schemas.

## TL;DR
* **Problem:** Manual verification of object status across multiple schemas is error-prone and time-consuming.
* **Solution:** Execute a self-joining query on **DBA_OBJECTS** to identify identical objects with **INVALID** status in the source baseline.
* **Key Command:** `SELECT src.object_name FROM DBA_OBJECTS src JOIN DBA_OBJECTS trg ON ...`

---

## 📑 Table of Contents
- [Prerequisites](#-prerequisites)
- [The Challenge](#-the-challenge)
- [Step-by-Step Implementation](#-step-by-step-implementation)
- [Developer & DBA Insights](#-developer--dba-insights)
- [Troubleshooting & Best Practices](#-troubleshooting--best-practices)
- [Implementation Checklist](#-implementation-checklist)

## 🛠 Prerequisites
Before starting, ensure you have:
- [ ] Access to Oracle Database 12c, 19c, 21c, or 23ai.
- [ ] `SELECT` privileges on `DBA_OBJECTS` or `SELECT_CATALOG_ROLE`.
- [ ] Target schema names (Owner) in UPPERCASE format.

## 💡 The Challenge
Deployment failures often stem from missing grants or broken dependencies that occur when code is applied to a target schema.
Standard auditing often misses objects that exist in both schemas but have different compilation states.

```sql
-- Avoid this pattern: Manually checking one schema at a time
SELECT object_name, status FROM DBA_OBJECTS WHERE owner = 'ADMIN' AND status = 'INVALID';
-- This fails to identify if the object even exists or is valid in the target schema.
```

## 🚀 Step-by-Step Implementation

### 1. Establish the Cross-Schema Join
To audit integrity, we join the dictionary view on `OBJECT_NAME` and `OBJECT_TYPE`.
This ensures the comparison targets identical logical components.
We use semantic line breaks to optimize Git diff tracking.

```sql
-- Implementation code
SELECT
    src.object_name,
    src.object_type,
    TO_CHAR(src.created, 'DD/MM/YYYY HH24:MI:SS')       AS created,
    TO_CHAR(src.last_ddl_time, 'DD/MM/YYYY HH24:MI:SS') AS last_ddl_time,
    src.status                                          AS source_status,
    trg.status                                          AS target_status
FROM DBA_OBJECTS src
JOIN DBA_OBJECTS trg
  ON src.object_name = trg.object_name
 AND src.object_type = trg.object_type
WHERE src.owner = 'ADMIN'    -- Set Source Schema (Baseline)
  AND src.status = 'INVALID' -- Focus on broken objects
  AND trg.owner = 'CUSTOMER' -- Set Target Schema (Verification)
ORDER BY src.object_name, src.object_type;
```

### 2. Correlate with DDL Timestamps
Identify when the invalidation occurred by extracting DDL metadata.
This helps isolate if a recent change caused the state transition.

> [!IMPORTANT]
> Large data dictionaries with millions of rows may experience latch contention during high-frequency polling.
> Always filter by `OWNER` to utilize dictionary indexes.

---

## 🧠 Developer & DBA Insights

### **Execution Metadata**
*   **CREATED vs. LAST_DDL_TIME:** By comparing these two timestamps, a DBA can determine if an object is invalid because it is brand new or because a recent DDL change broke an existing dependency.
*   **Status Parity:** Seeing `INVALID` on both sides suggests a systemic code issue, whereas `VALID` in source and `INVALID` in target usually points to a missing grant or synonym in the target environment.

### **Permission Requirements**
To execute this utility against `DBA_OBJECTS`, you require `SELECT_CATALOG_ROLE` or `DBA` privileges. In environments with restricted access, the script can be modified to use `ALL_OBJECTS`.

---

## 🛠 Troubleshooting & Best Practices


| Issue | Potential Cause | Recommended Fix |
| :--- | :--- | :--- |
| **ORA-00942** | Missing Privileges | Use `ALL_OBJECTS` or request `SELECT_CATALOG_ROLE`. |
| **No Matches Found** | Case Sensitivity | Schema names must be **UPPERCASE** (e.g., `'ADMIN'`, not `'admin'`). |
| **Performance Lag** | Dictionary Size | Filter by `OBJECT_TYPE` (e.g., `'PACKAGE'`) to reduce join overhead on large instances. |

---

## 📋 Implementation Checklist
- [ ] Convert all schema input names to UPPERCASE.
- [ ] Verify `DBA_OBJECTS` access before script execution.
- [ ] Run `utlrp.sql` to clear existing "stale" invalidations before auditing.
- [ ] Compare `LAST_DDL_TIME` to correlate with deployment logs.

---

## 👨‍💻 About the Author
**Kitti Taweepanyayot** is a Senior Oracle Developer focused on high-performance PL/SQL engineering, database automation, and complex schema architecture.
This utility is a core component of the **[Oracle DBA Toolkit](https://github.com)**, a repository of professional utilities designed to streamline database management tasks and ensure application integrity across enterprise Oracle environments.

[![Static Badge](https://img.shields.io/badge/LinkedIn-blue?style=plastic&logo=Linkedin&logoColor=white)](https://www.linkedin.com/in/kitti-taweepanyayot/)
[![Static Badge](https://img.shields.io/badge/github-repo-blue?style=plastic&logo=github)](https://github.com/orclkit/oracle-dba-toolkit)

---
