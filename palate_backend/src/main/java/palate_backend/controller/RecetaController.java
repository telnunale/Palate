package palate_backend.controller;

import palate_backend.dto.RecetaDTO;
import palate_backend.service.RecetaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/recetas")
public class RecetaController {

    private final RecetaService recetaService;

    @Autowired
    public RecetaController(RecetaService recetaService) {
        this.recetaService = recetaService;
    }

    @GetMapping
    public List<RecetaDTO> obtenerTodas() {
        return recetaService.obtenerTodas();
    }

    @GetMapping("/{id}")
    public ResponseEntity<RecetaDTO> obtenerPorId(@PathVariable Long id) {
        Optional<RecetaDTO> receta = recetaService.obtenerPorId(id);
        return receta.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/generar")
    public ResponseEntity<Object> generarReceta(@RequestBody Map<String, String> datos) {
        String descripcion = datos.get("descripcion");

        if (descripcion == null || descripcion.trim().isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "La descripción no puede estar vacía");
            return ResponseEntity.badRequest().body(error);
        }

        try {
            RecetaDTO receta = recetaService.generarYGuardar(descripcion);
            return ResponseEntity.ok(receta);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Error al generar la receta: " + e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }

    @PostMapping("/generar-con-aversion")
    public ResponseEntity<Object> generarConAversion(@RequestBody Map<String, Object> datos) {
        String descripcion = (String) datos.get("descripcion");
        Long intoleranciaId = Long.valueOf(datos.get("intoleranciaId").toString());

        if (descripcion == null || descripcion.trim().isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "La descripción no puede estar vacía");
            return ResponseEntity.badRequest().body(error);
        }

        try {
            RecetaDTO receta = recetaService.generarYGuardarConAversion(descripcion, intoleranciaId);
            return ResponseEntity.ok(receta);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Error al generar la receta: " + e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }
}
