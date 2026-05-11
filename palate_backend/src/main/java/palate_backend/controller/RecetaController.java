package palate_backend.controller;

import palate_backend.dto.RecetaDTO;
import palate_backend.service.RecetaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
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

    @PostMapping("/generar-con-despensa")
    public ResponseEntity<Object> generarConDespensa(@RequestBody Map<String, Object> datos) {
        Long usuarioId = Long.valueOf(datos.get("usuarioId").toString());
        String descripcion = datos.containsKey("descripcion") ? (String) datos.get("descripcion") : "";
        List<Long> intoleranciaIds = extraerIntoleranciaIds(datos);

        try {
            RecetaDTO receta = intoleranciaIds.size() > 1
                    ? recetaService.generarYGuardarConDespensaYAversiones(usuarioId, intoleranciaIds, descripcion)
                    : recetaService.generarYGuardarConDespensa(
                            usuarioId,
                            intoleranciaIds.isEmpty() ? null : intoleranciaIds.get(0),
                            descripcion);
            return ResponseEntity.ok(receta);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Error al generar la receta: " + e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }

    @PostMapping("/{id}/regenerar-imagen")
    public ResponseEntity<Map<String, String>> regenerarImagen(@PathVariable Long id) {
        Optional<String> nueva = recetaService.regenerarImagen(id);
        if (nueva.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Map<String, String> body = new HashMap<>();
        body.put("imagenUrl", nueva.get());
        return ResponseEntity.ok(body);
    }

    @PostMapping("/generar-con-aversion")
    public ResponseEntity<Object> generarConAversion(@RequestBody Map<String, Object> datos) {
        String descripcion = (String) datos.get("descripcion");
        List<Long> intoleranciaIds = extraerIntoleranciaIds(datos);

        if (descripcion == null || descripcion.trim().isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "La descripción no puede estar vacía");
            return ResponseEntity.badRequest().body(error);
        }
        if (intoleranciaIds.isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Debes indicar al menos una aversion");
            return ResponseEntity.badRequest().body(error);
        }

        try {
            RecetaDTO receta = intoleranciaIds.size() > 1
                    ? recetaService.generarYGuardarConAversiones(descripcion, intoleranciaIds)
                    : recetaService.generarYGuardarConAversion(descripcion, intoleranciaIds.get(0));
            return ResponseEntity.ok(receta);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Error al generar la receta: " + e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }

    @SuppressWarnings("unchecked")
    private List<Long> extraerIntoleranciaIds(Map<String, Object> datos) {
        List<Long> resultado = new ArrayList<>();
        Object lista = datos.get("intoleranciaIds");
        if (lista instanceof List<?>) {
            for (Object id : (List<Object>) lista) {
                if (id != null) resultado.add(Long.valueOf(id.toString()));
            }
        }
        if (resultado.isEmpty() && datos.get("intoleranciaId") != null) {
            resultado.add(Long.valueOf(datos.get("intoleranciaId").toString()));
        }
        return resultado;
    }
}
