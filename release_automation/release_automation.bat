@echo off

python "C:\Users\sgbsubhiram.gurlinka\Documents\Middleware\code\run_recipe_python.py"
if %errorlevel% neq 0 (
  echo run_recipe_python.py failed
  exit /b %errorlevel%
)

python check_logs.py
if %errorlevel% neq 0 (
  echo check_logs.py failed
  exit /b %errorlevel%
)

python git_automation_verbose.py
if %errorlevel% neq 0 (
  echo git_automation_verbose.py failed
  exit /b %errorlevel%
)

echo All scripts ran successfully
