package palate_backend.service;

import palate_backend.dto.ProductoDespensaDTO;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface DespensaService {

    List<ProductoDespensaDTO> obtenerPorUsuario(Long usuarioId);

    ProductoDespensaDTO añadir(Long usuarioId, Long alimentoId, LocalDate fechaCaducidad, BigDecimal cantidad, String unidad);

    ProductoDespensaDTO actualizar(Long id, Map<String, Object> datos);

    void eliminar(Long id);

    List<ProductoDespensaDTO> obtenerProximosACaducar(Long usuarioId, int dias);
}
