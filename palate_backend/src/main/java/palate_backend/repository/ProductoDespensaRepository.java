package palate_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import palate_backend.model.ProductoDespensa;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ProductoDespensaRepository extends JpaRepository<ProductoDespensa, Long> {

    List<ProductoDespensa> findByUsuarioId(Long usuarioId);

    List<ProductoDespensa> findByUsuarioIdAndConsumidoFalse(Long usuarioId);

    @Query("SELECT p FROM ProductoDespensa p WHERE p.usuario.id = :usuarioId AND p.consumido = false AND p.fechaCaducidad <= :fechaLimite ORDER BY p.fechaCaducidad ASC")
    List<ProductoDespensa> buscarProximosACaducar(@Param("usuarioId") Long usuarioId, @Param("fechaLimite") LocalDate fechaLimite);
}
