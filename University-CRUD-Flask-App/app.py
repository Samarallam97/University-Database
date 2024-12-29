from flask import Flask, request, render_template
import pyodbc

app = Flask(__name__)

DRIVER_NAME = 'SQL Server'
SERVER_NAME = '.'
DATABASE_NAME = 'University_'

conn = pyodbc.connect(
    f'Driver={{{DRIVER_NAME}}};'
    f'Server={SERVER_NAME};'
    f'Database={DATABASE_NAME};'
    'Trusted_Connection=yes;'
)

cursor = conn.cursor()

@app.route('/')
def index():
    return render_template('index.html') # ALL Entities


# Database Methods For Student


def add_student_in_database(cursor, conn, st_name, st_gender, st_address, st_phone, st_dob, st_email, department_id, level_id, scholar_id):
    query = '''
        EXEC setStudent @StudName = ?, @DOB = ?, @Gender = ?, 
                        @Address = ?, @phone = ?, @Email = ?, 
                        @DeptId = ?, @LevelId = ?, @ScholarId = ?
    '''
    cursor.execute(query, (st_name, st_dob, st_gender, st_address, st_phone, st_email, department_id, level_id, scholar_id))
    conn.commit()

def update_student_in_database(cursor, conn, name, gender, address, phone, dob, email, department_id, level_id, student_id, scholar_id):
    query = """
        EXEC UpdateStudent @studId = ?, @StudName = ?, @Address = ?, @Email = ?, 
                           @phone = ?, @Gender = ?, @DOB = ?, @DeptId = ?, 
                           @LevelId = ?, @ScholarId = ?
    """
    cursor.execute(query, (student_id, name, address, email, phone, gender, dob, department_id, level_id, scholar_id))
    conn.commit()

def delete_student_from_database(cursor, conn, student_id):
    query = "EXEC DeleteStudent @studId = ?"
    cursor.execute(query, (student_id,))
    conn.commit()

def search_student_with_id_in_database(cursor , id) :
    query = \
    f''' EXEC GetOneStudent @studId = {id}'''
    cursor.execute(query)
    student = cursor.fetchone()
    return student

def search_student_with_name_in_database(cursor, keyword):
    query = """
        EXEC GetStudentWithName @studName = ?
    """
    cursor.execute(query, (keyword,))
    results = cursor.fetchall()
    return results

def search_students_with_grade(cursor, level_id, course_id, grade):
    query = """
        EXEC GetStudWithGrade @grade = ?, @courseId = ?, @levelId = ?
    """
    cursor.execute(query, (grade, course_id, level_id))
    results = cursor.fetchall()
    return results

def read_all_students_from_database(cursor):
    query = '''
        EXEC GetAllStudents
    '''
    cursor.execute(query)
    results = cursor.fetchall()
    return results

def read_all_levels_from_database(cursor) :
    query = '''
        EXEC Getlevel;
    '''
    cursor.execute(query)
    results = cursor.fetchall()
    return results

def read_all_schoraships_from_database(cursor) :
    query = '''    
        EXEC GetScholarships
    '''
    cursor.execute(query)
    results = cursor.fetchall()
    return results

def read_all_departments_from_database(cursor) :
    query = '''
        EXEC GetDepartments
    '''
    cursor.execute(query)
    results = cursor.fetchall()
    return results

def read_all_courses_from_database(cursor) :
    query = '''
       EXEC GetCoursec
    '''
    cursor.execute(query)
    results = cursor.fetchall()
    return results


Levels = read_all_levels_from_database(cursor)
Schoraships = read_all_schoraships_from_database(cursor)
Departments = read_all_departments_from_database(cursor)
Courses = read_all_courses_from_database(cursor)

# Routes Methods For Student

# Table

@app.route('/StudentTable' ,methods=['GET']) # in index
def student_table() :
    if request.method == 'GET':
        results = read_all_students_from_database(cursor)
        return render_template('StudentTable.html', students=results , levels = Levels , courses = Courses )

# Add

@app.route('/AddStudentForm') # add btn
def show_add_student_form() :
    return render_template('AddStudentForm.html' , levels =Levels , schoraships = Schoraships , departments = Departments)


@app.route('/AddNewStudent', methods=['POST'])
def add_new_student():
    if request.method == 'POST':
        
        st_name = request.form['name']
        st_gender = request.form['gender'] 
        st_address = request.form['address'] 
        st_phone = request.form['phone']
        st_dob = request.form['dob'] 
        st_email = request.form['email'] 
        department_id = request.form['department_id'] 
        level_id =  request.form['level_id']
        scholar_id =  request.form['scholar_id']

        add_student_in_database(cursor, conn , st_name,st_gender , st_address , st_phone , st_dob ,st_email , department_id , level_id , scholar_id)
        
        students = read_all_students_from_database(cursor)
        return render_template('StudentTable.html', students=students , levels = Levels , courses = Courses )


# Update

@app.route('/edit_student/<int:student_id>')
def show_edit_student_form(student_id) :
    student = search_student_with_id_in_database(cursor , student_id)
    return render_template('EditStudetForm.html', student=student , levels =Levels , schoraships = Schoraships , departments = Departments)


@app.route('/SaveStudent/<int:student_id>', methods=['POST'])
def save_student(student_id) :
    name = request.form['name']
    gender = request.form['gender']
    address = request.form['address']
    phone = request.form['phone']
    dob = request.form['dob']
    email = request.form['email']
    department_id = int(request.form['department_id'])
    level_id = int(request.form['level_id'])
    schoraship_id = int(request.form['schoraship_id'])


    update_student_in_database(cursor , conn ,name, gender, address, phone, dob, email, department_id, level_id, student_id , schoraship_id)
    
    results = read_all_students_from_database(cursor);
    return render_template('StudentTable.html', students=results , levels = Levels , courses = Courses )


# Delete

@app.route('/delete_student/<int:student_id>' , methods=['GET'])
def delete_student(student_id):

    delete_student_from_database(cursor, conn, student_id)

    results = read_all_students_from_database(cursor)
    return render_template('StudentTable.html', students=results , levels = Levels , courses = Courses )
    
# Search 


@app.route('/SearchStudentWithName', methods=['GET'])
def search_with_name():
    if request.method == 'GET':
        keyword = request.args.get('searchName')
        results = search_student_with_name_in_database(cursor, keyword)
        return render_template('StudentTable.html', students=results , levels = Levels , courses = Courses )

# Top students

@app.route('/TopStudentsWithGrade', methods=['GET'])
def students_with_grades() :
    if request.method == 'GET':
        level_id = request.args.get('level_id')
        course_id = request.args.get('course_id')
        grade = request.args.get('grade')

        results = search_students_with_grade(cursor , level_id, course_id, grade )
        return render_template('StudentTable.html', students=results , levels = Levels , courses = Courses )


app.run(debug=True)
cursor.close()
conn.close()