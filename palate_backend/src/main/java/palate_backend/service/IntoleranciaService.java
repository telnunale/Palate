package palate_backend.service;

import palate_backend.dto.IntoleranciaDTO;

import java.util.List;
import java.util.Map;

public interface IntoleranciaService {

    List<IntoleranciaDTO> obtenerPorUsuario(Long usuarioId);

    void crear(Long usuarioId, Long alimentoId, int nivelRechazo, List<Map<String, Object>> motivos);

    void eliminar(Long id);
}
