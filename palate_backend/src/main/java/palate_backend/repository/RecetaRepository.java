package palate_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import palate_backend.model.Receta;

import java.util.List;

@Repository
public interface RecetaRepository extends JpaRepository<Receta, Long> {

    List<Receta> findByTituloContainingIgnoreCase(String titulo);

    @Query("SELECT r FROM Receta r WHERE LOWER(r.titulo) LIKE LOWER(:busqueda) OR LOWER(r.descripcion) LIKE LOWER(:busqueda)")
    List<Receta> buscarEnCache(@Param("busqueda") String busqueda);
}
