package palate_backend.dao;

import palate_backend.model.Usuario;
import java.util.List;
import java.util.Optional;

public interface UsuarioDao {
    boolean crearUsuario(Usuario usuario);
    Optional<Usuario> buscarPorID(long id);
    Usuario actualizarUsuario(Usuario usuario);
    boolean eliminarUsuario(Usuario usuario);
    Optional<Usuario> buscarPorEmail(String email);
    List<Usuario> recuperarTodos();
}
