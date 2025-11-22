CREATE DATABASE IF NOT EXISTS project_repo;
USE project_repo;

CREATE TABLE IF NOT EXISTS departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(128) NOT NULL UNIQUE
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
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  roll_number VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  department_id INT,
  batch VARCHAR(64),
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS projects (
  project_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  guide_id INT,
  department_id INT,
  member_type ENUM('individual','group') NOT NULL DEFAULT 'individual',
  project_type ENUM('semester','final_year') NOT NULL DEFAULT 'semester',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (guide_id) REFERENCES guides(guide_id) ON DELETE SET NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS project_students (
  project_student_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT,
  student_id INT,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  UNIQUE KEY project_student_unique (project_id, student_id)
);

CREATE TABLE IF NOT EXISTS internships (
  internship_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT,
  student_id INT,
  company_name VARCHAR(255),
  duration VARCHAR(128),
  domain VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  UNIQUE KEY internship_unique (project_id, student_id)
);