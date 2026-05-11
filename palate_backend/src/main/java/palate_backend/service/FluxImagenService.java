package palate_backend.service;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;
import java.util.Optional;

/**
 * Cliente fal.ai FLUX schnell. Genera la imagen de una receta y la sube
 * a Cloudinary para servirla desde un CDN permanente.
 */
@Service
public class FluxImagenService {

    private static final String ENDPOINT = "https://fal.run/fal-ai/flux/schnell";

    private final String apiKey;
    private final CloudinaryImagenService cloudinaryImagenService;
    private final HttpClient httpClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public FluxImagenService(
            @Value("${palate.fal.api-key:}") String apiKey,
            CloudinaryImagenService cloudinaryImagenService) {
        this.apiKey = apiKey;
        this.cloudinaryImagenService = cloudinaryImagenService;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    public Optional<String> generarYGuardar(Long recetaId, String tituloReceta) {
        if (tituloReceta == null || tituloReceta.isBlank()) return Optional.empty();
        return generarYGuardarConPrompt(recetaId, construirPromptBasico(tituloReceta));
    }

    public Optional<String> generarYGuardarConPrompt(Long recetaId, String prompt) {
        if (apiKey == null || apiKey.isBlank()) return Optional.empty();
        if (recetaId == null || prompt == null || prompt.isBlank()) {
            return Optional.empty();
        }

        try {
            Optional<String> urlTemporal = invocarFlux(prompt);
            if (urlTemporal.isEmpty()) return Optional.empty();

            if (cloudinaryImagenService.estaConfigurado()) {
                Optional<String> cdn = cloudinaryImagenService.subirDesdeUrl(urlTemporal.get(), recetaId);
                if (cdn.isPresent()) return cdn;
            }
            return urlTemporal;
        } catch (Exception e) {
            System.err.println("[FluxImagen] Error generando imagen: " + e.getMessage());
            return Optional.empty();
        }
    }

    private String construirPromptBasico(String tituloReceta) {
        return "Professional food photography of \"" + tituloReceta
                + "\", a traditional Spanish/Mediterranean dish, "
                + "overhead shot, neutral ceramic plate, warm natural "
                + "lighting, terracotta tones, appetizing, high detail, "
                + "no text, no watermark, no people";
    }

    private Optional<String> invocarFlux(String prompt) throws Exception {
        String body = objectMapper.writeValueAsString(Map.of(
                "prompt", prompt,
                "image_size", "landscape_4_3",
                "num_inference_steps", 4,
                "num_images", 1,
                "enable_safety_checker", true
        ));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(ENDPOINT))
                .header("Authorization", "Key " + apiKey)
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(45))
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        HttpResponse<String> response = httpClient.send(
                request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() != 200) {
            System.err.println("[FluxImagen] Status " + response.statusCode()
                    + " body=" + response.body());
            return Optional.empty();
        }

        JsonNode root = objectMapper.readTree(response.body());
        JsonNode images = root.path("images");
        if (!images.isArray() || images.isEmpty()) {
            return Optional.empty();
        }
        String url = images.get(0).path("url").asText(null);
        return Optional.ofNullable(url);
    }
}
