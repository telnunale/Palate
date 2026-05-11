package palate_backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;
import java.util.List;

@Service
public class IAServiceImpl implements IAService {

    @Value("${palate.gemini.api-key}")
    private String apiKey;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    @Override
    public Map<String, Object> generarReceta(String descripcion) throws Exception {
        String prompt = """
                Eres un chef profesional. Genera una receta basada en esta descripción: "%s"

                %s
                """.formatted(descripcion, getJsonRules());

        return llamarGemini(prompt);
    }

    @Override
    public Map<String, Object> generarRecetaConAversion(String descripcion, String alimentoRechazado, int nivelRechazo, List<Map<String, Object>> motivos) throws Exception {

        StringBuilder aversionInfo = new StringBuilder();
        aversionInfo.append("El usuario rechaza el ingrediente: ").append(alimentoRechazado);
        aversionInfo.append(" con un nivel de rechazo de ").append(nivelRechazo).append("/10.\n");
        aversionInfo.append("Los motivos del rechazo son:\n");

        for (Map<String, Object> motivo : motivos) {
            aversionInfo.append("- ").append(motivo.get("tipo"))
                    .append(" (intensidad ").append(motivo.get("intensidad")).append("/5)\n");
        }

        String reglaDeNivel;
        if (nivelRechazo <= 3) {
            reglaDeNivel = """
                El nivel de rechazo es BAJO (1-3). El ingrediente debe aparecer de forma OCULTA:
                - Usar cantidades muy pequeñas
                - Marcarlo con rol COMPLEMENTO o SECUNDARIO, nunca PROTAGONISTA
                - Elegir métodos de preparación que camuflen el ingrediente
                - El ingrediente NO debe ser visible ni reconocible en el plato
                """;
        } else if (nivelRechazo <= 6) {
            reglaDeNivel = """
                El nivel de rechazo es MEDIO (4-6). El ingrediente puede aparecer de forma moderada:
                - Usar cantidades reducidas (50-70% de lo normal)
                - Puede ser SECUNDARIO pero no PROTAGONISTA
                - Elegir métodos de preparación que suavicen el ingrediente
                """;
        } else {
            reglaDeNivel = """
                El nivel de rechazo es ALTO (7-10). El usuario casi tolera el ingrediente:
                - Usar cantidades normales o casi normales (80-100%)
                - Puede ser PROTAGONISTA o SECUNDARIO
                - Cualquier método de preparación es aceptable
                """;
        }

        StringBuilder reglasMotivo = new StringBuilder();
        for (Map<String, Object> motivo : motivos) {
            String tipo = motivo.get("tipo").toString();
            switch (tipo) {
                case "TEXTURA":
                    reglasMotivo.append("- Rechazo por TEXTURA: usar TRITURADO, EN_SALSA o FRITO. EVITAR: CRUDO, AL_VAPOR, HERVIDO.\n");
                    break;
                case "SABOR":
                    reglasMotivo.append("- Rechazo por SABOR: combinar con sabores fuertes. Usar EN_SALSA, MARINADO u HORNEADO. EVITAR: CRUDO, HERVIDO.\n");
                    break;
                case "OLOR":
                    reglasMotivo.append("- Rechazo por OLOR: cocción prolongada. Usar HORNEADO, FRITO o MARINADO. EVITAR: CRUDO, AL_VAPOR.\n");
                    break;
                case "COLOR":
                    reglasMotivo.append("- Rechazo por COLOR: ocultar visualmente. Usar TRITURADO, EN_SALSA u HORNEADO. EVITAR: CRUDO.\n");
                    break;
            }
        }

        String prompt = """
                Eres un chef profesional especializado en ayudar a personas con aversiones alimentarias.

                %s

                Reglas de nivel:
                %s

                Reglas según motivo de rechazo:
                %s

                El usuario quiere: "%s"

                Genera una receta que INCLUYA el ingrediente rechazado (%s) siguiendo las reglas anteriores.
                La receta debe ayudar al usuario a acostumbrarse progresivamente al ingrediente.

                %s
                """.formatted(aversionInfo, reglaDeNivel, reglasMotivo, descripcion, alimentoRechazado, getJsonRules());

        return llamarGemini(prompt);
    }

    @Override
    public Map<String, Object> generarRecetaConDespensa(String descripcion, List<String> ingredientesDespensa) throws Exception {
        StringBuilder listaIngredientes = new StringBuilder();
        for (String ingrediente : ingredientesDespensa) {
            listaIngredientes.append("- ").append(ingrediente).append("\n");
        }

        String prompt = """
                Eres un chef profesional. Genera una receta basada en esta descripción: "%s"

                El usuario tiene los siguientes ingredientes disponibles en casa. Prioriza usarlos en la receta:
                %s

                %s
                """.formatted(descripcion, listaIngredientes, getJsonRules());

        return llamarGemini(prompt);
    }

