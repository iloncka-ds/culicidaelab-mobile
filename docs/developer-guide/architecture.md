# CulicidaeLab Architecture Overview

## Introduction

CulicidaeLab is a Flutter mobile application designed for mosquito species identification and disease information dissemination. The application leverages AI-powered image classification using PyTorch Lite models to identify mosquito species from user-captured photos and provides comprehensive information about mosquito-borne diseases.

## High-Level Architecture

The application follows a layered architecture pattern with clear separation of concerns:

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[Screens & Widgets]
        VM[View Models]
        P[Providers]
    end
    
    subgraph "Business Logic Layer"
        S[Services]
        R[Repositories]
    end
    
    subgraph "Data Layer"
        DB[(SQLite Database)]
        API[External APIs]
        ML[PyTorch Models]
        SP[Shared Preferences]
    end
    
    subgraph "External Dependencies"
        CAM[Camera]
        GPS[Location Services]
        NET[Network]
        FS[File System]
    end
    
    UI --> VM
    VM --> P
    VM --> R
    R --> S
    S --> DB
    S --> API
    S --> ML
    S --> SP
    S --> CAM
    S --> GPS
    S --> NET
    S --> FS
```

## MVVM Pattern Implementation

CulicidaeLab implements the Model-View-ViewModel (MVVM) architectural pattern with Provider for state management:

### View Layer
- **Screens**: Main UI components that represent different app pages
- **Widgets**: Reusable UI components and custom widgets
- **Navigation**: Route management and screen transitions

### ViewModel Layer
- **ClassificationViewModel**: Manages mosquito classification workflow
- **DiseaseInfoViewModel**: Handles disease information display
- **MosquitoGalleryViewModel**: Controls gallery browsing functionality

### Model Layer
- **Data Models**: Represent core entities (Mosquito, Disease, Observation)
- **Repositories**: Abstract data access and business logic
- **Services**: Handle specific functionality (AI, Database, Network)

## Component Relationships

### Core Components

```mermaid
graph LR
    subgraph "UI Components"
        HS[HomeScreen]
        CS[ClassificationScreen]
        GS[GalleryScreen]
        DS[DiseaseScreen]
    end
    
    subgraph "ViewModels"
        CVM[ClassificationViewModel]
        DVM[DiseaseInfoViewModel]
        GVM[GalleryViewModel]
    end
    
    subgraph "Repositories"
        CR[ClassificationRepository]
        MR[MosquitoRepository]
    end
    
    subgraph "Services"
        CLS[ClassificationService]
        DBS[DatabaseService]
        US[UserService]
    end
    
    HS --> CVM
    CS --> CVM
    GS --> GVM
    DS --> DVM
    
    CVM --> CR
    GVM --> MR
    DVM --> MR
    
    CR --> CLS
    CR --> MR
    MR --> DBS
    CVM --> US
```

## Data Flow Architecture

### Classification Workflow

```mermaid
sequenceDiagram
    participant User
    participant UI as ClassificationScreen
    participant VM as ClassificationViewModel
    participant Repo as ClassificationRepository
    participant CS as ClassificationService
    participant ML as PyTorchWrapper
    participant DB as DatabaseService
    
    User->>UI: Capture/Select Image
    UI->>VM: processImage(image)
    VM->>Repo: classifyImage(image)
    Repo->>CS: classifyMosquito(image)
    CS->>ML: predict(imageBytes)
    ML-->>CS: PredictionResult
    CS-->>Repo: ClassificationResult
    Repo->>DB: saveObservation(result)
    Repo-->>VM: ClassificationResult
    VM-->>UI: Update UI State
    UI-->>User: Display Results
```

### Data Persistence Flow

```mermaid
graph TD
    A[User Action] --> B[ViewModel]
    B --> C[Repository]
    C --> D{Data Source}
    D -->|Local Data| E[DatabaseService]
    D -->|Remote Data| F[HTTP Client]
    D -->|User Preferences| G[SharedPreferences]
    E --> H[(SQLite)]
    F --> I[External API]
    G --> J[Local Storage]
```

## Dependency Injection

The application uses GetIt for dependency injection, configured in `lib/locator.dart`:

### Service Registration Order

1. **External Packages**: SharedPreferences, HTTP Client, UUID
2. **Core Services**: Database, PyTorch, User, Classification
3. **Repositories**: Data access layer
4. **ViewModels**: Business logic layer
5. **Providers**: State management

### Dependency Graph

```mermaid
graph TD
    SP[SharedPreferences] --> US[UserService]
    SP --> LP[LocaleProvider]
    UUID[Uuid] --> US
    HTTP[HTTP Client] --> CR[ClassificationRepository]
    
    DBS[DatabaseService] --> MR[MosquitoRepository]
    PW[PytorchWrapper] --> CS[ClassificationService]
    
    CS --> CR
    MR --> CR
    MR --> DVM[DiseaseInfoViewModel]
    MR --> GVM[GalleryViewModel]
    
    CR --> CVM[ClassificationViewModel]
    US --> CVM
```

## State Management with Provider

### Provider Architecture

```mermaid
graph TB
    subgraph "Provider Tree"
        LP[LocaleProvider]
        CVM[ClassificationViewModel]
        DVM[DiseaseInfoViewModel]
        GVM[GalleryViewModel]
    end
    
    subgraph "Widget Tree"
        MA[MaterialApp]
        HP[HomePage]
        CS[ClassificationScreen]
        GS[GalleryScreen]
        DS[DiseaseScreen]
    end
    
    LP --> MA
    CVM --> CS
    GVM --> GS
    DVM --> DS
