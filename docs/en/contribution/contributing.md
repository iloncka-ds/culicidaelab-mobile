# Contributing to CulicidaeLab

Welcome to the CulicidaeLab project! We're excited that you're interested in contributing to this open-source mosquito identification and research platform. This guide will help you get started with contributing effectively to the project.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Contribution Types](#contribution-types)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Submission Guidelines](#submission-guidelines)
- [Community Guidelines](#community-guidelines)
- [Getting Help](#getting-help)

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Development Environment**: Set up your development environment following our [Development Setup Guide](../developer-guide/setup-development.md)
2. **Project Understanding**: Read the [Architecture Documentation](../developer-guide/architecture.md) and [Project Structure Guide](../developer-guide/project-structure.md)
3. **Code Style**: Familiarize yourself with our [Code Style Guide](code-style.md)

### First-Time Setup

1. **Fork the Repository**
   ```bash
   # Fork the repository on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/culicidaelab-mobile.git
   cd culicidaelab-mobile
   ```

2. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/culicidaelab/culicidaelab-mobile.git
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify Setup**
   ```bash
   flutter doctor
   flutter test
   ```

## Development Workflow

### Branch Strategy

We use a feature branch workflow:

1. **Main Branch**: `main` - Production-ready code
2. **Feature Branches**: `feature/description` - New features
3. **Bug Fix Branches**: `fix/description` - Bug fixes
4. **Documentation Branches**: `docs/description` - Documentation updates

### Creating a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create and switch to a new feature branch
git checkout -b feature/mosquito-species-filter

# Make your changes and commit
git add .
git commit -m "Add species filter to mosquito gallery"

# Push to your fork
git push origin feature/mosquito-species-filter
```

### Commit Message Guidelines

Follow the conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(gallery): add species filtering functionality
fix(classification): resolve model loading timeout issue
docs(api): update classification service documentation
test(services): add unit tests for user service
```

## Contribution Types

### 1. Bug Fixes

**Process:**
1. Check if the bug is already reported in [Issues](https://github.com/culicidaelab/culicidaelab-mobile/issues)
2. If not, create a new issue using the bug report template
3. Create a fix branch: `fix/issue-number-description`
4. Write tests that reproduce the bug
5. Implement the fix
6. Ensure all tests pass
7. Submit a pull request

**Requirements:**
- Include test cases that verify the fix
- Update documentation if the fix changes behavior
- Reference the issue number in your PR description

### 2. New Features

**Process:**
1. Discuss the feature in an issue first
2. Wait for maintainer approval before starting work
3. Create a feature branch: `feature/feature-name`
4. Implement the feature following our architecture patterns
5. Add comprehensive tests
6. Update documentation
7. Submit a pull request

**Requirements:**
- Follow MVVM architecture pattern
- Include unit tests for business logic
- Include widget tests for UI components
- Update user documentation if applicable
- Add API documentation for new services

### 3. Documentation Improvements

**Process:**
1. Create a documentation branch: `docs/improvement-description`
2. Make your changes
3. Test documentation builds locally
4. Submit a pull request

**Requirements:**
- Follow our documentation style guide
- Include code examples where appropriate
- Ensure all links work correctly
- Update table of contents if needed

### 4. Performance Improvements

**Process:**
1. Create an issue describing the performance problem
2. Include benchmarks or profiling data
3. Create a performance branch: `perf/improvement-description`
4. Implement improvements
5. Provide before/after performance metrics
6. Submit a pull request

**Requirements:**
- Include performance benchmarks
- Ensure no functionality is broken
- Document any API changes
- Add tests for performance-critical code

## Code Standards

### Architecture Requirements

1. **MVVM Pattern**: All UI screens must follow the Model-View-ViewModel pattern
2. **Dependency Injection**: Use the service locator pattern for dependency management
3. **Repository Pattern**: Data access must go through repository interfaces
4. **Service Layer**: Business logic belongs in service classes

### Code Quality Standards

1. **Null Safety**: All code must be null-safe
2. **Error Handling**: Proper exception handling with specific exception types
3. **Resource Management**: Proper disposal of resources (streams, controllers, etc.)
4. **Performance**: Efficient widget building and memory usage

### Example Implementation

```dart
// Good: Following MVVM pattern
class MosquitoGalleryViewModel extends ChangeNotifier {
  final MosquitoRepository _repository;

  List<MosquitoModel> _mosquitoes = [];
  bool _isLoading = false;
  String? _error;

  MosquitoGalleryViewModel({required MosquitoRepository repository})
      : _repository = repository;

  List<MosquitoModel> get mosquitoes => _mosquitoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMosquitoes() async {
    _setLoading(true);
    try {
      _mosquitoes = await _repository.getAllMosquitoes();
      _error = null;
    } catch (e) {
      _error = 'Failed to load mosquitoes: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

## Testing Requirements

### Test Coverage Expectations

- **Unit Tests**: All service classes and view models must have unit tests
- **Widget Tests**: All custom widgets must have widget tests
- **Integration Tests**: Critical user flows must have integration tests

### Test Structure

```dart
void main() {
  group('MosquitoGalleryViewModel', () {
    late MosquitoGalleryViewModel viewModel;
    late MockMosquitoRepository mockRepository;

    setUp(() {
      mockRepository = MockMosquitoRepository();
      viewModel = MosquitoGalleryViewModel(repository: mockRepository);
    });

    group('loadMosquitoes', () {
      test('should load mosquitoes successfully', () async {
        // Arrange
        final mosquitoes = [MosquitoModel(id: 1, name: 'Aedes aegypti')];
        when(mockRepository.getAllMosquitoes())
            .thenAnswer((_) async => mosquitoes);

        // Act
        await viewModel.loadMosquitoes();

        // Assert
        expect(viewModel.mosquitoes, equals(mosquitoes));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
      });

      test('should handle errors gracefully', () async {
        // Arrange
        when(mockRepository.getAllMosquitoes())
            .thenThrow(Exception('Network error'));

        // Act
        await viewModel.loadMosquitoes();

        // Assert
        expect(viewModel.mosquitoes, isEmpty);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, contains('Network error'));
      });
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/view_models/mosquito_gallery_view_model_test.dart

# Run tests with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Submission Guidelines

### Pull Request Process

1. **Pre-submission Checklist**
   - [ ] Code follows style guidelines
   - [ ] All tests pass
   - [ ] Documentation is updated
   - [ ] Commit messages follow conventions
   - [ ] Branch is up to date with main

2. **Pull Request Template**
   Use our PR template to ensure all necessary information is included:
   - Description of changes
   - Type of change (bug fix, feature, etc.)
   - Testing performed
   - Screenshots (for UI changes)
   - Breaking changes (if any)

3. **Review Process**
   - At least one maintainer review required
   - All CI checks must pass
   - Address all review feedback
   - Squash commits if requested

### Code Review Guidelines

**For Contributors:**
- Respond to feedback promptly
- Ask questions if feedback is unclear
- Make requested changes in separate commits
- Update tests and documentation as needed

**For Reviewers:**
- Be constructive and specific in feedback
- Explain the reasoning behind suggestions
- Approve when code meets standards
- Test functionality when possible

## Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please read and follow our Code of Conduct:

- **Be Respectful**: Treat all community members with respect and kindness
- **Be Inclusive**: Welcome newcomers and help them get started
- **Be Constructive**: Provide helpful feedback and suggestions
- **Be Professional**: Maintain a professional tone in all interactions

### Communication Channels

- **GitHub Issues**: Bug reports, feature requests, and discussions
- **Pull Requests**: Code review and technical discussions
- **Discussions**: General questions and community discussions

### Recognition

We value all contributions to the project:

- Contributors are listed in our README
- Significant contributions are highlighted in release notes
- Regular contributors may be invited to join the maintainer team

## Getting Help

### Resources

1. **Documentation**: Check our comprehensive documentation first
2. **Issues**: Search existing issues for similar problems
3. **Discussions**: Use GitHub Discussions for questions
4. **Code Examples**: Look at existing code for patterns and examples

### Asking for Help

When asking for help, please provide:

1. **Clear Description**: What you're trying to do and what's not working
2. **Environment Details**: OS, Flutter version, device information
3. **Code Examples**: Minimal reproducible example
4. **Error Messages**: Complete error messages and stack traces
5. **Steps Taken**: What you've already tried

### Mentorship

New contributors can request mentorship:

- Comment on issues asking for guidance
- Mention @maintainers in discussions
- Start with "good first issue" labeled items
- Pair with experienced contributors on complex features

## Development Best Practices

### Performance Considerations

1. **Widget Optimization**
   - Use `const` constructors where possible
   - Implement `shouldRebuild` for expensive widgets
   - Avoid creating widgets in build methods

2. **Memory Management**
   - Dispose of controllers and streams properly
   - Use weak references for callbacks
   - Monitor memory usage during development

3. **AI Model Optimization**
   - Optimize model loading and inference
   - Implement proper caching strategies
   - Handle model updates efficiently

### Security Considerations

1. **Data Privacy**
   - Follow GDPR and privacy guidelines
   - Minimize data collection
   - Secure data transmission

2. **API Security**
   - Validate all inputs
   - Use secure authentication
   - Implement rate limiting

### Accessibility

1. **Screen Reader Support**
   - Add semantic labels to all interactive elements
   - Provide alternative text for images
   - Ensure proper focus management

2. **Visual Accessibility**
   - Maintain sufficient color contrast
   - Support system font scaling
   - Provide visual feedback for interactions

## Release Process

### Version Management

We follow semantic versioning (SemVer):
- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes (backward compatible)

### Release Cycle

1. **Development**: Features developed in feature branches
2. **Testing**: Comprehensive testing before release
3. **Release Candidate**: Pre-release testing
4. **Release**: Tagged release with changelog
5. **Post-Release**: Monitor for issues and hotfixes

## Conclusion

Thank you for contributing to CulicidaeLab! Your contributions help advance mosquito research and public health initiatives worldwide. By following these guidelines, you help maintain code quality and ensure a positive experience for all contributors.

For questions about these guidelines or the contribution process, please open an issue or start a discussion. We're here to help you succeed as a contributor to the project.

---

**Happy Contributing!** 🦟🔬📱