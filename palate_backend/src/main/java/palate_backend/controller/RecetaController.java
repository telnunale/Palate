package palate_backend.controller;

import palate_backend.model.Receta;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/recetas")
public class RecetaController {
    @PersistenceContext
    private EntityManager em;

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
}