    @Override
    public Map<String, Object> generarRecetaConDespensaYAversion(String descripcion, List<String> ingredientesDespensa, String alimentoRechazado, int nivelRechazo, List<Map<String, Object>> motivos) throws Exception {
        StringBuilder listaIngredientes = new StringBuilder();
        for (String ingrediente : ingredientesDespensa) {
            listaIngredientes.append("- ").append(ingrediente).append("\n");
        }

        StringBuilder aversionInfo = new StringBuilder();
        aversionInfo.append("El usuario rechaza el ingrediente: ").append(alimentoRechazado);
        aversionInfo.append(" con un nivel de rechazo de ").append(nivelRechazo).append("/10.\n");
        aversionInfo.append("Los motivos del rechazo son:\n");

        for (Map<String, Object> motivo : motivos) {
            aversionInfo.append("- ").append(motivo.get("tipo"))
                    .append(" (intensidad ").append(motivo.get("intensidad")).append("/5)\n");
        }

        String reglaDeNivel;
        if (nivelRechazo <= 3) {
            reglaDeNivel = """
                El nivel de rechazo es BAJO (1-3). El ingrediente debe aparecer de forma OCULTA:
                - Usar cantidades muy pequeñas
                - Marcarlo con rol COMPLEMENTO o SECUNDARIO, nunca PROTAGONISTA
                - Elegir métodos de preparación que camuflen el ingrediente
                - El ingrediente NO debe ser visible ni reconocible en el plato
                """;
        } else if (nivelRechazo <= 6) {
            reglaDeNivel = """
                El nivel de rechazo es MEDIO (4-6). El ingrediente puede aparecer de forma moderada:
                - Usar cantidades reducidas (50-70% de lo normal)
                - Puede ser SECUNDARIO pero no PROTAGONISTA
                - Elegir métodos de preparación que suavicen el ingrediente
                """;
        } else {
            reglaDeNivel = """
                El nivel de rechazo es ALTO (7-10). El usuario casi tolera el ingrediente:
                - Usar cantidades normales o casi normales (80-100%)
                - Puede ser PROTAGONISTA o SECUNDARIO
                - Cualquier método de preparación es aceptable
                """;
        }

        StringBuilder reglasMotivo = new StringBuilder();
        for (Map<String, Object> motivo : motivos) {
            String tipo = motivo.get("tipo").toString();
            switch (tipo) {
                case "TEXTURA":
                    reglasMotivo.append("- Rechazo por TEXTURA: usar TRITURADO, EN_SALSA o FRITO. EVITAR: CRUDO, AL_VAPOR, HERVIDO.\n");
                    break;
                case "SABOR":
                    reglasMotivo.append("- Rechazo por SABOR: combinar con sabores fuertes. Usar EN_SALSA, MARINADO u HORNEADO. EVITAR: CRUDO, HERVIDO.\n");
                    break;
                case "OLOR":
                    reglasMotivo.append("- Rechazo por OLOR: cocción prolongada. Usar HORNEADO, FRITO o MARINADO. EVITAR: CRUDO, AL_VAPOR.\n");
                    break;
                case "COLOR":
                    reglasMotivo.append("- Rechazo por COLOR: ocultar visualmente. Usar TRITURADO, EN_SALSA u HORNEADO. EVITAR: CRUDO.\n");
                    break;
            }
        }

        String prompt = """
                Eres un chef profesional especializado en ayudar a personas con aversiones alimentarias.

                %s

                Reglas de nivel:
                %s

                Reglas según motivo de rechazo:
                %s

                El usuario quiere: "%s"

                El usuario tiene además los siguientes ingredientes disponibles en casa (prioriza usarlos):
                %s

                Genera una receta que INCLUYA el ingrediente rechazado (%s) siguiendo las reglas anteriores
                y que aproveche los ingredientes disponibles en la despensa del usuario.

                %s
                """.formatted(aversionInfo, reglaDeNivel, reglasMotivo, descripcion, listaIngredientes, alimentoRechazado, getJsonRules());

        return llamarGemini(prompt);
    }

