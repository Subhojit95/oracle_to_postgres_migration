# 🔄 Oracle to PostgreSQL Database Migration – Academic Management System

## 🚀 Project Overview
This project demonstrates a full-scale migration of an academic management system from Oracle to PostgreSQL, leveraging AWS cloud services and advanced database tooling. It includes schema transformation, PL/SQL object conversion, and real-time replication strategies using AWS Database Migration Service (DMS).

## 🎯 Objectives
- Migrate a complex Oracle-based academic database to PostgreSQL on AWS RDS.
- Convert PL/SQL procedures, functions, and packages to PostgreSQL-compatible equivalents.
- Use AWS DMS for initial data migration and reverse replication for validation and rollback testing.
- Showcase schema redesign, performance optimization, and cloud deployment.

## 🛠️ Tech Stack
| Component            | Description                                      |
|---------------------|--------------------------------------------------|
| **Source DB**        | Oracle 19c                                       |
| **Target DB**        | PostgreSQL 15 on AWS RDS                         |
| **Migration Tool**   | AWS Database Migration Service (DMS)            |
| **Replication**      | Reverse replication for data integrity checks   |
| **Code Conversion**  | PL/SQL to pgSQL (procedures, triggers, packages)|
| **Version Control**  | Git / GitHub                                     |
| **Monitoring**       | AWS CloudWatch, pg_stat_statements              |

## 🧱 Modules Migrated
- **Admissions**: Student records, department mapping.
- **Academics**: Courses, prerequisites, grades, exams, schedules.
- **Faculty & Departments**: Staff profiles, hiring data.
- **Hostel & Library**: Room allocations, book loans.
- **Finance**: Fees, payments, scholarships.
- **Communication**: Notifications, disciplinary actions.

## 🔧 Migration Highlights
- ✅ **Schema Translation**: Oracle `NUMBER`, `VARCHAR2`, `CLOB` mapped to PostgreSQL equivalents.
- ✅ **PL/SQL Conversion**: Refactored packages and procedures using pgSQL and `DO` blocks.
- ✅ **AWS DMS Setup**: 
  - Full load + CDC (Change Data Capture)
  - Source: Oracle on-prem
  - Target: PostgreSQL on AWS RDS
- ✅ **Reverse Replication**: PostgreSQL → Oracle for validation and rollback testing.
- ✅ **Performance Tuning**: Indexing, vacuum strategies, query optimization.

## 📌 Status
- 🚧 Schema conversion and migration in progress  


## 🤝 Contribution & Contact
Suggestions, forks, and feedback are welcome!  
📬 Contact: [iamsubh43@gmail.com]  
🔗 GitHub: [github.com/Subhojit95]
