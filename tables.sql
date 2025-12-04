-- Enhanced Database Schema with Triggers, Views, Indexes and GitHub Link
CREATE DATABASE IF NOT EXISTS project_repo;
USE project_repo;

-- ========================================
-- TABLE DEFINITIONS
-- ========================================

CREATE TABLE IF NOT EXISTS departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(128) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admins (
  admin_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS guides (
  guide_id INT AUTO_INCREMENT PRIMARY KEY,
  guide_name VARCHAR(255) NOT NULL,
  department_id INT,
  designation VARCHAR(128),
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
  INDEX idx_guide_department (department_id),
  INDEX idx_guide_name (guide_name)
);

CREATE TABLE IF NOT EXISTS students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  roll_number VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  department_id INT,
  batch VARCHAR(64),
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
  INDEX idx_student_department (department_id),
  INDEX idx_student_batch (batch),
  INDEX idx_student_roll (roll_number)
);

CREATE TABLE IF NOT EXISTS projects (
  project_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  guide_id INT,
  department_id INT,
  member_type ENUM('individual','group') NOT NULL DEFAULT 'individual',
  project_type ENUM('semester','final_year') NOT NULL DEFAULT 'semester',
  github_link VARCHAR(512),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (guide_id) REFERENCES guides(guide_id) ON DELETE SET NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
  INDEX idx_project_guide (guide_id),
  INDEX idx_project_department (department_id),
  INDEX idx_project_type (project_type),
  INDEX idx_project_member_type (member_type)
);

CREATE TABLE IF NOT EXISTS project_students (
  project_student_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT,
  student_id INT,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  UNIQUE KEY project_student_unique (project_id, student_id),
  INDEX idx_ps_project (project_id),
  INDEX idx_ps_student (student_id)
);

CREATE TABLE IF NOT EXISTS internships (
  internship_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT,
  student_id INT,
  company_name VARCHAR(255),
  duration VARCHAR(128),
  domain VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  UNIQUE KEY internship_unique (project_id, student_id),
  INDEX idx_internship_project (project_id),
  INDEX idx_internship_student (student_id),
  INDEX idx_internship_company (company_name)
);

-- Audit Log Table for tracking changes
CREATE TABLE IF NOT EXISTS project_audit_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT,
  action VARCHAR(50),
  old_value TEXT,
  new_value TEXT,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
  INDEX idx_audit_project (project_id),
  INDEX idx_audit_date (changed_at)
);

-- ========================================
-- VIEWS
-- ========================================

-- View: Complete Project Details with Guide and Department
CREATE OR REPLACE VIEW vw_project_details AS
SELECT 
  p.project_id,
  p.title,
  p.description,
  p.project_type,
  p.member_type,
  p.github_link,
  p.created_at,
  g.guide_id,
  g.guide_name,
  g.designation,
  d.department_id,
  d.name AS department_name,
  (SELECT COUNT(*) FROM project_students ps WHERE ps.project_id = p.project_id) AS student_count
FROM projects p
LEFT JOIN guides g ON p.guide_id = g.guide_id
LEFT JOIN departments d ON p.department_id = d.department_id;

-- View: Student Project Assignments
CREATE OR REPLACE VIEW vw_student_projects AS
SELECT 
  s.student_id,
  s.roll_number,
  s.name AS student_name,
  s.batch,
  sd.name AS student_department,
  p.project_id,
  p.title AS project_title,
  p.project_type,
  p.member_type,
  p.github_link,
  g.guide_name,
  pd.name AS project_department
FROM students s
LEFT JOIN departments sd ON s.department_id = sd.department_id
LEFT JOIN project_students ps ON s.student_id = ps.student_id
LEFT JOIN projects p ON ps.project_id = p.project_id
LEFT JOIN guides g ON p.guide_id = g.guide_id
LEFT JOIN departments pd ON p.department_id = pd.department_id;

-- View: Guide's Students (All unique students working under a guide)
CREATE OR REPLACE VIEW vw_guide_students AS
SELECT DISTINCT
  g.guide_id,
  g.guide_name,
  s.student_id,
  s.roll_number,
  s.name AS student_name,
  s.batch,
  d.name AS department_name,
  COUNT(DISTINCT ps.project_id) AS projects_count
FROM guides g
JOIN projects p ON g.guide_id = p.guide_id
JOIN project_students ps ON p.project_id = ps.project_id
JOIN students s ON ps.student_id = s.student_id
LEFT JOIN departments d ON s.department_id = d.department_id
GROUP BY g.guide_id, g.guide_name, s.student_id, s.roll_number, s.name, s.batch, d.name;

-- View: Final Year Projects with Internships
CREATE OR REPLACE VIEW vw_final_year_internships AS
SELECT 
  p.project_id,
  p.title,
  p.github_link,
  g.guide_name,
  d.name AS department_name,
  s.roll_number,
  s.name AS student_name,
  i.company_name,
  i.duration,
  i.domain
FROM projects p
JOIN guides g ON p.guide_id = g.guide_id
JOIN departments d ON p.department_id = d.department_id
JOIN project_students ps ON p.project_id = ps.project_id
JOIN students s ON ps.student_id = s.student_id
LEFT JOIN internships i ON p.project_id = i.project_id AND s.student_id = i.student_id
WHERE p.project_type = 'final_year';

-- View: Department Statistics
CREATE OR REPLACE VIEW vw_department_stats AS
SELECT 
  d.department_id,
  d.name AS department_name,
  COUNT(DISTINCT s.student_id) AS total_students,
  COUNT(DISTINCT g.guide_id) AS total_guides,
  COUNT(DISTINCT p.project_id) AS total_projects,
  SUM(CASE WHEN p.project_type = 'final_year' THEN 1 ELSE 0 END) AS final_year_projects,
  SUM(CASE WHEN p.project_type = 'semester' THEN 1 ELSE 0 END) AS semester_projects