    @Override
    public Map<String, Object> generarRecetaConAversiones(String descripcion, List<AversionPromptInfo> aversiones) throws Exception {
        if (aversiones == null || aversiones.isEmpty()) {
            return generarReceta(descripcion);
        }
        if (aversiones.size() == 1) {
            AversionPromptInfo unica = aversiones.get(0);
            return generarRecetaConAversion(descripcion, unica.alimentoRechazado(), unica.nivelRechazo(), unica.motivos());
        }

        String bloqueAversiones = construirBloqueAversiones(aversiones);
        String prompt = """
                Eres un chef profesional especializado en ayudar a personas con varias aversiones alimentarias simultaneamente.

                %s

                El usuario quiere: "%s"

                Genera una receta que INCLUYA TODOS los ingredientes rechazados listados, respetando para cada uno las reglas de nivel y de motivo indicadas. La receta debe ayudar al usuario a acostumbrarse progresivamente a esos ingredientes.

                %s
                """.formatted(bloqueAversiones, descripcion, getJsonRules());

        return llamarGemini(prompt);
    }

    @Override
    public Map<String, Object> generarRecetaConDespensaYAversiones(String descripcion, List<String> ingredientesDespensa, List<AversionPromptInfo> aversiones) throws Exception {
        if (aversiones == null || aversiones.isEmpty()) {
            return generarRecetaConDespensa(descripcion, ingredientesDespensa);
        }
        if (aversiones.size() == 1) {
            AversionPromptInfo unica = aversiones.get(0);
            return generarRecetaConDespensaYAversion(descripcion, ingredientesDespensa, unica.alimentoRechazado(), unica.nivelRechazo(), unica.motivos());
        }

        StringBuilder listaIngredientes = new StringBuilder();
        for (String ingrediente : ingredientesDespensa) {
            listaIngredientes.append("- ").append(ingrediente).append("\n");
        }

        String bloqueAversiones = construirBloqueAversiones(aversiones);
        String prompt = """
                Eres un chef profesional especializado en ayudar a personas con varias aversiones alimentarias simultaneamente.

                %s

                El usuario quiere: "%s"

                El usuario tiene ademas los siguientes ingredientes disponibles en casa (prioriza usarlos):
                %s

                Genera una receta que INCLUYA TODOS los ingredientes rechazados listados, respetando para cada uno las reglas de nivel y motivo indicadas, y que aproveche los ingredientes de la despensa.

                %s
                """.formatted(bloqueAversiones, descripcion, listaIngredientes, getJsonRules());

        return llamarGemini(prompt);
    }

    private String construirBloqueAversiones(List<AversionPromptInfo> aversiones) {
        StringBuilder bloque = new StringBuilder();
        bloque.append("El usuario tiene las siguientes aversiones alimentarias:\n\n");

        int indice = 1;
        for (AversionPromptInfo aversion : aversiones) {
            bloque.append("AVERSION ").append(indice).append(": ")
                    .append(aversion.alimentoRechazado())
                    .append(" (nivel ").append(aversion.nivelRechazo()).append("/10)\n");
            bloque.append("Motivos:\n");
            for (Map<String, Object> motivo : aversion.motivos()) {
                bloque.append("- ").append(motivo.get("tipo"))
                        .append(" (intensidad ").append(motivo.get("intensidad")).append("/5)\n");
            }
            bloque.append("Regla de nivel: ").append(describirReglaNivel(aversion.nivelRechazo())).append("\n");
            bloque.append("Reglas segun motivo:\n").append(describirReglasMotivo(aversion.motivos()));
            bloque.append("\n");
            indice++;
        }
        return bloque.toString();
    }

    private String describirReglaNivel(int nivelRechazo) {
        if (nivelRechazo <= 3) {
            return "BAJO (1-3): cantidades minimas, rol COMPLEMENTO o SECUNDARIO, metodo que camufle el ingrediente, no visible en el plato.";
        }
        if (nivelRechazo <= 6) {
            return "MEDIO (4-6): cantidades reducidas (50-70%), rol SECUNDARIO como maximo, metodo que suavice el ingrediente.";
        }
        return "ALTO (7-10): cantidades normales (80-100%), rol PROTAGONISTA o SECUNDARIO, cualquier metodo aceptable.";
    }

