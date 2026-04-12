package palate_backend.dao;

import palate_backend.model.Alimento;
import java.util.List;
import java.util.Optional;

public interface AlimentoDao {
    boolean crearAlimento(Alimento alimento);
    Optional<Alimento> buscarPorID(long id);
    Alimento actualizarAlimento(Alimento alimento);
    boolean eliminarAlimento(Alimento alimento);
    List<Alimento> recuperarTodos();
    Optional<Alimento> buscarPorNombre(String nombre);
    List<Alimento> buscarPorCategoria(String categoria);
}
