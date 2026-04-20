package palate_backend.service;

import palate_backend.dto.RecetaDTO;

import java.util.List;
import java.util.Optional;

public interface RecetaService {

    List<RecetaDTO> obtenerTodas();

    Optional<RecetaDTO> obtenerPorId(Long id);

    RecetaDTO generarYGuardar(String descripcion) throws Exception;

    RecetaDTO generarYGuardarConAversion(String descripcion, Long intoleranciaId) throws Exception;
}
