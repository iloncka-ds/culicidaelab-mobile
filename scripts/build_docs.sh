#!/bin/bash

# CulicidaeLab Documentation Build Script
# This script provides a convenient way to build documentation on Unix-like systems

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DART_DOC_OUTPUT="docs/api-reference/generated"
MKDOCS_CONFIG="docs/_config/mkdocs.yml"
MKDOCS_OUTPUT="site"

# Function to print colored output
print_status() {
    echo -e "${BLUE}🚀 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to show usage
show_usage() {
    echo "CulicidaeLab Documentation Builder"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --clean      Clean previous builds before generating new documentation"
    echo "  --no-api     Skip API documentation generation (dart doc)"
    echo "  --no-site    Skip static site generation (MkDocs)"
    echo "  --validate   Validate generated documentation"
    echo "  --serve      Start local development server after build"
    echo "  --help, -h   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build all documentation"
    echo "  $0 --clean            # Clean and build all"
    echo "  $0 --no-api           # Build only static site"
    echo "  $0 --serve            # Build and serve locally"
}

# Parse command line arguments
CLEAN=false
BUILD_API=true
BUILD_SITE=true
VALIDATE=false
SERVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --no-api)
            BUILD_API=false
            shift
            ;;
        --no-site)
            BUILD_SITE=false
            shift
            ;;
        --validate)
            VALIDATE=true
            shift
            ;;
        --serve)
            SERVE=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to clean previous builds
clean_builds() {
    print_status "Cleaning previous builds..."
    
    if [ -d "$DART_DOC_OUTPUT" ]; then
        rm -rf "$DART_DOC_OUTPUT"
        echo "   Cleaned: $DART_DOC_OUTPUT"
    fi
    
    if [ -d "$MKDOCS_OUTPUT" ]; then
        rm -rf "$MKDOCS_OUTPUT"
        echo "   Cleaned: $MKDOCS_OUTPUT"
    fi
    
    print_success "Clean completed"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if dart is installed
    if ! command -v dart &> /dev/null; then
        print_error "Dart SDK not found. Please install Flutter/Dart SDK."
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Please run from project root."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
    echo ""
}

# Function to generate API documentation
generate_api_docs() {
    print_status "Generating API documentation..."
    
    if [ ! -f "dartdoc_options.yaml" ]; then
        print_error "dartdoc_options.yaml not found. Please run from project root."
        exit 1
    fi
    
    # Run dart doc
    if dart doc --validate-links .; then
        print_success "API documentation generated"
    else
        print_error "API documentation generation failed"
        exit 1
    fi
    
    echo ""
}

# Function to install MkDocs if needed
install_mkdocs() {
    print_status "Installing MkDocs and plugins..."
    
    # Check if pip is available
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        print_error "pip not found. Please install Python and pip."
        exit 1
    fi
    
    # Use pip3 if available, otherwise pip
    PIP_CMD="pip"
    if command -v pip3 &> /dev/null; then
        PIP_CMD="pip3"
    fi
    
    # Install MkDocs and plugins
    $PIP_CMD install mkdocs mkdocs-material mkdocs-mermaid2-plugin mkdocs-minify-plugin mkdocs-git-revision-date-localized-plugin
    
    print_success "MkDocs installation completed"
    echo ""
}

# Function to generate static site documentation
generate_site_docs() {
    print_status "Generating static site documentation..."
    
    if [ ! -f "$MKDOCS_CONFIG" ]; then
        print_error "MkDocs config not found: $MKDOCS_CONFIG"
        exit 1
    fi
    
    # Check if MkDocs is installed
    if ! command -v mkdocs &> /dev/null; then
        print_warning "MkDocs not found. Installing..."
        install_mkdocs
    fi
    
    # Run MkDocs build
    if mkdocs build --config-file "$MKDOCS_CONFIG" --site-dir "$MKDOCS_OUTPUT"; then
        print_success "Static site documentation generated"
    else
        print_error "Static site generation failed"
        exit 1
    fi
    
    echo ""
}

# Function to validate documentation
validate_docs() {
    print_status "Validating documentation..."
    
    # Check API documentation
    if [ -f "$DART_DOC_OUTPUT/index.html" ]; then
        print_success "API documentation validated"
    else
        print_warning "API documentation index not found"
    fi
    
    # Check static site
    if [ -f "$MKDOCS_OUTPUT/index.html" ]; then
        print_success "Static site documentation validated"
    else
        print_warning "Static site index not found"
    fi
    
    echo ""
}

# Function to serve documentation locally
serve_docs() {
    print_status "Starting local documentation server..."
    
    if [ -f "$MKDOCS_CONFIG" ]; then
        print_success "Documentation server starting at http://localhost:8000"
        mkdocs serve --config-file "$MKDOCS_CONFIG"
    else
        print_error "Cannot serve: MkDocs config not found"
        exit 1
    fi
}

# Main execution
main() {
    print_status "Starting CulicidaeLab documentation build..."
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Clean if requested
    if [ "$CLEAN" = true ]; then
        clean_builds
    fi
    
    # Generate API documentation
    if [ "$BUILD_API" = true ]; then
        generate_api_docs
    fi
    
    # Generate static site documentation
    if [ "$BUILD_SITE" = true ]; then
        generate_site_docs
    fi
    
    # Validate if requested
    if [ "$VALIDATE" = true ]; then
        validate_docs
    fi
    
    # Show completion message
    print_success "Documentation build completed successfully!"
    echo ""
    echo "📖 API docs: $DART_DOC_OUTPUT/index.html"
    echo "🌐 Site docs: $MKDOCS_OUTPUT/index.html"
    echo ""
    
    # Serve if requested
    if [ "$SERVE" = true ]; then
        serve_docs
    fi
}

# Run main function
main