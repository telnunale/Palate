package palate_backend.service;

import palate_backend.dto.RecetaRecomendadaDTO;

import java.util.List;

public interface RecomendacionService {

    List<RecetaRecomendadaDTO> obtenerRecomendaciones(Long usuarioId);
}
