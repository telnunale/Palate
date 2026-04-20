package palate_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import palate_backend.model.IntoleranciaUsuario;

import java.util.List;

@Repository
public interface IntoleranciaUsuarioRepository extends JpaRepository<IntoleranciaUsuario, Long> {

    List<IntoleranciaUsuario> findByUsuarioId(Long usuarioId);
}
