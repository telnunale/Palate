package palate_backend.service;

import java.util.List;
import java.util.Map;

public interface IAService {

    Map<String, Object> generarReceta(String descripcion) throws Exception;

    Map<String, Object> generarRecetaConAversion(String descripcion, String alimentoRechazado, int nivelRechazo, List<Map<String, Object>> motivos) throws Exception;
}
