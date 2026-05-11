package palate_backend.service;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Optional;

/**
 * Cliente de la API de busqueda de imagenes de Pexels. Usado como
 * segundo paso en la cascada de resolucion de imagen de receta.
 */
@Service
public class PexelsImagenService {

    private static final String ENDPOINT = "https://api.pexels.com/v1/search";

    private final String apiKey;
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public PexelsImagenService(@Value("${palate.pexels.api-key:}") String apiKey) {
        this.apiKey = apiKey;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(5))
                .build();
    }

    public Optional<String> buscarImagen(String consulta) {
        if (apiKey == null || apiKey.isBlank()) return Optional.empty();
        if (consulta == null || consulta.isBlank()) return Optional.empty();

        try {
            String query = URLEncoder.encode(consulta.trim(), StandardCharsets.UTF_8);
            String url = ENDPOINT + "?query=" + query
                    + "&per_page=1&orientation=landscape&size=medium";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Authorization", apiKey)
                    .timeout(Duration.ofSeconds(8))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(
                    request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                System.err.println("[Pexels] Status " + response.statusCode()
                        + " para query=\"" + consulta + "\"");
                return Optional.empty();
            }

            JsonNode root = objectMapper.readTree(response.body());
            JsonNode photos = root.path("photos");
            if (!photos.isArray() || photos.isEmpty()) {
                return Optional.empty();
            }

            JsonNode src = photos.get(0).path("src");
            String urlImagen = src.path("large").asText(null);
            if (urlImagen == null || urlImagen.isBlank()) {
                urlImagen = src.path("medium").asText(null);
            }
            return Optional.ofNullable(urlImagen);

        } catch (Exception e) {
            System.err.println("[Pexels] Error consultando API: " + e.getMessage());
            return Optional.empty();
        }
    }
}
