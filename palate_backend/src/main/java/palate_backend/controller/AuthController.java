package palate_backend.controller;

import palate_backend.dto.UsuarioDTO;
import palate_backend.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UsuarioService usuarioService;

    @Autowired
    public AuthController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/registro")
    public ResponseEntity<Map<String, String>> registro(@RequestBody Map<String, String> datos) {
        String email = datos.get("email");
        String password = datos.get("password");
        String nombre = datos.get("nombre");

        if (email == null || password == null || nombre == null) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Faltan campos obligatorios");
            return ResponseEntity.badRequest().body(error);
        }

        try {
            usuarioService.registro(email, password, nombre);
            Map<String, String> respuesta = new HashMap<>();
            respuesta.put("mensaje", "Usuario registrado correctamente");
            respuesta.put("email", email);
            return ResponseEntity.ok(respuesta);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
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

        Optional<UsuarioDTO> resultado = usuarioService.login(email, password);

        if (resultado.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Email o contraseña incorrectos");
            return ResponseEntity.status(401).body(error);
        }

        UsuarioDTO usuario = resultado.get();
        Map<String, String> respuesta = new HashMap<>();
        respuesta.put("mensaje", "Login correcto");
        respuesta.put("email", usuario.getEmail());
        respuesta.put("nombre", usuario.getNombre());
        return ResponseEntity.ok(respuesta);
    }
}
