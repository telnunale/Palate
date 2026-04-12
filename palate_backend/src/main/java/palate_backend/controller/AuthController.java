package palate_backend.controller;

import palate_backend.model.Usuario;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/registro")
    @Transactional
    public ResponseEntity<Map<String, String>> registro(@RequestBody Map<String, String> datos) {
        String email = datos.get("email");
        String password = datos.get("password");
        String nombre = datos.get("nombre");

        if (email == null || password == null || nombre == null) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Faltan campos obligatorios");
            return ResponseEntity.badRequest().body(error);
        }

        // Comprobar si el email ya existe
        String jpql = "SELECT u FROM Usuario u WHERE u.email = :emailParam";
        TypedQuery<Usuario> query = em.createQuery(jpql, Usuario.class);
        query.setParameter("emailParam", email);
        List<Usuario> existentes = query.getResultList();

        if (!existentes.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "El email ya está registrado");
            return ResponseEntity.badRequest().body(error);
        }

        // Crear usuario con password encriptado
        Usuario usuario = new Usuario(email, passwordEncoder.encode(password), nombre);
        em.persist(usuario);

        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("mensaje", "Usuario registrado correctamente");
        respuesta.put("email", email);
        return ResponseEntity.ok(respuesta);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody Map<String, String> datos) {
        String email = datos.get("email");
        String password = datos.get("password");

        if (email == null || password == null) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Faltan campos obligatorios");
            return ResponseEntity.badRequest().body(error);
        }

        // Buscar usuario por email
        String jpql = "SELECT u FROM Usuario u WHERE u.email = :emailParam";
        TypedQuery<Usuario> query = em.createQuery(jpql, Usuario.class);
        query.setParameter("emailParam", email);
        List<Usuario> resultados = query.getResultList();

        if (resultados.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Email o contraseña incorrectos");
            return ResponseEntity.status(401).body(error);
        }

        Usuario usuario = resultados.get(0);

        // Verificar password con BCrypt
        if (!passwordEncoder.matches(password, usuario.getPasswordHash())) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Email o contraseña incorrectos");
            return ResponseEntity.status(401).body(error);
        }

        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("mensaje", "Login correcto");
        respuesta.put("email", usuario.getEmail());
        respuesta.put("nombre", usuario.getNombre());
        return ResponseEntity.ok(respuesta);
    }
}