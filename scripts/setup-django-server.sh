#!/bin/bash
set -e
set -u

PROJECT_DIR="sentinel-matrix-server"
ENV_DIR="sentinel-env"
DJANGO_PROJECT="sentinelproject"
DJANGO_APP="sentinelapi"

if [ -d "$PROJECT_DIR" ]; then
  echo "Error: $PROJECT_DIR already exists."
  exit 1
fi

mkdir "$PROJECT_DIR"
cd "$PROJECT_DIR"

python3 -m venv "$ENV_DIR"
source "$ENV_DIR/bin/activate"

cat > requirements.txt <<'EOF'
asgiref==3.11.1
Django==6.0.6
django-cors-headers==4.9.0
django-safedelete==1.4.1
djangorestframework==3.17.1
packaging==26.2
pillow==12.2.0
setuptools==82.0.1
sqlparse==0.5.5
EOF

pip install --upgrade pip
pip install -r requirements.txt

django-admin startproject "$DJANGO_PROJECT" .
python manage.py startapp "$DJANGO_APP"

mkdir -p "$DJANGO_APP/fixtures"
mkdir -p "$DJANGO_APP/models"
mkdir -p "$DJANGO_APP/views"
mkdir -p "$DJANGO_APP/tests"
mkdir -p dev-docs
mkdir -p templates
mkdir -p media

touch "$DJANGO_APP/models/__init__.py"
touch "$DJANGO_APP/views/__init__.py"
touch "$DJANGO_APP/tests/__init__.py"

touch "$DJANGO_APP/models/user.py"
touch "$DJANGO_APP/models/course.py"
touch "$DJANGO_APP/models/student.py"
touch "$DJANGO_APP/models/enrollment.py"
touch "$DJANGO_APP/models/assessment.py"
touch "$DJANGO_APP/models/student_assessment.py"
touch "$DJANGO_APP/models/assessment_type.py"

touch "$DJANGO_APP/views/auth.py"
touch "$DJANGO_APP/views/course.py"
touch "$DJANGO_APP/views/student.py"
touch "$DJANGO_APP/views/enrollment.py"
touch "$DJANGO_APP/views/assessment.py"
touch "$DJANGO_APP/views/student_assessment.py"
touch "$DJANGO_APP/views/assessment_type.py"

touch "$DJANGO_APP/tests/test_auth.py"
touch "$DJANGO_APP/tests/test_courses.py"
touch "$DJANGO_APP/tests/test_students.py"
touch "$DJANGO_APP/tests/test_enrollments.py"
touch "$DJANGO_APP/tests/test_assessments.py"
touch "$DJANGO_APP/tests/test_risk_score.py"

touch "$DJANGO_APP/fixtures/users.json"
touch "$DJANGO_APP/fixtures/tokens.json"
touch "$DJANGO_APP/fixtures/courses.json"
touch "$DJANGO_APP/fixtures/students.json"
touch "$DJANGO_APP/fixtures/enrollments.json"
touch "$DJANGO_APP/fixtures/assessment_types.json"
touch "$DJANGO_APP/fixtures/assessments.json"
touch "$DJANGO_APP/fixtures/student_assessments.json"

cat > seed_data.sh <<EOF
#!/bin/bash
set -e

rm -rf $DJANGO_APP/migrations
rm -f db.sqlite3

python manage.py makemigrations $DJANGO_APP
python manage.py migrate
python manage.py loaddata users
python manage.py loaddata tokens
EOF

chmod +x seed_data.sh

cat > README.md <<EOF
# Sentinel Matrix Server

Django REST API backend for Sentinel Matrix, a student risk dashboard application.

## Setup

Activate the virtual environment:

\`\`\`bash
source $ENV_DIR/bin/activate
\`\`\`

Install dependencies:

\`\`\`bash
pip install -r requirements.txt
\`\`\`

Run migrations:

\`\`\`bash
python manage.py migrate
\`\`\`

Start server:

\`\`\`bash
python manage.py runserver
\`\`\`

Seed database:

\`\`\`bash
./seed_data.sh
\`\`\`
EOF

echo ""
echo "Sentinel Matrix backend setup complete."
echo ""
echo "Next steps:"
echo "cd $PROJECT_DIR"
echo "source $ENV_DIR/bin/activate"
echo "python manage.py runserver"