package palate_backend.dao;

import palate_backend.model.Receta;
import java.util.List;
import java.util.Optional;

public interface RecetaDao {
    boolean crearReceta(Receta receta);
    Optional<Receta> buscarPorID(long id);
    Receta actualizarReceta(Receta receta);
    boolean eliminarReceta(Receta receta);
    List<Receta> recuperarTodas();
    List<Receta> buscarPorTitulo(String titulo);
}
