-- Sample Data Insert Script for Project Repository
-- Matches your exact phpMyAdmin database structure

USE project_repo;

-- Step 1: Insert Departments (MUST BE FIRST - other tables reference this)
INSERT INTO departments (department_id, name) VALUES
(1, 'Computer Science Engineering'),
(2, 'Information Technology'),
(3, 'Electronics and Communication'),
(4, 'Mechanical Engineering'),
(5, 'Civil Engineering');

-- Step 2: Insert Admin (skip if server.js already created it)
INSERT IGNORE INTO admins (username, password) VALUES
('admin@123', 'admin123');

-- Step 3: Insert 10 Guides (using department_id foreign key)
INSERT INTO guides (guide_name, department_id, designation, password) VALUES
('Dr. Rajesh Kumar', 1, 'Professor', 'guide123'),
('Dr. Priya Sharma', 2, 'Associate Professor', 'guide123'),
('Dr. Arun Patel', 3, 'Assistant Professor', 'guide123'),
('Dr. Lakshmi Iyer', 1, 'Professor', 'guide123'),
('Dr. Vikram Singh', 2, 'Associate Professor', 'guide123'),
('Dr. Meena Krishnan', 4, 'Assistant Professor', 'guide123'),
('Dr. Karthik Reddy', 1, 'Professor', 'guide123'),
('Dr. Divya Menon', 3, 'Associate Professor', 'guide123'),
('Dr. Suresh Nair', 5, 'Professor', 'guide123'),
('Dr. Anita Desai', 2, 'Assistant Professor', 'guide123');

-- Step 4: Insert 10 Students (using department_id foreign key)
INSERT INTO students (roll_number, name, department_id, batch, password) VALUES
('CS2021001', 'Aarav Kapoor', 1, '2021', 'student123'),
('IT2021002', 'Diya Malhotra', 2, '2021', 'student123'),
('EC2021003', 'Arjun Mehta', 3, '2021', 'student123'),
('CS2021004', 'Isha Gupta', 1, '2021', 'student123'),
('IT2021005', 'Rohan Verma', 2, '2021', 'student123'),
('ME2021006', 'Ananya Rao', 4, '2021', 'student123'),
('CS2022007', 'Vivaan Shah', 1, '2022', 'student123'),
('EC2022008', 'Saanvi Joshi', 3, '2022', 'student123'),
('CE2022009', 'Aditya Pillai', 5, '2022', 'student123'),
('IT2022010', 'Kavya Nambiar', 2, '2022', 'student123');

-- Step 5: Insert Projects (using guide_id and department_id foreign keys)
-- Mix of semester and final_year projects, individual and group
INSERT INTO projects (title, description, guide_id, department_id, member_type, project_type) VALUES
-- Final Year Projects (for internships)
('AI-Based Healthcare System', 'Machine learning system for disease prediction and diagnosis', 1, 1, 'individual', 'final_year'),
('Smart City IoT Platform', 'IoT-based smart city monitoring and management solution', 2, 2, 'group', 'final_year'),
('5G Network Simulator', 'Advanced 5G network simulation and testing tool', 3, 3, 'individual', 'final_year'),
('E-Commerce Recommendation Engine', 'Personalized product recommendation system using ML', 4, 1, 'group', 'final_year'),
('Cloud-Based ERP System', 'Enterprise resource planning system on cloud infrastructure', 5, 2, 'individual', 'final_year'),

-- Semester Projects
('Library Management System', 'Web-based library management application with book tracking', 6, 4, 'individual', 'semester'),
('Student Attendance Tracker', 'Mobile app for tracking student attendance with QR codes', 7, 1, 'group', 'semester'),
('Digital Signal Processing Tool', 'MATLAB-based signal processing toolkit for audio analysis', 8, 3, 'individual', 'semester'),
('Construction Project Manager', 'Project management tool for construction site monitoring', 9, 5, 'group', 'semester'),
('Online Exam Portal', 'Secure online examination system with proctoring', 10, 2, 'individual', 'semester');

-- Step 6: Map Students to Projects (project_students table)
INSERT INTO project_students (project_id, student_id) VALUES
-- Final Year Projects
(1, 1),   -- Aarav -> AI Healthcare (individual)
(2, 2),   -- Diya -> Smart City IoT (group member 1)
(2, 5),   -- Rohan -> Smart City IoT (group member 2)
(3, 3),   -- Arjun -> 5G Simulator (individual)
(4, 4),   -- Isha -> E-Commerce Engine (group member 1)
(4, 7),   -- Vivaan -> E-Commerce Engine (group member 2)
(5, 10),  -- Kavya -> Cloud ERP (individual)

