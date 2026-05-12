package palate_backend.service;

import java.util.List;
import java.util.Map;

public interface IAService {

    Map<String, Object> generarReceta(String descripcion) throws Exception;

    Map<String, Object> generarRecetaConAversion(String descripcion, String alimentoRechazado, int nivelRechazo, List<Map<String, Object>> motivos) throws Exception;

    Map<String, Object> generarRecetaConDespensa(String descripcion, List<String> ingredientesDespensa) throws Exception;

    Map<String, Object> generarRecetaConDespensaYAversion(String descripcion, List<String> ingredientesDespensa, String alimentoRechazado, int nivelRechazo, List<Map<String, Object>> motivos) throws Exception;

    Map<String, Object> generarRecetaConAversiones(String descripcion, List<AversionPromptInfo> aversiones) throws Exception;

    Map<String, Object> generarRecetaConDespensaYAversiones(String descripcion, List<String> ingredientesDespensa, List<AversionPromptInfo> aversiones) throws Exception;

    /**
     * Estima calorias y macronutrientes totales de una receta usando Gemini.
     * Sustituye a Edamam cuando se agota la cuota. Devuelve un mapa con las
     * claves: calorias, proteinas, hidratos, grasas (todas Double en gramos
     * salvo calorias en kcal). Devuelve null si no se pudo estimar.
     */
    Map<String, Object> analizarNutricion(String titulo, List<String> ingredientes) throws Exception;

    record AversionPromptInfo(String alimentoRechazado, int nivelRechazo, List<Map<String, Object>> motivos) {}
}