    private String describirReglasMotivo(List<Map<String, Object>> motivos) {
        StringBuilder reglas = new StringBuilder();
        for (Map<String, Object> motivo : motivos) {
            String tipo = motivo.get("tipo").toString();
            switch (tipo) {
                case "TEXTURA":
                    reglas.append("- TEXTURA: usar TRITURADO, EN_SALSA o FRITO. EVITAR: CRUDO, AL_VAPOR, HERVIDO.\n");
                    break;
                case "SABOR":
                    reglas.append("- SABOR: combinar con sabores fuertes. Usar EN_SALSA, MARINADO u HORNEADO. EVITAR: CRUDO, HERVIDO.\n");
                    break;
                case "OLOR":
                    reglas.append("- OLOR: coccion prolongada. Usar HORNEADO, FRITO o MARINADO. EVITAR: CRUDO, AL_VAPOR.\n");
                    break;
                case "COLOR":
                    reglas.append("- COLOR: ocultar visualmente. Usar TRITURADO, EN_SALSA u HORNEADO. EVITAR: CRUDO.\n");
                    break;
            }
        }
        return reglas.toString();
    }

    private String getJsonRules() {
        return """
                Responde SOLO con un JSON válido, sin texto adicional, sin markdown, sin ```json```.
                El JSON debe tener exactamente esta estructura:

                {
                    "titulo": "Nombre de la receta",
                    "descripcion": "Descripción breve (1-2 frases)",
                    "instrucciones": "1. Primer paso. 2. Segundo paso. 3. Tercer paso.",
                    "tiempoPreparacion": 15,
                    "tiempoCoccion": 30,
                    "dificultad": "MEDIA",
                    "ingredientes": [
                        {
                            "nombre": "Cebolla",
                            "categoria": "Verduras",
                            "cantidad": 0.5,
                            "unidadMedida": "ud",
                            "descripcionEdamam": "1/2 medium onion",
                            "rol": "PROTAGONISTA",
                            "metodoPreparacion": "HORNEADO"
                        }
                    ]
                }

                Reglas:
                - tiempoPreparacion y tiempoCoccion son números enteros en minutos
                - dificultad: FACIL, MEDIA o DIFICIL
                - rol: PROTAGONISTA, SECUNDARIO o COMPLEMENTO
                - metodoPreparacion: CRUDO, TRITURADO, EN_SALSA, HORNEADO, FRITO, HERVIDO, AL_VAPOR o MARINADO
                - categoria: Verduras, Frutas, Carnes, Pescados, Lácteos, Cereales, Legumbres, Condimentos, Tubérculos, Proteínas u Otros
                - cantidad es un número decimal (puede ser fraccion: 0.5, 0.25, 0.33)
                - unidadMedida: usar medidas caseras siempre que sea natural:
                    * Alimentos contables (huevos, cebollas, manzanas, patatas): "ud"
                    * Ajos: "diente"
                    * Condimentos secos, harinas, azucar: "cucharada" o "cucharadita"
                    * Liquidos pequenos (aceite, vinagre, salsas): "cucharada" o "ml"
                    * Carnes, pescados, verduras a granel: "g"
                    * Liquidos grandes (leche, caldo, agua): "ml"
                - descripcionEdamam: OBLIGATORIO. Texto en INGLES con la cantidad y nombre del ingrediente
                  en peso CRUDO para que la API Edamam calcule nutricion correctamente. Ejemplos:
                    * "1/2 medium onion"
                    * "1 tablespoon olive oil"
                    * "200g raw chicken breast"
                    * "1 clove garlic"
                    * "250ml whole milk"
                - Las cantidades de ingredientes son siempre en PESO CRUDO antes de cocinar
                - Incluye entre 3 y 8 ingredientes
                - Las instrucciones deben ser pasos numerados claros
                """;
    }

    private Map<String, Object> llamarGemini(String prompt) throws Exception {
        String requestBody = objectMapper.writeValueAsString(Map.of(
                "contents", new Object[]{
                        Map.of("parts", new Object[]{
                                Map.of("text", prompt)
                        })
                },
                "generationConfig", Map.of(
                        "temperature", 0.7,
                        "maxOutputTokens", 4096,
                        "responseMimeType", "application/json"
                )
        ));

        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(45))
                .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            throw new Exception("Error de Gemini: " + response.body());
        }

        JsonNode responseJson = objectMapper.readTree(response.body());
        String contenido = responseJson
                .path("candidates")
                .path(0)
                .path("content")
                .path("parts")
                .path(0)
                .path("text")
                .asText();

        contenido = contenido.trim();
        if (contenido.startsWith("```json")) {
            contenido = contenido.substring(7);
        }
        if (contenido.startsWith("```")) {
            contenido = contenido.substring(3);
        }
        if (contenido.endsWith("```")) {
            contenido = contenido.substring(0, contenido.length() - 3);
        }
        contenido = contenido.trim();

        @SuppressWarnings("unchecked")
        Map<String, Object> recetaMap = objectMapper.readValue(contenido, Map.class);

        return recetaMap;
    }
}
