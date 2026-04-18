package palate_backend.controller;

import palate_backend.model.Receta;
import palate_backend.service.RecetaGeneradorService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/recetas")
public class RecetaController {

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private RecetaGeneradorService recetaGeneradorService;

    @GetMapping
    public List<Receta> obtenerTodas() {
        String jpql = "SELECT r FROM Receta r";
        TypedQuery<Receta> query = em.createQuery(jpql, Receta.class);
        return query.getResultList();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Receta> obtenerPorId(@PathVariable Long id) {
        Receta r = em.find(Receta.class, id);
        if (r != null) {
            return ResponseEntity.ok(r);
        }
        return ResponseEntity.notFound().build();
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
            Receta receta = recetaGeneradorService.generarYGuardar(descripcion);
            return ResponseEntity.ok(receta);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Error al generar la receta: " + e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }
}