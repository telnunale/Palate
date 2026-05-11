\## Requisitos previos



\### Backend

\- Java 21 ou superior

\- Maven 3.9+

\- Conexión a internet (base de datos en Neon cloud)



\### Frontend

\- Flutter SDK 3.x ou superior

\- Dart SDK (incluído con Flutter)

\- Google Chrome (para probas en desenvolvemento)



\## Despregue do proxecto



\### 1. Clonar o repositorio



```bash

git clone https://github.com/telnunale/Palate.git

cd Palate

```



\### 2. Configurar e executar o backend



O backend está desplegado en Render: `https://palate-backend-XXXX.onrender.com`. A aplicación móbil xa apunta a este endpoint, polo que **non é necesario arrancar o backend localmente** para probar a aplicación.



Para arrancalo en local (opcional):



```bash

cd palate\_backend

```



Copiar a plantilla de credenciais e rellenala coas chaves propias dos servizos externos (Gemini, fal.ai, Cloudinary, Edamam, Pexels, Neon):



```bash

cp src/main/resources/application-local.properties.example src/main/resources/application-local.properties

```



Arrancar con o perfil `local`:



```bash

./mvnw spring-boot:run -Dspring-boot.run.profiles=local

```



En Windows:



```bash

mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"

```



O servidor arrancará en `http://localhost:8080`. As credenciais reais nunca se inclúen no repositorio.



\### 3. Configurar e executar o frontend



Abrir outra terminal:



```bash

cd palate\_frontend

flutter pub get

flutter run -d chrome

```



A aplicación Flutter abrirá no navegador e conectará co backend en `localhost:8080`.



\## Endpoints da API REST



| Método | Endpoint | Descrición |

|--------|----------|------------|

| POST | /api/auth/registro | Rexistro de usuario (BCrypt) |

| POST | /api/auth/login | Inicio de sesión |

| GET | /api/recetas | Listar todas as receitas |

| GET | /api/recetas/{id} | Detalle dunha receita cos ingredientes |



\## Tecnoloxías utilizadas



\- \*\*Backend:\*\* Spring Boot 4.0.5, Java 21, Spring Security, JPA/Hibernate

\- \*\*Frontend:\*\* Flutter, Dart, arquitectura MVVM

\- \*\*Base de datos:\*\* PostgreSQL 17.8 (Neon, tier gratuito)

\- \*\*Seguridade:\*\* BCrypt para encriptación de contrasinais

\- \*\*IDE:\*\* IntelliJ IDEA (backend), Visual Studio Code (frontend)



\## Probas da API



Pódese probar a API desde PowerShell:



```powershell

\# Rexistro

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/registro" -Method POST -ContentType "application/json" -Body '{"email":"test@palate.com","password":"1234","nombre":"Test"}'



\# Login

Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -ContentType "application/json" -Body '{"email":"test@palate.com","password":"1234"}'



\# Listar receitas

Invoke-RestMethod -Uri "http://localhost:8080/api/recetas"

```



\## Autor



Proxecto Final de Ciclo — DAM 2025-2026

IES Fernando Wirtz Suárez, A Coruña

