@echo off
REM CulicidaeLab Documentation Build Script for Windows
REM This script provides a convenient way to build documentation on Windows

setlocal enabledelayedexpansion

REM Configuration
set "DART_DOC_OUTPUT=docs\api-reference\generated"
set "MKDOCS_CONFIG=docs\_config\mkdocs.yml"
set "MKDOCS_OUTPUT=site"

REM Default options
set "CLEAN=false"
set "BUILD_API=true"
set "BUILD_SITE=true"
set "VALIDATE=false"
set "SERVE=false"

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :start_build
if "%~1"=="--clean" (
    set "CLEAN=true"
    shift
    goto :parse_args
)
if "%~1"=="--no-api" (
    set "BUILD_API=false"
    shift
    goto :parse_args
)
if "%~1"=="--no-site" (
    set "BUILD_SITE=false"
    shift
    goto :parse_args
)
if "%~1"=="--validate" (
    set "VALIDATE=true"
    shift
    goto :parse_args
)
if "%~1"=="--serve" (
    set "SERVE=true"
    shift
    goto :parse_args
)
if "%~1"=="--help" goto :show_usage
if "%~1"=="-h" goto :show_usage
echo Unknown option: %~1
goto :show_usage

:show_usage
echo CulicidaeLab Documentation Builder
echo.
echo Usage: %~nx0 [options]
echo.
echo Options:
echo   --clean      Clean previous builds before generating new documentation
echo   --no-api     Skip API documentation generation (dart doc)
echo   --no-site    Skip static site generation (MkDocs)
echo   --validate   Validate generated documentation
echo   --serve      Start local development server after build
echo   --help, -h   Show this help message
echo.
echo Examples:
echo   %~nx0                    # Build all documentation
echo   %~nx0 --clean            # Clean and build all
echo   %~nx0 --no-api           # Build only static site
echo   %~nx0 --serve            # Build and serve locally
goto :eof

:start_build
echo 🚀 Starting CulicidaeLab documentation build...
echo.

REM Check prerequisites
call :check_prerequisites
if errorlevel 1 goto :error

REM Clean if requested
if "%CLEAN%"=="true" (
    call :clean_builds
    if errorlevel 1 goto :error
)

REM Generate API documentation
if "%BUILD_API%"=="true" (
    call :generate_api_docs
    if errorlevel 1 goto :error
)

REM Generate static site documentation
if "%BUILD_SITE%"=="true" (
    call :generate_site_docs
    if errorlevel 1 goto :error
)

REM Validate if requested
if "%VALIDATE%"=="true" (
    call :validate_docs
)

REM Show completion message
echo ✅ Documentation build completed successfully!
echo.
echo 📖 API docs: %DART_DOC_OUTPUT%\index.html
echo 🌐 Site docs: %MKDOCS_OUTPUT%\index.html
echo.

REM Serve if requested
if "%SERVE%"=="true" (
    call :serve_docs
)

goto :eof

:check_prerequisites
echo 🔍 Checking prerequisites...

REM Check if dart is installed
dart --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Dart SDK not found. Please install Flutter/Dart SDK.
    exit /b 1
)

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml not found. Please run from project root.
    exit /b 1
)

echo ✅ Prerequisites check passed
echo.
exit /b 0

:clean_builds
echo 🧹 Cleaning previous builds...

if exist "%DART_DOC_OUTPUT%" (
    rmdir /s /q "%DART_DOC_OUTPUT%"
    echo    Cleaned: %DART_DOC_OUTPUT%
)

if exist "%MKDOCS_OUTPUT%" (
    rmdir /s /q "%MKDOCS_OUTPUT%"
    echo    Cleaned: %MKDOCS_OUTPUT%
)

echo ✅ Clean completed
echo.
exit /b 0

:generate_api_docs
echo 📚 Generating API documentation...

if not exist "dartdoc_options.yaml" (
    echo ❌ dartdoc_options.yaml not found. Please run from project root.
    exit /b 1
)

REM Run dart doc
dart doc --validate-links .
if errorlevel 1 (
    echo ❌ API documentation generation failed
    exit /b 1
)

echo ✅ API documentation generated
echo.
exit /b 0

:install_mkdocs
echo 📦 Installing MkDocs and plugins...

REM Check if pip is available
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip not found. Please install Python and pip.
    exit /b 1
)

REM Install MkDocs and plugins
pip install mkdocs mkdocs-material mkdocs-mermaid2-plugin mkdocs-minify-plugin mkdocs-git-revision-date-localized-plugin
if errorlevel 1 (
    echo ❌ MkDocs installation failed
    exit /b 1
)

echo ✅ MkDocs installation completed
echo.
exit /b 0

:generate_site_docs
echo 🌐 Generating static site documentation...

if not exist "%MKDOCS_CONFIG%" (
    echo ❌ MkDocs config not found: %MKDOCS_CONFIG%
    exit /b 1
)

REM Check if MkDocs is installed
mkdocs --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  MkDocs not found. Installing...
    call :install_mkdocs
    if errorlevel 1 exit /b 1
)

REM Run MkDocs build
mkdocs build --config-file "%MKDOCS_CONFIG%" --site-dir "%MKDOCS_OUTPUT%"
if errorlevel 1 (
    echo ❌ Static site generation failed
    exit /b 1
)

echo ✅ Static site documentation generated
echo.
exit /b 0

:validate_docs
echo 🔍 Validating documentation...

REM Check API documentation
if exist "%DART_DOC_OUTPUT%\index.html" (
    echo ✅ API documentation validated
) else (
    echo ⚠️  API documentation index not found
)

REM Check static site
if exist "%MKDOCS_OUTPUT%\index.html" (
    echo ✅ Static site documentation validated
) else (
    echo ⚠️  Static site index not found
)

echo.
exit /b 0

:serve_docs
echo 🚀 Starting local documentation server...

if exist "%MKDOCS_CONFIG%" (
    echo ✅ Documentation server starting at http://localhost:8000
    mkdocs serve --config-file "%MKDOCS_CONFIG%"
) else (
    echo ❌ Cannot serve: MkDocs config not found
    exit /b 1
)
exit /b 0

:error
echo ❌ Build failed!
exit /b 1