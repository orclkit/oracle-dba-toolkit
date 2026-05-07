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

---

## 📂 Project Structure
- `scripts/`: Production-ready SQL utilities for maintenance and auditing.
- `article/`: In-depth guides on Oracle source extraction and DBA best practices.
- `images/`: Technical diagrams and query result demonstrations.

## 👨‍💻 Portfolio & Contact
Expert in **Oracle Database Administration**, specializing in automation, high-availability, and performance tuning.

**Star this repo** if these scripts help your daily workflow!
