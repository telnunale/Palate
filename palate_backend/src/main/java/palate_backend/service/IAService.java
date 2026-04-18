package palate_backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Map;

@Service
public class IAService {

    @Value("${palate.gemini.api-key}")
    private String apiKey;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    public Map<String, Object> generarReceta(String descripcion) throws Exception {

        String prompt = """
                Eres un chef profesional. Genera una receta basada en esta descripción: "%s"
                
                Responde SOLO con un JSON válido, sin texto adicional, sin markdown, sin ```json```.
                El JSON debe tener exactamente esta estructura:
                
                {
                    "titulo": "Nombre de la receta",
                    "descripcion": "Descripción breve de la receta (1-2 frases)",
                    "instrucciones": "1. Primer paso. 2. Segundo paso. 3. Tercer paso.",
                    "tiempoPreparacion": 15,
                    "tiempoCoccion": 30,
                    "dificultad": "MEDIA",
                    "ingredientes": [
                        {
                            "nombre": "Nombre del ingrediente",
                            "categoria": "Verduras",
                            "cantidad": 200,
                            "unidadMedida": "g",
                            "rol": "PROTAGONISTA",
                            "metodoPreparacion": "HORNEADO"
                        }
                    ]
                }
                
                Reglas importantes:
                - tiempoPreparacion y tiempoCoccion son números enteros en minutos
                - dificultad solo puede ser: FACIL, MEDIA o DIFICIL
                - rol solo puede ser: PROTAGONISTA, SECUNDARIO o COMPLEMENTO
                - metodoPreparacion solo puede ser: CRUDO, TRITURADO, EN_SALSA, HORNEADO, FRITO, HERVIDO, AL_VAPOR o MARINADO
                - categoria solo puede ser: Verduras, Frutas, Carnes, Pescados, Lácteos, Cereales, Legumbres, Condimentos, Tubérculos, Proteínas u Otros
                - cantidad es un número decimal
                - Incluye entre 3 y 8 ingredientes
                - Las instrucciones deben ser pasos numerados claros
                """.formatted(descripcion);

        String requestBody = objectMapper.writeValueAsString(Map.of(
                "contents", new Object[]{
                        Map.of("parts", new Object[]{
                                Map.of("text", prompt)
                        })
                },
                "generationConfig", Map.of(
                        "temperature", 0.7,
                        "maxOutputTokens", 1500,
                        "responseMimeType", "application/json"
                )
        ));

        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + apiKey;

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
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