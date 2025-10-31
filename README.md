# Assignment 9: Docker Compose, PostgreSQL, and SQL Operations

[![CI/CD](https://github.com/Rajat-njit/module-9/actions/workflows/test.yml/badge.svg)](https://github.com/Rajat-njit/module-9/actions/workflows/test.yml)

## 📚 Project Overview

This project demonstrates a comprehensive understanding of containerized application development, focusing on Docker Compose orchestration, PostgreSQL database management, and SQL operations. The assignment showcases the integration of FastAPI, PostgreSQL, and pgAdmin in a multi-container environment, emphasizing modern DevOps practices and database relationship design.

**Course:** Python for Web Development  
**Institution:** New Jersey Institute of Technology  
**Focus Areas:** Containerization, Database Operations, SQL, CI/CD

## 🎯 Learning Objectives Achieved

- **Container Orchestration**: Successfully configured and deployed multi-service Docker Compose architecture
- **Database Management**: Implemented PostgreSQL with proper schema design and referential integrity
- **SQL Proficiency**: Demonstrated CRUD operations, JOIN queries, and database relationships
- **DevOps Practices**: Established CI/CD pipeline with automated testing, security scanning, and deployment
- **Security Awareness**: Conducted vulnerability assessments with documented risk analysis

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                Docker Compose Network                │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │   FastAPI    │  │  PostgreSQL  │  │  pgAdmin  │ │
│  │  Container   │  │   Container  │  │ Container │ │
│  │  Port: 8000  │  │  Port: 5432  │  │Port: 5050 │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
│         │                  │                │       │
│         └──────────────────┴────────────────┘       │
│              app-network (bridge)                   │
└─────────────────────────────────────────────────────┘
```

### Service Components

**1. FastAPI Application (`web`)**
- Modern Python web framework
- Automatic API documentation
- Asynchronous request handling
- Connected to PostgreSQL via SQLAlchemy

**2. PostgreSQL Database (`db`)**
- Version: PostgreSQL 16
- Persistent data storage with Docker volumes
- Health checks for service reliability
- Configured with application-specific database (`fastapi_db`)

**3. pgAdmin (`pgadmin`)**
- Web-based database administration interface
- Visual query tool for SQL operations
- Database schema visualization
- Connection management for multiple servers

## Quick Start

### Prerequisites

- Docker Desktop installed and running
- Git for version control
- 4GB RAM minimum
- 10GB free disk space

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/rajatpednekar/assignment_9_is601.git
   cd assignment_9_is601
   ```

2. **Start all services**
   ```bash
   docker-compose up --build
   ```

3. **Verify services are running**
   ```bash
   docker ps
   ```
   
   You should see three containers running:
   - `fastapi_calculator` (web application)
   - `postgres_db` (database)
   - `pgadmin` (admin interface)

### Accessing Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **FastAPI** | http://localhost:8000 | N/A |
| **API Docs** | http://localhost:8000/docs | N/A |
| **pgAdmin** | http://localhost:5050 | Email: `admin@example.com`<br>Password: `admin` |
| **PostgreSQL** | localhost:5432 | User: `postgres`<br>Password: `postgres`<br>Database: `fastapi_db` |

## 🗄️ Database Schema

### Tables Structure

**Users Table**
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Calculations Table** (One-to-Many with Users)
```sql
CREATE TABLE calculations (
    id SERIAL PRIMARY KEY,
    operation VARCHAR(20) NOT NULL,
    operand_a FLOAT NOT NULL,
    operand_b FLOAT NOT NULL,
    result FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Relationship Design

The database implements a **one-to-many relationship**:
- One user can have multiple calculations
- Foreign key constraint ensures referential integrity
- CASCADE deletion automatically removes calculations when user is deleted

## Database Operations Walkthrough

### Connecting to PostgreSQL via pgAdmin

**Step 1: Access pgAdmin Interface**
1. Navigate to http://localhost:5050 in your web browser
2. Login with credentials: `admin@example.com` / `admin`
3. You'll see the pgAdmin dashboard with a clean interface

**Step 2: Register PostgreSQL Server**
1. Right-click **"Servers"** in the left sidebar
2. Select **Register → Server**
3. In the **General** tab:
   - Name: `FastAPI Database` (or any descriptive name)
4. In the **Connection** tab:
   - Host: `db` ⚠️ (Important: Use service name, NOT localhost)
   - Port: `5432`
   - Maintenance database: `postgres`
   - Username: `postgres`
   - Password: `postgres`
   - Save password: ✓ (optional, for convenience)
5. Click **Save**

**Why "db" and not "localhost"?**  
Inside Docker's network, containers communicate using service names defined in `docker-compose.yml`. The hostname `db` resolves to the PostgreSQL container's internal IP address. Using `localhost` would try to connect to pgAdmin's own container, causing connection failures.

**Step 3: Navigate to Database**
1. Expand: **Servers → FastAPI Database → Databases**
2. You should see `fastapi_db` database
3. Right-click `fastapi_db` → **Query Tool**

Now you're ready to execute SQL commands!

### SQL Operations Step-by-Step

#### 1. CREATE - Building Database Structure

**Creating Users Table:**
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**What This Does:**
- `SERIAL PRIMARY KEY`: Auto-incrementing unique identifier (1, 2, 3...)
- `VARCHAR(50)`: Text field with maximum 50 characters
- `NOT NULL`: Field cannot be empty
- `UNIQUE`: No duplicate usernames or emails allowed
- `DEFAULT CURRENT_TIMESTAMP`: Automatically records creation time

**Creating Calculations Table:**
```sql
CREATE TABLE calculations (
    id SERIAL PRIMARY KEY,
    operation VARCHAR(20) NOT NULL,
    operand_a FLOAT NOT NULL,
    operand_b FLOAT NOT NULL,
    result FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

**Key Features:**
- `FOREIGN KEY`: Links `user_id` to `users` table's `id`
- `REFERENCES users(id)`: Enforces relationship (user must exist)
- `ON DELETE CASCADE`: Deleting a user automatically deletes their calculations
- This creates a **one-to-many relationship** (one user, many calculations)

**Execution:**
1. Paste SQL into pgAdmin Query Tool
2. Click the **Execute/Run** button (▶️) or press F5
3. Success message: "Query returned successfully: 2 rows affected"

#### 2. INSERT - Adding Data

**Inserting Users:**
```sql
INSERT INTO users (username, email) 
VALUES 
    ('alice', 'alice@example.com'), 
    ('bob', 'bob@example.com');
```

**What Happens:**
- Two users inserted in one statement (efficient)
- `id` automatically generated: alice=1, bob=2
- `created_at` automatically set to current timestamp
- Database enforces UNIQUE constraint (duplicate usernames/emails will fail)

**Inserting Calculations:**
```sql
INSERT INTO calculations (operation, operand_a, operand_b, result, user_id)
VALUES
    ('add', 2, 3, 5, 1),
    ('divide', 10, 2, 5, 1),
    ('multiply', 4, 5, 20, 2);
```

**Data Relationships:**
- Calculations 1 & 2: Belong to Alice (user_id=1)
- Calculation 3: Belongs to Bob (user_id=2)
- Demonstrates one-to-many: Alice has 2 calculations, Bob has 1

**Foreign Key Protection:**
Try inserting with `user_id=999` - it will fail! The foreign key constraint ensures you can't create calculations for non-existent users.

#### 3. READ - Querying Data

**Simple Query - All Users:**
```sql
SELECT * FROM users;
```

**Results:**
| id | username | email | created_at |
|----|----------|-------|------------|
| 1 | alice | alice@example.com | 2025-10-31 02:00:00 |
| 2 | bob | bob@example.com | 2025-10-31 02:00:00 |

**Simple Query - All Calculations:**
```sql
SELECT * FROM calculations;
```

**Results:**
| id | operation | operand_a | operand_b | result | timestamp | user_id |
|----|-----------|-----------|-----------|--------|-----------|---------|
| 1 | add | 2 | 3 | 5 | 2025-10-31 02:00:01 | 1 |
| 2 | divide | 10 | 2 | 5 | 2025-10-31 02:00:01 | 1 |
| 3 | multiply | 4 | 5 | 20 | 2025-10-31 02:00:01 | 2 |

**Advanced Query - JOIN Operation:**
```sql
SELECT u.username, c.operation, c.operand_a, c.operand_b, c.result
FROM calculations c
JOIN users u ON c.user_id = u.id;
```

**Results:**
| username | operation | operand_a | operand_b | result |
|----------|-----------|-----------|-----------|--------|
| alice | add | 2 | 3 | 5 |
| alice | divide | 10 | 2 | 5 |
| bob | multiply | 4 | 5 | 20 |

**How JOIN Works:**
1. Start with `calculations` table (aliased as `c`)
2. For each calculation row, look up the matching user
3. Match condition: `c.user_id = u.id`
4. Combine columns from both tables
5. Result shows human-readable usernames instead of just user IDs

**Why This Matters:**
- **Normalization**: Username stored once in `users` table
- **Efficiency**: Avoid data duplication
- **Consistency**: Update username in one place, reflects everywhere
- **Relationships**: See connections between data entities

#### 4. UPDATE - Modifying Data

**Correcting a Calculation Result:**
```sql
UPDATE calculations
SET result = 6
WHERE id = 1;
```

**What This Does:**
- Changes calculation id=1 (Alice's addition: 2+3)
- Old result: 5 → New result: 6 (simulating a correction)
- `WHERE` clause is CRITICAL: Without it, ALL rows would be updated!

**Best Practice Workflow:**
```sql
-- Step 1: Preview what will be updated
SELECT * FROM calculations WHERE id = 1;

-- Step 2: Perform the update
UPDATE calculations SET result = 6 WHERE id = 1;

-- Step 3: Verify the change
SELECT * FROM calculations WHERE id = 1;
```

**Verification:**
```sql
SELECT * FROM calculations WHERE id = 1;
```
Now shows `result = 6`

#### 5. DELETE - Removing Data

**Deleting a Specific Calculation:**
```sql
DELETE FROM calculations
WHERE id = 2;
```

**What Happens:**
- Removes calculation id=2 (Alice's divide operation: 10/2=5)
- Permanently deleted (no undo unless you have backups)
- `WHERE` clause prevents accidentally deleting all rows

**Verification:**
```sql
SELECT * FROM calculations;
```

**Results After Deletion:**
| id | operation | operand_a | operand_b | result | user_id |
|----|-----------|-----------|-----------|--------|---------|
| 1 | add | 2 | 3 | 6 | 1 |
| 3 | multiply | 4 | 5 | 20 | 2 |

**Notice:** ID gap (1, 3) - ID 2 is gone. PostgreSQL doesn't reuse SERIAL IDs.

**CASCADE DELETE Demonstration:**
If you were to delete a user:
```sql
DELETE FROM users WHERE id = 1;  -- Deletes Alice
```

**Cascading Effect:**
- Alice (user id=1) is deleted
- Automatically deletes calculation id=1 (due to `ON DELETE CASCADE`)
- Maintains referential integrity (no orphaned calculations)
- Bob's data (user id=2, calculation id=3) remains untouched

### pgAdmin Features Used

**Query Tool:**
- Syntax highlighting for SQL keywords
- Execute button (▶️) or F5 keyboard shortcut
- Results displayed in grid format
- Export options (CSV, JSON, etc.)
- Query history tracking

**Data Viewing:**
- Right-click table → **View/Edit Data** → **All Rows**
- Visual representation of table contents
- Inline editing capabilities
- Filter and sort options

**Schema Visualization:**
- Expand tables to see columns
- View constraints and indexes
- Check foreign key relationships
- ERD (Entity Relationship Diagram) generation

**Administration Features:**
- User management
- Backup and restore
- Performance monitoring
- Query execution plans

## 🔐 Security & CI/CD

### Automated Pipeline

**GitHub Actions Workflow:**
1. **Test Job**: Validates dependencies and PostgreSQL connectivity
2. **Security Job**: Trivy vulnerability scanning with documented exceptions
3. **Deploy Job**: Multi-platform Docker image build and push to Docker Hub

### Security Posture

**Active Measures:**
- Automated vulnerability scanning on every commit
- Container isolation with dedicated networks
- Non-root user execution in containers
- Secure credential management via GitHub Secrets
- Health checks for service monitoring

**Documented Exceptions:**
- CVE-2025-43859 (h11): Dependency conflict with httpcore
- CVE-2025-62727 (Starlette): Incompatibility with FastAPI stable version

All exceptions include:
- Technical justification
- Risk assessment
- Mitigation strategies
- Review schedule

## 📦 Docker Hub

**Image Repository:** [rajatpednekar/assignment_9](https://hub.docker.com/r/rajatpednekar/assignment_9)

**Available Tags:**
- `latest`: Most recent stable build
- `{commit-sha}`: Specific commit versions

## 🛠️ Development

### Local Development Setup

```bash
# Install dependencies locally (optional)
pip install -r requirements.txt

# Run tests (if available)
pytest tests/

# Access database directly
docker exec -it postgres_db psql -U postgres -d fastapi_db
```

### Stopping Services

```bash
# Stop all containers
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## 📊 Key Features

✅ **Multi-Container Orchestration**: Seamless service communication via Docker networking  
✅ **Data Persistence**: PostgreSQL data survives container restarts  
✅ **Health Monitoring**: Automated health checks ensure service availability  
✅ **Auto-Reload**: FastAPI automatically reloads on code changes  
✅ **Visual Administration**: pgAdmin provides intuitive database management  
✅ **CI/CD Integration**: Automated testing, security scanning, and deployment  
✅ **Multi-Platform**: Images work on both AMD64 and ARM64 architectures


##  Troubleshooting

**Problem:** Cannot connect to Docker daemon  
**Solution:** Start Docker Desktop application and wait for it to fully initialize

**Problem:** Port already in use  
**Solution:** Stop conflicting services or modify port mappings in docker-compose.yml

**Problem:** pgAdmin shows "could not connect to server"  
**Solution:** Use hostname `db` (not `localhost`) when connecting to PostgreSQL

**Problem:** PostgreSQL volume conflict  
**Solution:** Run `docker-compose down -v` to remove old volumes and rebuild

##  Resources & References

- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Official Docs](https://www.postgresql.org/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)

## 👤 Author

**Rajat Pednekar**  
New Jersey Institute of Technology  
Course: Python for Web Development  
Assignment: Module 9 - Docker Compose and Database Integration