-- Semester Projects
(6, 6),   -- Ananya -> Library Management (individual)
(7, 7),   -- Vivaan -> Attendance Tracker (group member)
(7, 1),   -- Aarav -> Attendance Tracker (group member)
(8, 8),   -- Saanvi -> DSP Tool (individual)
(9, 9),   -- Aditya -> Construction Manager (group member)
(9, 3),   -- Arjun -> Construction Manager (group member)
(10, 10); -- Kavya -> Online Exam Portal (individual)

-- Step 7: Insert Internship Details (ONLY for Final Year Projects)
INSERT INTO internships (project_id, student_id, company_name, duration, domain) VALUES
(1, 1, 'Google India', '6 months', 'Artificial Intelligence & Machine Learning'),
(2, 2, 'Infosys Limited', '6 months', 'IoT & Cloud Computing'),
(2, 5, 'Tata Consultancy Services', '6 months', 'IoT & Smart Cities'),
(3, 3, 'Qualcomm India', '5 months', '5G Technology & Wireless Communication'),
(4, 4, 'Amazon Development Centre', '6 months', 'Machine Learning & Recommendations'),
(4, 7, 'Flipkart', '6 months', 'E-Commerce Technology & Analytics'),
(5, 10, 'Microsoft India', '6 months', 'Cloud Computing & Azure Services');

-- ========================================
-- VERIFICATION QUERIES (Optional - run these to verify your data)
-- ========================================

-- Check total counts
-- SELECT COUNT(*) as total_departments FROM departments;
-- SELECT COUNT(*) as total_admins FROM admins;
-- SELECT COUNT(*) as total_guides FROM guides;
-- SELECT COUNT(*) as total_students FROM students;
-- SELECT COUNT(*) as total_projects FROM projects;
-- SELECT COUNT(*) as total_internships FROM internships;

-- View all students with their department names
-- SELECT s.roll_number, s.name, d.name as department, s.batch 
-- FROM students s 
-- LEFT JOIN departments d ON s.department_id = d.department_id;

-- View all guides with their department names
-- SELECT g.guide_name, d.name as department, g.designation 
-- FROM guides g 
-- LEFT JOIN departments d ON g.department_id = d.department_id;

-- View all projects with guide and department info
-- SELECT p.title, p.project_type, p.member_type, g.guide_name, d.name as department
-- FROM projects p
-- LEFT JOIN guides g ON p.guide_id = g.guide_id
-- LEFT JOIN departments d ON p.department_id = d.department_id;

-- View project-student mappings
-- SELECT p.title, s.roll_number, s.name as student_name
-- FROM projects p
-- JOIN project_students ps ON p.project_id = ps.project_id
-- JOIN students s ON ps.student_id = s.student_id
-- ORDER BY p.title;

-- View internship details
-- SELECT p.title, s.roll_number, s.name, i.company_name, i.duration, i.domain
-- FROM internships i
-- JOIN projects p ON i.project_id = p.project_id
-- JOIN students s ON i.student_id = s.student_id;

-- ========================================
-- LOGIN CREDENTIALS FOR TESTING
-- ========================================
/*
ADMIN LOGIN:
- Role: admin
- Username: admin@123
- Password: admin123

GUIDE LOGINS (all password: guide123):
- Dr. Rajesh Kumar
- Dr. Priya Sharma
- Dr. Arun Patel
- Dr. Lakshmi Iyer
- Dr. Vikram Singh
- Dr. Meena Krishnan
- Dr. Karthik Reddy
- Dr. Divya Menon
- Dr. Suresh Nair
- Dr. Anita Desai

STUDENT LOGINS (all password: student123):
- CS2021001 (Aarav Kapoor)
- IT2021002 (Diya Malhotra)
- EC2021003 (Arjun Mehta)
- CS2021004 (Isha Gupta)
- IT2021005 (Rohan Verma)
- ME2021006 (Ananya Rao)
- CS2022007 (Vivaan Shah)
- EC2022008 (Saanvi Joshi)
- CE2022009 (Aditya Pillai)
- IT2022010 (Kavya Nambiar)
*/