```

### State Flow Pattern

1. **User Interaction**: User performs action in UI
2. **ViewModel Update**: ViewModel processes action and updates state
3. **Provider Notification**: ViewModel notifies listeners via ChangeNotifier
4. **UI Rebuild**: Consumer widgets rebuild with new state
5. **Repository Interaction**: ViewModel calls repository methods for data operations

## AI Model Integration

### PyTorch Lite Integration

```mermaid
graph LR
    subgraph "AI Pipeline"
        IMG[Image Input] --> PREP[Image Preprocessing]
        PREP --> MODEL[PyTorch Lite Model]
        MODEL --> POST[Post-processing]
        POST --> RESULT[Classification Result]
    end
    
    subgraph "Model Management"
        ASSETS[Model Assets] --> LOADER[Model Loader]
        LOADER --> CACHE[Model Cache]
        CACHE --> MODEL
    end
```

### Classification Service Architecture

- **Image Preprocessing**: Resize, normalize, and format images for model input
- **Model Inference**: Execute PyTorch Lite model prediction
- **Result Processing**: Parse model output and map to mosquito species
- **Confidence Scoring**: Evaluate prediction confidence and handle low-confidence results

## Database Architecture

### SQLite Schema

```mermaid
erDiagram
    MOSQUITO {
        int id PK
        string species_name
        string common_name
        string description
        string habitat
        string distribution
        string image_path
        datetime created_at
        datetime updated_at
    }
    
    DISEASE {
        int id PK
        string name
        string description
        string symptoms
        string prevention
        string treatment
        string image_path
        datetime created_at
        datetime updated_at
    }
    
    OBSERVATION {
        int id PK
        string user_id
        int mosquito_id FK
        string image_path
        float confidence_score
        double latitude
        double longitude
        datetime observed_at
        datetime created_at
    }
    
    MOSQUITO_DISEASE {
        int mosquito_id FK
        int disease_id FK
    }
    
    MOSQUITO ||--o{ OBSERVATION : "identified_as"
    MOSQUITO ||--o{ MOSQUITO_DISEASE : "carries"
    DISEASE ||--o{ MOSQUITO_DISEASE : "carried_by"
```

### Data Access Pattern

- **Repository Pattern**: Abstract data access through repository interfaces
- **Service Layer**: Business logic separated from data access
- **Model Classes**: Strongly-typed data models with validation
- **Migration Support**: Database schema versioning and migration handling

## Security Architecture

### Data Protection

- **Local Storage**: SQLite database with encrypted sensitive data
- **User Privacy**: Anonymous user identification with UUID
- **Image Security**: Local image storage with secure file paths
- **Network Security**: HTTPS for all external API communications

### Permission Management

- **Camera Access**: Required for image capture functionality
- **Location Services**: Optional for observation geo-tagging
- **Storage Access**: Required for image processing and caching
- **Network Access**: Required for external API integration

## Performance Considerations

### Memory Management

- **Image Processing**: Efficient image loading and disposal
- **Model Caching**: PyTorch model loaded once and cached
- **Database Connections**: Connection pooling and proper disposal
- **Widget Lifecycle**: Proper disposal of controllers and listeners

### Optimization Strategies

- **Lazy Loading**: Services and models loaded on-demand
- **Image Caching**: Cached network images for offline access
- **Database Indexing**: Optimized queries with proper indexing
- **Background Processing**: Heavy operations moved to background threads

## Testing Architecture

### Testing Layers

```mermaid
graph TB
    subgraph "Testing Pyramid"
        UT[Unit Tests]
        IT[Integration Tests]
        WT[Widget Tests]
        E2E[End-to-End Tests]
    end
    
    subgraph "Test Targets"
        M[Models]
        S[Services]
        R[Repositories]
        VM[ViewModels]
        W[Widgets]
        F[Full App Flow]
    end
    
    UT --> M
    UT --> S
    IT --> R
    IT --> VM
    WT --> W
    E2E --> F
```

### Testing Strategy

- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test component interactions and data flow
- **Widget Tests**: Test UI components and user interactions
- **End-to-End Tests**: Test complete user workflows

## Deployment Architecture

### Build Configuration

- **Development**: Debug builds with development tools
- **Staging**: Release builds with staging API endpoints
- **Production**: Optimized release builds with production configuration

### Platform-Specific Considerations

- **Android**: Gradle build configuration and permissions
- **iOS**: Xcode project settings and Info.plist configuration
- **Asset Management**: Platform-specific asset optimization

## Extension Points

### Customization Areas

- **New Classification Models**: Plugin architecture for additional AI models
- **Data Sources**: Extensible repository pattern for new data sources
- **UI Themes**: Configurable theming system
- **Localization**: Support for additional languages and regions

### Integration Capabilities

- **External APIs**: RESTful API integration framework
- **Third-party Services**: Plugin system for external service integration
- **Data Export**: Configurable data export formats and destinations
- **Analytics**: Pluggable analytics and monitoring systems

## Conclusion

The CulicidaeLab architecture provides a solid foundation for a scalable, maintainable, and extensible mobile application. The clear separation of concerns, dependency injection, and MVVM pattern ensure that the codebase remains organized and testable as the application grows in complexity and features.