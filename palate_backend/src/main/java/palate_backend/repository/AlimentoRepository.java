package palate_backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import palate_backend.model.Alimento;

import java.util.Optional;

@Repository
public interface AlimentoRepository extends JpaRepository<Alimento, Long> {

    Optional<Alimento> findByNombreIgnoreCase(String nombre);
}