FROM departments d
LEFT JOIN students s ON d.department_id = s.department_id
LEFT JOIN guides g ON d.department_id = g.department_id
LEFT JOIN projects p ON d.department_id = p.department_id
GROUP BY d.department_id, d.name;

-- ========================================
-- TRIGGERS
-- ========================================

-- Trigger: Prevent adding more than 1 student to individual projects
DELIMITER //
CREATE TRIGGER trg_check_individual_project
BEFORE INSERT ON project_students
FOR EACH ROW
BEGIN
  DECLARE v_member_type VARCHAR(20);
  DECLARE v_student_count INT;
  
  SELECT member_type INTO v_member_type 
  FROM projects 
  WHERE project_id = NEW.project_id;
  
  IF v_member_type = 'individual' THEN
    SELECT COUNT(*) INTO v_student_count 
    FROM project_students 
    WHERE project_id = NEW.project_id;
    
    IF v_student_count >= 1 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Individual projects can only have one student';
    END IF;
  END IF;
END;//
DELIMITER ;

-- Trigger: Audit log when project is updated
DELIMITER //
CREATE TRIGGER trg_project_update_audit
AFTER UPDATE ON projects
FOR EACH ROW
BEGIN
  IF OLD.title != NEW.title THEN
    INSERT INTO project_audit_log (project_id, action, old_value, new_value)
    VALUES (NEW.project_id, 'TITLE_CHANGED', OLD.title, NEW.title);
  END IF;
  
  IF OLD.github_link != NEW.github_link OR (OLD.github_link IS NULL AND NEW.github_link IS NOT NULL) THEN
    INSERT INTO project_audit_log (project_id, action, old_value, new_value)
    VALUES (NEW.project_id, 'GITHUB_LINK_UPDATED', OLD.github_link, NEW.github_link);
  END IF;
  
  IF OLD.description != NEW.description THEN
    INSERT INTO project_audit_log (project_id, action, old_value, new_value)
    VALUES (NEW.project_id, 'DESCRIPTION_CHANGED', OLD.description, NEW.description);
  END IF;
END;//
DELIMITER ;

-- Trigger: Validate internship only for final year projects
DELIMITER //
CREATE TRIGGER trg_check_internship_project_type
BEFORE INSERT ON internships
FOR EACH ROW
BEGIN
  DECLARE v_project_type VARCHAR(20);
  
  SELECT project_type INTO v_project_type 
  FROM projects 
  WHERE project_id = NEW.project_id;
  
  IF v_project_type != 'final_year' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Internships can only be added to final year projects';
  END IF;
END;//
DELIMITER ;

-- Trigger: Auto-delete internships when project type changes from final_year
DELIMITER //
CREATE TRIGGER trg_cleanup_internships_on_project_type_change
AFTER UPDATE ON projects
FOR EACH ROW
BEGIN
  IF OLD.project_type = 'final_year' AND NEW.project_type != 'final_year' THEN
    DELETE FROM internships WHERE project_id = NEW.project_id;
  END IF;
END;//
DELIMITER ;

-- Trigger: Audit log when student is added to project
DELIMITER //
CREATE TRIGGER trg_student_assigned_audit
AFTER INSERT ON project_students
FOR EACH ROW
BEGIN
  DECLARE v_student_name VARCHAR(255);
  
  SELECT name INTO v_student_name 
  FROM students 
  WHERE student_id = NEW.student_id;
  
  INSERT INTO project_audit_log (project_id, action, old_value, new_value)
  VALUES (NEW.project_id, 'STUDENT_ADDED', NULL, v_student_name);
END;//
DELIMITER ;

-- ========================================
-- STORED PROCEDURES (Bonus)
-- ========================================

-- Procedure: Get all students under a specific guide
DELIMITER //
CREATE PROCEDURE sp_get_guide_students(IN p_guide_id INT)
BEGIN
  SELECT * FROM vw_guide_students 
  WHERE guide_id = p_guide_id 
  ORDER BY student_name;
END;//
DELIMITER ;

-- Procedure: Get project statistics for a guide
DELIMITER //
CREATE PROCEDURE sp_get_guide_project_stats(IN p_guide_id INT)
BEGIN
  SELECT 
    COUNT(*) AS total_projects,
    SUM(CASE WHEN project_type = 'final_year' THEN 1 ELSE 0 END) AS final_year_projects,
    SUM(CASE WHEN project_type = 'semester' THEN 1 ELSE 0 END) AS semester_projects,
    SUM(CASE WHEN member_type = 'group' THEN 1 ELSE 0 END) AS group_projects,
    SUM(CASE WHEN member_type = 'individual' THEN 1 ELSE 0 END) AS individual_projects
  FROM projects
  WHERE guide_id = p_guide_id;
END;//
DELIMITER ;

-- ========================================
-- SAMPLE QUERIES TO TEST VIEWS
-- ========================================

/*
-- Test Views:
SELECT * FROM vw_project_details;
SELECT * FROM vw_student_projects WHERE roll_number = 'CS2021001';
SELECT * FROM vw_guide_students WHERE guide_id = 1;
SELECT * FROM vw_final_year_internships;
SELECT * FROM vw_department_stats;

-- Test Stored Procedures:
CALL sp_get_guide_students(1);
CALL sp_get_guide_project_stats(1);

-- Check audit logs:
SELECT * FROM project_audit_log ORDER BY changed_at DESC;
*/
