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



```bash

cd palate\_backend

```



Abrir o arquivo `src/main/resources/application.properties` e configurar a conexión á base de datos PostgreSQL (Neon):



```properties

spring.datasource.url=jdbc:postgresql://SEU\_HOST\_NEON/neondb?sslmode=require

spring.datasource.username=SEU\_USUARIO

spring.datasource.password=SEA\_CONTRASINAL

```



Executar o backend:



```bash

./mvnw spring-boot:run

```



En Windows:



```bash

mvnw.cmd spring-boot:run

```



O servidor arrancará en `http://localhost:8080`.



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

