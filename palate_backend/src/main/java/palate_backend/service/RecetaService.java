package palate_backend.service;

import palate_backend.dto.RecetaDTO;

import java.util.List;
import java.util.Optional;

public interface RecetaService {

    List<RecetaDTO> obtenerTodas();

    Optional<RecetaDTO> obtenerPorId(Long id);

    RecetaDTO generarYGuardar(String descripcion) throws Exception;

    RecetaDTO generarYGuardarConAversion(String descripcion, Long intoleranciaId) throws Exception;

    RecetaDTO generarYGuardarConDespensa(Long usuarioId, Long intoleranciaId, String descripcion) throws Exception;

    RecetaDTO generarYGuardarConAversiones(String descripcion, List<Long> intoleranciaIds) throws Exception;

    RecetaDTO generarYGuardarConDespensaYAversiones(Long usuarioId, List<Long> intoleranciaIds, String descripcion) throws Exception;

    Optional<String> regenerarImagen(Long recetaId);
}
