# Oracle DBA Toolkit

[ Oracle](https://oracle.com)
[ SQL](https://wikipedia.org)
[ License: GPL v3](https://gnu.org)

Essential toolkit for **Oracle Database Administrators** to automate daily monitoring, audit schema integrity, and track system health. This repository serves as a professional portfolio of high-performance SQL scripts and in-depth technical guides for enterprise-level database management.

---

## 📚 Technical Knowledge Base (Articles)

### [Auditing Oracle 19c Patching on AWS RDS](./articles/oracle-19c-rds-patching-audit-guide.md)
**The Definitive Guide to DBA_REGISTRY_SQLPATCH**

A deep dive into verifying database patch levels in managed cloud environments. This guide is essential for developers and DBAs working on **Oracle 19c RDS** where standard OS access (`opatch`) is restricted.

- **Key Topics:** `DBA_REGISTRY_SQLPATCH` vs legacy views, decoding **NJ flags**, and XML metadata extraction.
- **Tools:** Advanced SQL and XQuery (`XMLTABLE`) for data dictionary auditing.

---

### [Auditing Schema Integrity and Invalid Objects](./articles/audit-oracle-schema-integrity-invalid-objects.md)
**The Definitive Guide to Cross-Schema Dependency Validation**

An in-depth architectural guide on tracking system degradation and deployment consistency across distinct structural boundaries. This article establishes an optimal framework for isolating operational variations between target application schemas following complex database upgrades.

- **Key Topics:** Decoupling cascading metadata changes, optimizing dictionary join paths, and automating baseline consistency validation.
- **Tools:** Analytic set operations and metadata extraction via `DBA_OBJECTS` wrappers.

---

### [Automating Oracle 19c RDS File Lifecycles](./articles/automate-oracle-19c-rds-file-cleanup.md)
**Declarative Directory Purging via JSON-Driven Regex and SQL**

A senior-grade blueprint for implementing declarative, automated file retention pipelines within managed cloud databases. This framework isolates volatile retention metadata from underlying procedural processing loops, establishing a modern approach to cloud database file system maintenance.

- **Key Topics:** Mitigating PaaS space exhaustion errors, case-sensitive matching strategies, and parsing double-escaped (`\\`) regular expressions.
- **Tools:** Set-based `CROSS APPLY` lateral joins, `JSON_TABLE` policy metadata projection, and `DBMS_SCHEDULER` orchestration.

---

## 🛠️ Featured SQL Scripts

### [Cross-Schema Invalid Object Comparison](./scripts/compare-invalid-objects-between-oracle-schemas.sql)
**High-Authority Script for Schema Integrity Audits**

This diagnostic utility is crucial for identifying **INVALID objects** across different Oracle environments or application schemas (e.g., comparing `ADMIN` vs. `CUSTOMER`). It helps DBAs verify deployment success and identify broken dependencies after major patches or upgrades.

- **Primary Use Case:** CI/CD deployment validation, database migration auditing, and schema consistency checking.
- **Key Features:**
  - Tracks `INVALID` status for Views, Packages, Procedures, and Functions.
  - Compares object metadata including `CREATED` and `LAST_DDL_TIME`.
  - Optimized for **Oracle 12c, 19c, 21c, and 23c** architectures.

---

### [Oracle Patch RU Level & Component Auditor](./scripts/verify-oracle-19c-patch-ru-level-and-internal-components.sql)
**High-Impact Utility for SQL Patch Metadata Reporting**

This utility leverages **Analytic Functions** and **XQuery** to parse the database's internal XML descriptors. It identifies the **Patch RU Level** while ignoring failed attempts, providing a clean audit of the current database software state.

- **Primary Use Case:** Verifying Patch Release Updates (RU) and internal component health in **AWS RDS** or on-premise environments.
- **Key Features:**
  - Extracts **ruVersion** and **Patch Component Impact** from `XMLTYPE` descriptors.
  - Resolves **Patch Registry** history using `ROW_NUMBER()` for a deduplicated view.
  - Essential for identifying JVM and CATPROC patch states.

---

### [RDS Directory Capacity & Storage Audit Engine](./scripts/oracle-19c-rds-directory-storage-audit-engine.sql)
**Unified Storage Diagnostics and Declarative Purge Preview**

This high-performance utility enables DBAs to audit underlying file system allocation inside managed cloud instances where direct OS access is restricted. It calculates exact directory metrics and processes embedded JSON parameters to provide a secure "Dry-Run" preview of files eligible for deletion under current lifecycle policies.

- **Primary Use Case:** Proactive storage capacity reporting, identifying hidden disk space leaks, and pre-execution validation of automated purge cycles in **Amazon RDS for Oracle**.
- **Key Features:**
  - Aggregates file counts and sizes across dynamic in-memory collections using a lateral `CROSS APPLY` join.
  - Implements a case-sensitive metadata evaluation layer utilizing `JSON_TABLE` to safely preview target cleanup candidates.
  - Utilizes `dbms_xplan.format_size` to output complex byte allocations into highly readable execution summaries.

---

## 📋 Prerequisites & Requirements
To ensure the successful execution of these scripts, verify the following:

- **Database Permissions:** Users must have `SELECT` privileges on `DBA_OBJECTS`. If administrative access is restricted, replace `DBA_OBJECTS` with `ALL_OBJECTS` in the script.
- **Oracle Version:** Full compatibility with **Oracle Database 11g through 23c**.
- **Environment:** Access to source and target schemas within the same database instance.

---

## 🚀 Getting Started
1. **Clone the repo:** `git clone https://github.com/orclkit/oracle-dba-toolkit`
2. **Execution:** Run scripts via **SQL Developer**, **TOAD**, or **SQL*Plus**.
3. **Configuration:** Update the `OWNER` filter in the `WHERE` clause:
   - `src.owner = 'SOURCE_SCHEMA'`
   - `trg.owner = 'TARGET_SCHEMA'`

---

## 🛠️ Troubleshooting Common Issues


| Issue | Potential Cause | Recommended Fix |
| :--- | :--- | :--- |
| **Empty Result Set** | Status mismatch | Ensure source objects are in `INVALID` status before running. |
| **ORA-00942** | Missing Privileges | Use `ALL_OBJECTS` or request `SELECT_CATALOG_ROLE`. |
| **No Matches Found** | Case Sensitivity | Schema names must be **UPPERCASE** (e.g., `'ADMIN'`, not `'admin'`). |
| **Performance Lag** | Dictionary Size | Filter by `OBJECT_TYPE` (e.g., `'PACKAGE'`) to reduce join overhead. |
| **ORA-19279** | XML Sequence Mismatch | Ensure the query uses `string-join()` for patches affecting multiple components. |
| **Empty "target_ru"** | Legacy Patches | Older patches in the registry (pre-12c style) may lack XML attributes; check `description` instead. |
| **ORA-01031** | Insufficient Privileges | User requires `SELECT` on `DBA_REGISTRY_SQLPATCH` (usually granted via `DBA` role). |
| **Inaccurate Version** | Inventory Sync Delay | On RDS, wait 30-60 minutes after maintenance for the XML descriptor to fully populate. |
---

## 📂 Project Structure
- `scripts/`: Production-ready SQL utilities for maintenance and auditing.
- `article/`: In-depth guides on Oracle source extraction and DBA best practices.
- `images/`: Technical diagrams and query result demonstrations.

## 👨‍💻 Portfolio & Contact
Expert in **Oracle Database Administration**, specializing in automation, high-availability, and performance tuning.

**Star this repo** if these scripts help your daily workflow!
