# 🧠 DejarEs — App iOS para dejar malos hábitos

![Swift](https://img.shields.io/badge/Swift-5.10-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-18.0%2B-blue?logo=apple)
![License](https://img.shields.io/badge/license-MIT-lightgrey)
![Tuist](https://img.shields.io/badge/Tuist-4.x-green?logo=tuist)
![Build](https://github.com/AlbertoGarciaDev/DejarEs/actions/workflows/ci.yml/badge.svg)

> Proyecto desarrollado por **AlbertoGarciaDev**, parte del ecosistema **AGD Frameworks**.  
> Diseñado para acompañar a las personas en su proceso de dejar malos hábitos (como fumar, procrastinar o beber) mediante **motivación, seguimiento y rutinas personalizadas**.

---

## 🌱 Descripción general

**DejarEs** es una aplicación iOS creada con **Clean Architecture modular** y **Tuist**, enfocada en la mejora personal y el cambio de hábitos.

Su propósito es **ayudar al usuario a abandonar hábitos negativos** mediante:
- Rachas de motivación (“streaks”).
- Registro de avances diarios.
- Módulo de motivación personalizada.
- Integración futura con recordatorios inteligentes.

---

## 🧩 Arquitectura

El proyecto sigue una **estructura modular escalable** con separación clara de responsabilidades.
```
DejarEs/
├── Apps/
│     └── DejarEsApp/
├── Modules/
│     ├── FeatureHabits/
│     └── CorePersistenceAdapter/
└── Dependencies/
      ├── AGDNetworking/
      ├── AGDPersistence/
      ├── AGDDesignSystem/
      ├── AGDFoundation/
      └── ...
```

### Capas principales

| Capa | Descripción |
|------|--------------|
| **Apps/** | Contiene el punto de entrada (SwiftUI App) |
| **Modules/** | Features funcionales (Hábitos, Motivación, Perfil) |
| **Dependencies/** | Frameworks reutilizables del ecosistema AGD |
| **Scripts/** | Scripts de automatización y generación de módulos |

---

## 🧠 Ecosistema AGD

Parte del conjunto de frameworks reutilizables creados por [AlbertoGarciaDev](https://github.com/AlbertoGarciaDev):

| Framework | Propósito |
|------------|------------|
| `AGDNetworking` | Capa de red desacoplada con API estable (URLSession, middlewares, mocks) |
| `AGDPersistence` | Persistencia genérica (SwiftData, UserDefaults, etc.) |
| `AGDDesignSystem` | Componentes de UI consistentes con el estilo de DejarEs |
| `AGDFoundation` | Utilidades y extensiones base para todos los proyectos AGD |

---

## ⚙️ Stack tecnológico

| Componente | Tecnología |
|-------------|-------------|
| Lenguaje | Swift 5.10 |
| UI | SwiftUI (iOS 17+) |
| Arquitectura | Clean Architecture + Tuist |
| CI/CD | GitHub Actions (Lint + Build) |
| Linter | SwiftLint / SwiftFormat |
| IDE | Xcode 16+ |
| Mínimo iOS | 17.0 |
| Diseño | LiquidGlass (iOS 18-ready) |

---

## 🔧 Configuración local

### 1️⃣ Clonar el repositorio
```bash
git clone https://github.com/AlbertoGarciaDev/DejarEs.git
cd DejarEs
```

### 2️⃣ Instalar dependencias
```bash
brew bundle
tuist install
```

### 3️⃣ Generar el workspace
```bash
tuist generate
xed .
```

### 4️⃣ Compilar y ejecutar
Selecciona el esquema DejarEsApp → Run (⌘R)

## 🚀 CI / CD

El proyecto incluye integración continua con GitHub Actions:
- Lint automático en cada Pull Request.
- Build checks (en construcción).
- Validación de flujo GitFlow para ramas `feature/* → develop` y `release/hotfix → main`.

## 📖 Documentación

Cada framework del ecosistema AGD incluye su propia documentación técnica dentro de `/Dependencies/AGD*/docs/`.
Ejemplo:
```
AGDNetworking/docs/
├── overview.md
├── api.md
└── examples.md
```

## 📜 Licencia

Este proyecto está bajo la licencia MIT

MIT License

Copyright (c) 2025 Alberto García

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## 👤 Autor

Alberto García
- 🌐 [albertogarcia.dev](https://albertogarcia.dev)
- 🐙 GitHub
- 💼 LinkedIn
